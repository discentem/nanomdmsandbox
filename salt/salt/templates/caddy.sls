#!py

import json
from collections import OrderedDict

def run():

    # context variables
    hostname_mappings = context['hostname_mappings'] # type: ignore
    subjects = context['subjects'] # type: ignore
    email = context['email'] # type: ignore
    
    caddy_config = OrderedDict()
    caddy_config = {
        "apps": {
            "tls": {
                "automation": {
                    "policies": [
                        {
                            "subjects": subjects,
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
                        "routes": [],
                    }
                }
            },
        }
    }

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
    return json.dumps(caddy_config, indent = 2) 