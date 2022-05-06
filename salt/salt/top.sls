#!py

def run():
  top_file = {
    'base': {
        '*': [ 'states.caddy' ]
    }
  }

  os = __salt__['grains.get']("os", None)
  if os == "MacOS":
      top_file = {
        'base': {
            '*': [ 'states.caddy', 'states.minion_config' ]
        }
  }

  return top_file