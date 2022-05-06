#!py

def run():
    config = {}

    print("caddy.path", __salt__['pillar.get']("caddy.path"))

    config['manage caddy.json'] = {
        'file.managed': [
            {'name': __salt__['pillar.get']("caddy")["path"]},
            {'source': 'salt://states/caddy/templates/caddy.sls'},
            {'template': "py"},
            # inject data into the template
            {'template_variables': {
                'email': 'kurtz.brandon@gmail.com',
                'subjects': ['bkurtz.io'],
                'hostname_mappings': {
                    'helloworld.bkurtz.io': 'localhost:8080'
                }   
            }}
        ]
    }
    return config
