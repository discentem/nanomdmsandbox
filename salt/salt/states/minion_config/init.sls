#!py

import os

def run():
    print()

    config = {}
    minion_conf = __salt__['config.get']('file_roots')[saltenv][0]
    config['manage minion config'] = {
        'file.managed': [
            {'name': "{}/minion".format(minion_conf) },
            {'source': 'salt://states/minion_config/templates/minion.sls'},
            {'template': "py"},
            # inject data into the template
            {'template_variables': {} }
        ]
    }
    return config