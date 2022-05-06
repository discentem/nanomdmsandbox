#!py

def run():

    #### template template_variables ####
    
    
    #### end template template_variables ####

    # return string of final contents
    contents = [
        "# disable to make runs quick on macOS",
        "enable_fqdns_grains: False"
    ]
    return "\n".join(contents)