#!py

def run():
    config = {}
    config['manage caddy.json'] = {
        'file.managed': [
            {'name': '/Users/brandon_kurtz/caddy.json'},
            {'source': 'salt://templates/caddy.sls'},
            {'template': "py"},
            # inject data into the template
            {'context': {
                'email': 'kurtz.brandon@gmail.com',
                'subjects': ['bkurtz.io'],
                'hostname_mappings': {
                    'helloworld.bkurtz.io': 'localhost:8080'
                }   
            }}
        ]
    }


    return config