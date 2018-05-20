# Pull base image
# ---------------
FROM oracle/database:12.2.0.1-ee

# Maintainer
# ----------
MAINTAINER Preston Sheldon <psheldon@pivotal.io>

ENV ORACLE_PWD=4dminPass

COPY scripts/*.sh $ORACLE_BASE/
COPY sql/* $ORACLE_BASE/scripts/sql/

# Builds Oracle DB inside of this image
RUN $ORACLE_BASE/runOracle.sh

# Starts Oracle DB and creates users based on environment variables
CMD $ORACLE_BASE/entrypoint.sh
