manage caddy.json:
    file.managed:
      - name: /Users/brandon_kurtz/caddy.json
      - source: salt://states/caddy/templates/caddy.sls
      - template: py
      - template_variables:
          email: kurtz.brandon@gmail.com
          subjects:
          - bkurtz.io
          hostname_mappings:
            helloworld.bkurtz.io: 'localhost:8080'



# def run():
#     config = {}
#     config['manage caddy.json'] = {
#         'file.managed': [
#             {'name': '/Users/brandon_kurtz/caddy.json'},
#             {'source': 'salt://states/caddy/templates/caddy.sls'},
#             {'template': "py"},
#             # inject data into the template
#             {'context': {
#                 'email': 'kurtz.brandon@gmail.com',
#                 'subjects': ['bkurtz.io'],
#                 'hostname_mappings': {
#                     'helloworld.bkurtz.io': 'localhost:8080'
#                 }   
#             }}
#         ]
#     }
#     return config
