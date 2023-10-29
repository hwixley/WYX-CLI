import termcolor

def info(message):
    print(termcolor.colored(message, "green"))

def error(message):
    print(termcolor.colored(message, "red"))