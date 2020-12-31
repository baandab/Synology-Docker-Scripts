#!/bin/bash


d=`date "+%Y-%m-%d - %H:%M:%S"`

echo
echo
echo

echo "$d - Starting Docker Network Shim..."

MATCH=`/sbin/ip link | grep -c "mynet-shim"`

if [ "$MATCH" == "1" ]
then
	echo
	echo "Network exists... removing it first... "
	/sbin/ip link set mynet-shim down
	/sbin/ip link delete mynet-shim 
fi

echo
echo "Sleeping 15 seconds..."

sleep 15

echo 
echo "Creating macvlan1 and network shim..." 

#create network shim - see https://blog.oddbit.com/post/2018-03-12-using-docker-macvlan-networks/
#
# this creates a subnet (192.168.0.40 to 192.168.0.48) that we can connect to via 192.168.0.49
#
# 192.168.0.49/32 is one address: 192.168.0.49
# 192.168.0.40/29 is a range 192.168.0.40 to 192.168.0.48
# 192.168.0.0/24 is a range 192.168.0.40 to 192.168.0.255
#  
  
# create shim 
/sbin/ip link add mynet-shim link eth0 type macvlan  mode bridge

sleep 5

# add host to shim
/sbin/ip address add 192.168.0.49/32 dev mynet-shim

sleep 5

# activate the shim
/sbin/ip link set mynet-shim up

sleep 5

# set route from host to shim to connect the networks
/sbin/ip route add 192.168.0.40/29 dev mynet-shim

sleep 5

echo 
echo "Checking if network was created..."

MATCH=`/sbin/ip link | grep -c "mynet-shim"`

if [ "$MATCH" == "1" ]
then
	echo
	echo "Network created... "
	echo 
	echo "Showing link... "
	
	/sbin/ip link | grep "mynet-shim"
	
	echo 
	echo "Showing address... "
	
	/sbin/ip address show mynet-shim
	
	echo 
	echo "Showing route..."
	
	/sbin/ip route | grep "mynet-shim"

	echo 
	echo 
else
	echo
	echo "Error ... network does not exist..."
fi

exit 