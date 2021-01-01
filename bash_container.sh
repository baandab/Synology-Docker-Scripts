#!/bin/sh

# Name:
# -----
# bash_container.sh
#
#
# Pass this script the name of a container to start a bash shell to it

usage()
{

echo "Usage:		"${0##*/}"	 [ influx | hamachi | grafana | homebridge | <container_name> ]"
	
}

if [ "$1" = "" ]
then
	usage
	exit
fi

container=`echo $1 | cut -f2 -d "_" | sed "s/\.sh//g"`

ID=`/usr/local/bin/docker ps | grep $container | cut -f1 -d" "`

echo "Staring bash session to the $1 container: ($ID)..."
echo
echo /usr/local/bin/docker exec -it --user=root $ID /bin/sh
echo
/usr/local/bin/docker exec -it --user=root $ID /bin/sh