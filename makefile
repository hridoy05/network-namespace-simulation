# Define variables for namespace and bridge names
NS1=ns1
NS2=ns2
ROUTER=router-ns
BR0=br0
BR1=br1

setup:
	# Create network bridges
	sudo ip link add name $(BR0) type bridge
	sudo ip link add name $(BR1) type bridge
	sudo ip link set $(BR0) up
	sudo ip link set $(BR1) up

	# Create network namespaces
	sudo ip netns add $(NS1)
	sudo ip netns add $(NS2)
	sudo ip netns add $(ROUTER)

	# Create virtual Ethernet pairs
	sudo ip link add veth-ns1 type veth peer name veth-br0
	sudo ip link add veth-ns2 type veth peer name veth-br1
	sudo ip link add veth-router0 type veth peer name veth-router0-br
	sudo ip link add veth-router1 type veth peer name veth-router1-br

	# Move interfaces to namespaces
	sudo ip link set veth-ns1 netns $(NS1)
	sudo ip link set veth-ns2 netns $(NS2)
	sudo ip link set veth-router0 netns $(ROUTER)
	sudo ip link set veth-router1 netns $(ROUTER)

	# Attach other ends to bridges
	sudo ip link set veth-br0 master $(BR0)
	sudo ip link set veth-br1 master $(BR1)
	sudo ip link set veth-router0-br master $(BR0)
	sudo ip link set veth-router1-br master $(BR1)

	# Bring up interfaces
	sudo ip link set veth-br0 up
	sudo ip link set veth-br1 up
	sudo ip link set veth-router0-br up
	sudo ip link set veth-router1-br up

	# Assign IP addresses
	sudo ip netns exec $(NS1) ip addr add 192.168.1.2/24 dev veth-ns1
	sudo ip netns exec $(NS2) ip addr add 192.168.2.2/24 dev veth-ns2
	sudo ip netns exec $(ROUTER) ip addr add 192.168.1.1/24 dev veth-router0
	sudo ip netns exec $(ROUTER) ip addr add 192.168.2.1/24 dev veth-router1

	# Bring up interfaces inside namespaces
	sudo ip netns exec $(NS1) ip link set veth-ns1 up
	sudo ip netns exec $(NS2) ip link set veth-ns2 up
	sudo ip netns exec $(ROUTER) ip link set veth-router0 up
	sudo ip netns exec $(ROUTER) ip link set veth-router1 up

	# Enable loopback interfaces
	sudo ip netns exec $(NS1) ip link set lo up
	sudo ip netns exec $(NS2) ip link set lo up
	sudo ip netns exec $(ROUTER) ip link set lo up

	# Enable IP forwarding in router
	sudo ip netns exec $(ROUTER) sysctl -w net.ipv4.ip_forward=1

	# Set default routes
	sudo ip netns exec $(NS1) ip route add default via 192.168.1.1
	sudo ip netns exec $(NS2) ip route add default via 192.168.2.1

test:
	# Test connectivity between ns1 and ns2
	sudo ip netns exec $(NS1) ping -c 3 192.168.2.2 || echo "Ping failed!"

clean:
	# Delete namespaces
	sudo ip netns delete $(NS1) || true
	sudo ip netns delete $(NS2) || true
	sudo ip netns delete $(ROUTER) || true

	# Delete bridges
	sudo ip link delete $(BR0) type bridge || true
	sudo ip link delete $(BR1) type bridge || true

	# Delete veth pairs (if still existing)
	sudo ip link delete veth-br0 || true
	sudo ip link delete veth-br1 || true
	sudo ip link delete veth-router0-br || true
	sudo ip link delete veth-router1-br || true

	@echo "Cleanup completed."
