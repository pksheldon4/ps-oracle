# ps-oracle

Extend the standard Oracle Docker image to include pre-creating the Database inside the Image. Details for the standard image can be found here [Oracle Database Docker Image](https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance).

The Oracle image allows the user to create a Docker Image using various versions of Oracle, this project expects to find a local version of the Docker Image named ```oracle/database:12.2.0.1-ee```

This is done by executing the following command ```./buildDockerImage.sh -v 12.2.0.1 -e -i```

Before using this project, it is necessary to follow the Oracle instructions to create the above image with one modification.

The following line must be commented out in ```Dockerfile.ee```
```
#VOLUME ["$ORACLE_BASE/oradata"]
```
My fork, including this change, can be found [here](https://github.com/pksheldon4/oracle-docker-images/tree/master/OracleDatabase/SingleInstance).

The purpose of this Docker image is to have the Database fully contained in the image so the VOLUME isn't necessary.
