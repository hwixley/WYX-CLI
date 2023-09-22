import random, string, sys

DEFAULT_LENGTH = 16

args = sys.argv()
str_length = DEFAULT_LENGTH

if len(args) > 1:
    str_length = args[1]

random_pass = ''.join(random.choices(string.ascii_uppercase, k=str_length))
print(random_pass)
