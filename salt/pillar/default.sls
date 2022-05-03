#!py

def run():
    pillar = {}
    pillar["caddy_config"] = {
        "apps": {
            "tls": {
                "automation": {
                    "policies": [
                        {
                            "subjects": ["bkurtz.io"],
                            "issuers": [
                                {
                                    "ca": "https://acme-staging-v02.api.letsencrypt.org/directory",
                                    "email": "kurtz.brandon@gmail.com",
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
                        "routes": [
                            {
                                "match": [{"host": ["helloworld.bkurtz.io"]}],
                                "terminal": True,
                                "handle": [
                                    {
                                        "handler": "reverse_proxy",
                                        "upstreams": [{"dial": "localhost:8080"}],
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
                            }
                        ],
                    }
                }
            },
        }
    }

    return pillar
