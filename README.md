# Payara
Payara project for docker

## First time configuration

To configure the container you can add:
```
	drivers to the `driver/` folder
	ear/war files to the `apps/` folder (for autodeply)
```
Download the payara version from the [Payara website](http://www.payara.fish/all_downloads)
and store the zip-file in the folder where the Dockerfile is located 
(version used: payara-4.1.1.164.zip). Change the Dockerfile when 
a different version of Payara is used. Also check the init.sh if it is not version 4.1.x.

The `payara_config.sh` will ask for credentials for a mysql connection. 

If you don't want to use autodeploy, you can login to the admin console on port 4848 and
deploy the applications manually (https://payara:4848/).




