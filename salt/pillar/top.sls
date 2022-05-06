#!py

def run():
  top_file = {
    # apply default pillar values for everything
    'base': {
        '*': [ 'default' ]
    }
  }

  os = __salt__['grains.get']("os", None)
  if os == "Ubuntu":
      top_file = {
        # if Ubuntu, override with Ubuntu pillar values
        'base': {
            '*': [ 'default', 'Ubuntu' ]
        }
  }

  return top_file