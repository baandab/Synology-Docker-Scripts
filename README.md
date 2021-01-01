# Synology Docker Scripts
 Various Docker Scripts for Synology
 
## dockerupdate.sh
 
Used to update docker containers.  Run this via Task Scheduler on the cadence you prefer (weekly, monthly, etc).  Requires a docker-compose.yml in the same directory.  Update this script to change network parameters. 

		bash /volume1/bin/dockerupdate.sh
 
 
## docker-compose.yml
 
This compose will create container for Grafana, Influxdb, and HomeBridge.   Update the ENV variables for your setup.
 

## start_docker_shim.sh
 
This will startup the network shim when the Synology reboots.  Run this via Task Schedule as a "triggered" user-defined script to run at "Boot-up".  Update this script to change network parameters. 
 
 
		bash /volume1/bin/start_docker_shim.sh
		
		
## bash_container.sh

Pass this script the name of a container to start a bash shell to it:

		./bash_container.sh grafana
		./bash_container.sh influx
		./bash_container.sh homebridge
