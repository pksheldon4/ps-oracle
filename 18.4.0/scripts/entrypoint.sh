#!/bin/bash
########### SIGTERM handler ############
function _term() {
   echo "Stopping container."
   echo "SIGTERM received, shutting down database!"
   sqlplus / as sysdba <<EOF
   shutdown immediate;
EOF
/etc/init.d/oracle-xe-18c stop
}

########### SIGKILL handler ############
function _kill() {
   echo "SIGKILL received, shutting down database!"
   sqlplus / as sysdba <<EOF
   shutdown abort;
EOF
  /etc/init.d/oracle-xe-18c stop 
}
############# Create User ################
function createUser {
  echo "############# Create User(s) #############"
  echo $ORACLE_USER
  if [ "$ORACLE_USER_PASSWORD" == "" ]; then
     ORACLE_USER_PASSWORD=$ORACLE_USER
  fi;

  OLDIFS=$IFS
  IFS=',':

## Schemas are oracle users with no login permissions.
  read -ra schemas <<< "$ORACLE_SCHEMAS"
  for((i=0; i< ${#schemas[@]};++i));
  do
   echo "#### Creating schema ["${schemas[i]}"]"
   sqlplus sys/$ORACLE_PWD@//localhost:1521/$ORACLE_PDB as sysdba <<EOF
   create user ${schemas[i]} no authentication;
   GRANT UNLIMITED TABLESPACE TO ${schemas[i]};
EOF
  done

  read -ra users <<< "$ORACLE_USER"
  read -ra passwords <<< "$ORACLE_USER_PASSWORD"
  for((i=0; i< ${#users[@]};++i));
  do
   echo "### Granting access to user ["${users[i]}"] as ["${passwords[i]}"]"
   # Evaluate the correct grants
   sqlplus sys/$ORACLE_PWD@//localhost:1521/$ORACLE_PDB as sysdba <<EOF
   GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE TO ${users[i]} IDENTIFIED BY ${passwords[i]};
   GRANT CREATE SESSION TO ${users[i]};
   GRANT CREATE ANY TABLE TO ${users[i]};
   GRANT ALTER ANY TABLE TO ${users[i]};
   GRANT DROP ANY TABLE TO ${users[i]};
   GRANT SELECT ANY TABLE TO ${users[i]};
   GRANT INSERT ANY TABLE TO ${users[i]};
   GRANT UPDATE ANY TABLE TO ${users[i]};
   GRANT DELETE ANY TABLE TO ${users[i]};
   GRANT CREATE ANY INDEX TO ${users[i]};
   GRANT COMMENT ANY TABLE TO ${users[i]};
   GRANT EXECUTE ANY PROCEDURE TO ${users[i]};
   GRANT CREATE TRIGGER TO ${users[i]};
EOF

  done
  IFS=$OLDIFS

  echo "### connect as user ["${users[0]}"]"
  sqlplus ${users[0]}/${passwords[0]}@//localhost:1521/$ORACLE_PDB <<EOF
EOF

}

############# Start DB ################
function startDB {
   echo "############# Start DB ################"
   /etc/init.d/oracle-xe-18c start | grep -qc "Oracle Database is not configured"
   sqlplus / as sysdba <<EOF
EOF
}

############# MAIN ################
echo "########################################"
# Set SIGTERM handler
trap _term SIGTERM

# Set SIGKILL handler
trap _kill SIGKILL

# Default for ORACLE PDB
if [ "$ORACLE_PDB" == "" ]; then
   export ORACLE_PDB=XEPDB1
fi;

# Check whether database already exists
startDB;
if [ "$ORACLE_USER" != "" ]; then
  createUser;
fi;

# Execute custom provided startup scripts
#$ORACLE_BASE/$USER_SCRIPTS_FILE $ORACLE_BASE/scripts/sql/

echo "#############################"
echo "DB STARTED AND READY TO USE!"
echo "#############################"

env 
echo "############################"

echo "TEST: " $TEST
if ["$TEST" == ""]; then
  tail -f $ORACLE_BASE/diag/rdbms/*/*/trace/alert*.log &
  childPID=$!
  wait $childPID
fi;
