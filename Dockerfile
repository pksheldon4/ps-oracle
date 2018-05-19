# Pull base image
# ---------------
FROM oracle/database:12.2.0.1-ee

# Maintainer
# ----------
MAINTAINER Preston Sheldon <psheldon@pivotal.io>

ENV ORACLE_PWD=4dminPass

COPY scripts/* $ORACLE_BASE/

RUN $ORACLE_BASE/runOracle.sh

CMD $ORACLE_BASE/entrypoint.sh
