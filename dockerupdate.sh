#!/bin/bash

d=`date "+%Y-%m-%d - %H:%M:%S"`
echo "Date: $d"
echo 
echo "Starting docker container updates..."
echo "-----------------------------------"
echo 


TIMEOUT=360
SLEEP=60 


echo "Update containers: docker-compose pull" 
echo 
/usr/local/bin/docker-compose --no-ansi pull
echo "-----------------------------------"
echo "Update complete..."

sleep $SLEEP

echo 
echo "Take down and remove existing containers: docker-compose down" 
echo 
COMPOSE_HTTP_TIMEOUT=$TIMEOUT /usr/local/bin/docker-compose --no-ansi down
echo "-----------------------------------"
echo "Containers removed..."

sleep $SLEEP

echo 
echo "Pruning networks and removing network shim" 
echo 

# remove network shim
/sbin/ip link set mynet-shim down
/sbin/ip link delete mynet-shim 

/usr/local/bin/docker network prune -f
echo "-----------------------------------"
echo "Networks pruned and shim removed..."

sleep $SLEEP

echo 
echo "Creating macvlan1 and network shim" 
echo 

#create network shim - see https://blog.oddbit.com/post/2018-03-12-using-docker-macvlan-networks/
#
# this creates a subnet (192.168.0.40 to 192.168.0.48) that we can connect to via 192.168.0.49
#
# 192.168.0.24 is the IP address Synology host
# 192.168.0.49/32 is one address: 192.168.0.49
# 192.168.0.40/29 is a range 192.168.0.40 to 192.168.0.48
# 192.168.0.0/24 is a range 192.168.0.40 to 192.168.0.255. 
#  
# change eth0 to ovs_eth0 if you have Synology Virtual Machine manager installed - thanks aurrak!

/usr/local/bin/docker network create -d macvlan -o parent=eth0 \
  --subnet 192.168.0.0/24 \
  --gateway 192.168.0.1 \
  --ip-range 192.168.0.40/29 \
  --aux-address 'host=192.168.0.49' \
  macvlan1
  
# create shim 
/sbin/ip link add mynet-shim link eth0 type macvlan  mode bridge

# add host to shim
/sbin/ip address add 192.168.0.49/32 dev mynet-shim

# activate the shim
/sbin/ip link set mynet-shim up

# set route from host to shim to connect the networks
/sbin/ip route add 192.168.0.40/29 dev mynet-shim
  

echo
echo  

echo "-----------------------------------"
echo "macvlan1 and network shim created..."
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

sleep $SLEEP

echo 
echo "Bring the containers back up: docker-compose up -d" 
echo 
COMPOSE_HTTP_TIMEOUT=$TIMEOUT /usr/local/bin/docker-compose --no-ansi up -d
echo "-----------------------------------"
echo "Containers started..."
echo 

sleep $SLEEP

echo "Pruning images: docker system prune -f -a"

/usr/local/bin/docker system prune -f -a

echo "-----------------------------------"
echo "Images pruned..."
