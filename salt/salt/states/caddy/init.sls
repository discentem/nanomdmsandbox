#!py

def run():
    config = {}

    caddy_config = __salt__['pillar.get']("caddy_config", None)

    config['manage caddy.json'] = {
        'file.serialize': [
            {'name': '/Users/brandon_kurtz/caddy.json'},
            {'dataset': caddy_config},
            {'formatter': 'json'},
            {'makedirs': True}
        ]
    }

    return config