import subprocess

# Run command to get wifi networks
output = subprocess.check_output('nmcli dev wifi list', shell=True)

# Decode bytes to string and split output by new lines
networks = output.decode().split('\n')

# Print each network
for network in networks:
    print(network)
