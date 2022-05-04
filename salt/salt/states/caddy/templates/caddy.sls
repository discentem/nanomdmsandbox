#!py

import json
from collections import OrderedDict

# salt makes template_variables dict available but template_variables is not defined in this file
#  so we have to tell pylance to not report undefined template_variables
# pyright: reportUndefinedVariable=false

def run():

    #### template template_variables ####
    
    # ensure template template_variables are the type that is intended
    if type(template_variables['subjects']) is not list:
        raise Exception("template_variables['subjects'] must be list")
    if type(template_variables['email']) is not str:
        raise Exception("template_variables['email'] must be str")

    try:
        # Force hostname_mappings into collections.OrderedDict instead of <class 'salt.utils.odict.OrderedDict'>
        # hostname_mappings will be salt.utils.odict.OrderedDict if ../init.sls is using the default renderer
        # https://docs.saltproject.io/en/latest/ref/renderers/all/salt.renderers.yaml.html.
        # It is not clear how type check salt.util.odict.OrderedDict so we do this instead.
        hostname_mappings = OrderedDict(template_variables['hostname_mappings'])
    except Exception as e:
        raise e

    # copy template template_variables to local template_variables
    subjects = template_variables['subjects']
    email = template_variables['email']
    
    #### end template template_variables ####

    # ensure dict order so we don't regenerate the rendered template unnecessarily
    caddy_config = OrderedDict()
    caddy_config = {
        "apps": {
            "tls": {
                "automation": {
                    "policies": [
                        {
                            "subjects": subjects, # injected template variable
                            "issuers": [
                                {
                                    "ca": "https://acme-staging-v02.api.letsencrypt.org/directory",
                                    "email": email,
                                    "module": "acme",
                                    "challenges": {
                                        "dns": {
                                            "provider": {
                                                "name": "digitalocean",
                                                "auth_token": "",
                                            },
                                            "resolvers": [
                                                "ns1.digitalocean.com",
                                                "ns2.digitalocean.com",
                                            ],
                                        }
                                    },
                                }
                            ],
                        }
                    ]
                }
            },
            "http": {
                "servers": {
                    "myServer": {
                        "listen": [":443", ":80"],
                        "routes": [], # routes dynamically generated below
                    }
                }
            },
        }
    }

    # append a handler to routes for each host mapping
    for ext, local in hostname_mappings.items(): # type: ignore
        caddy_config['apps']['http']['servers']['myServer']['routes'].append({
            "match": [{"host": [ext]}],
            "terminal": True,
            "handle": [
                {
                    "handler": "reverse_proxy",
                    "upstreams": [{"dial": local}],
                    "headers": {
                        "request": {
                            "set": {
                                "Host": [
                                    "{http.reverse_proxy.upstream.host}"
                                ]
                            }
                        }
                    },
                    "transport": {"protocol": "http"},
                }
            ],
        })
    # return string of final contents
    return json.dumps(caddy_config, indent = 2) 