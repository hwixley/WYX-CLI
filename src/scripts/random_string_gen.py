import random, string, sys

DEFAULT_LENGTH = 16

args = sys.argv
str_length = DEFAULT_LENGTH

if len(args) > 1 and args[1].isnumeric:
    str_length = int(args[1])

random_pass = ''.join(random.choices(string.hexdigits + string.punctuation, k=str_length))
print(random_pass)
