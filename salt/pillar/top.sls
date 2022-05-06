#!py

def run():
  top_file = {
    'base': {
        '*': [ 'default' ]
    }
  }

  os = __salt__['grains.get']("os", None)
  if os == "Ubuntu":
      top_file = {
        'base': {
            '*': [ 'default', 'Ubuntu' ]
        }
  }

  return top_file