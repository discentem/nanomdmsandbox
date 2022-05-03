#!py

import json
from collections import OrderedDict

# salt makes context dict available but context is not defined in this file
#  so we have to tell pylance to not report undefined variables
# pyright: reportUndefinedVariable=false

def run():

    #### template variables ####
    
    # ensure template variables are the type that is intended
    if type(context['hostname_mappings']) is not dict:
        raise Exception("context['hostname_mappings'] must be dict")
    if type(context['subjects']) is not list:
        raise Exception("context['subjects'] must be list")
    if type(context['email']) is not str:
        raise Exception("context['email'] must be str")

    # copy template variables to local variables
    hostname_mappings = context['hostname_mappings']
    subjects = context['subjects']
    email = context['email']
    
    #### end template variables ####

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