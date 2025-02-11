Linux Network Namespace Simulation Assignment

Main Objective :
Create a network simulation with two separate networks connected via a router using Linux network namespaces and bridges.

# Script Executable

`chmod +x network-namespace-simulation.sh`

# Run the Script:

`sudo ./network-namespace-simulation.sh`

# IP Addressing Scheme:

ns1: 192.168.1.2/24
ns2: 192.168.2.2/24

# router-ns:

- 192.168.1.1/24 (br0 side)
- 192.168.2.1/24 (br1 side)

# Routing Configuration:

Default routes in ns1 and ns2 via router-ns
IP forwarding enabled in router-ns

# Testing

ping test verifies connectivity between ns1 and ns2 through the router namespace.
