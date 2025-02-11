#!/bin/bash

# Set up network simulation with two separate networks connected via a router namespace

# Clean up function
cleanup() {
    ip netns del ns1 2>/dev/null
    ip netns del ns2 2>/dev/null
    ip netns del router-ns 2>/dev/null
    ip link del br0 2>/dev/null
    ip link del br1 2>/dev/null
    ip link del veth0 2>/dev/null
    ip link del veth1 2>/dev/null
    ip link del veth-router0 2>/dev/null
    ip link del veth-router1 2>/dev/null
}

# Execute cleanup to start fresh
cleanup

# Create network namespaces
ip netns add ns1
ip netns add ns2
ip netns add router-ns

# Create network bridges
ip link add br0 type bridge
ip link add br1 type bridge
ip link set br0 up
ip link set br1 up

# Create virtual ethernet (veth) pairs
ip link add veth0 type veth peer name veth-br0
ip link add veth1 type veth peer name veth-br1
ip link add veth-router0 type veth peer name veth-br0-router
ip link add veth-router1 type veth peer name veth-br1-router

# Assign veth interfaces to namespaces
ip link set veth0 netns ns1
ip link set veth1 netns ns2
ip link set veth-router0 netns router-ns
ip link set veth-router1 netns router-ns

# Connect virtual interfaces to bridges
ip link set veth-br0 master br0
ip link set veth-br1 master br1
ip link set veth-br0-router master br0
ip link set veth-br1-router master br1

ip link set veth-br0 up
ip link set veth-br1 up
ip link set veth-br0-router up
ip link set veth-br1-router up

# Assign IP addresses
ip netns exec ns1 ip addr add 192.168.1.2/24 dev veth0
ip netns exec ns1 ip link set veth0 up

ip netns exec ns2 ip addr add 192.168.2.2/24 dev veth1
ip netns exec ns2 ip link set veth1 up

ip netns exec router-ns ip addr add 192.168.1.1/24 dev veth-router0
ip netns exec router-ns ip addr add 192.168.2.1/24 dev veth-router1
ip netns exec router-ns ip link set veth-router0 up
ip netns exec router-ns ip link set veth-router1 up

# Bring router namespace interfaces up
ip netns exec router-ns ip link set lo up

# Enable IP forwarding in router namespace
ip netns exec router-ns sysctl -w net.ipv4.ip_forward=1

# Set up routing
ip netns exec ns1 ip route add default via 192.168.1.1
ip netns exec ns2 ip route add default via 192.168.2.1

# Enable connectivity test
echo "Testing connectivity..."
ip netns exec ns1 ping  192.168.2.2

echo "Network setup complete!"
