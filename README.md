# ps-oracle

Extend the standard Oracle Docker image to include pre-creating the Database inside the image. Details for the standard image can be found here [Oracle Database Docker Image](https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance).

It is expected that a local version of the Docker image named `oracle/database:18.4.0-xe` has already been created, following the instructions in the link above.

The purpose of this project is to reduce the time it takes to start up an Oracle container which can be used for testing.  This is done by executing the base `runOracle.sh` script during image creation and adding a new `entrypoint.sh` script to create the users/schemas during startup.

Dockerfile.xe
```

# Builds Oracle DB inside of this image
RUN $ORACLE_BASE/runOracle.sh

# Starts Oracle DB and creates users based on environment variables
CMD $ORACLE_BASE/entrypoint.sh
```

This image is built by executing the following command `./buildDockerImage.sh`

The database can be started using the included `docker-compose.yml` file which can be customized for your needs. Below is a description of the available environment variables.
1. ORACLE_USER - a comma-separated list of users to be created. These users will have access to do most database functions across all schemas.
1. ORACLE_USER_PASSWORD - a comma-separated list of passwords, positionally matched to the users. Defaults to the user names.
1. ORACLE_SCHEMAS - a comma-separated list of schemas to be created without login capability and only TABLESPACE access granted.
1. ORACLE_PWD - The password used for the SYS and SYSTEM users when the image was created. (Currently hardcoded in the Dockerfile.xe)


NOTE: This Docker build/image should not be used other than for testing purposes as the system password is included in this project and built into the image and users may be granted more privileges that would be valid in a real-world scenario.