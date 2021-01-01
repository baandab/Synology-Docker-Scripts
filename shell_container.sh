#!/bin/sh

# Name:
# ----- 
# shell_container.sh
#
#
# Pass this script the name of a container to start a shell to it

usage()
{

echo "Usage:		"${0##*/}" [ influx | hamachi | grafana | homebridge | <container_name> ].  [zsh | sh | shell | <shell>"

	examples:
	
		./shell_container.sh grafana   			# to start a sh shell
		./shell_container.sh grafana zsh  		# to start a zsh shell
		./shell_container.sh grafana shell  	# to start a shell shell
	
}

if [ "$1" = "" ]
then
	usage
	exit
fi

if [ "$2" = "" ]
then
	SHELL="sh"
else
	SHELL=$2
fi
container=`echo $1 | cut -f2 -d "_" | sed "s/\.sh//g"`

ID=`/usr/local/bin/docker ps | grep $container | cut -f1 -d" "`

echo "Staring $SHELL session to the $1 container: ($ID)..."
echo
echo /usr/local/bin/docker exec -it --user=root $ID /bin/$SHELL
echo
/usr/local/bin/docker exec -it --user=root $ID /bin/$SHELL