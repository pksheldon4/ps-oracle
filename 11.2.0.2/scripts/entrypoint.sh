#!/bin/bash

########### SIGTERM handler ############
function _term() {
   echo "Stopping container."
   echo "SIGTERM received, shutting down database!"
   sqlplus / as sysdba <<EOF
   shutdown immediate;
EOF
   lsnrctl stop
}

########### SIGKILL handler ############
function _kill() {
   echo "SIGKILL received, shutting down database!"
   sqlplus / as sysdba <<EOF
   shutdown abort;
EOF
   lsnrctl stop
}
############# Create User ################
function createUser {
  echo "############# Create User(s) #############"
  echo $ORACLE_USER
  if [ "$ORACLE_USER_PASSWORD" == "" ]; then
     ORACLE_USER_PASSWORD=$ORACLE_USER
  fi;

  OLDIFS=$IFS
  IFS=','
  read -ra users <<< "$ORACLE_USER"
  read -ra passwords <<< "$ORACLE_USER_PASSWORD"
  for((i=0; i< ${#users[@]};++i));
  do
   echo "### Granting access to user ["${users[i]}"] as ["${passwords[i]}"]"
   # Evaluate the correct grants
   sqlplus sys/$ORACLE_PWD@//localhost:1521/XE as sysdba <<EOF
   GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE TO ${users[i]} IDENTIFIED BY ${passwords[i]};
EOF

  done
  IFS=$OLDIFS

  echo "### connect as user ["${users[0]}"]"
  sqlplus ${users[0]}/${passwords[0]}@//localhost:1521/XE <<EOF
EOF

}

############# Start DB ################
function startDB {
   echo "############# Start DB ################"
   /etc/init.d/oracle-xe start | grep -qc "Oracle Database 11g Express Edition is not configured"
}

############# MAIN ################
echo "########################################"
# Set SIGTERM handler
trap _term SIGTERM

# Set SIGKILL handler
trap _kill SIGKILL

# Default for ORACLE PDB
if [ "$ORACLE_PDB" == "" ]; then
   export ORACLE_PDB=XE
fi;

# Check whether database already exists
startDB;
if [ "$ORACLE_USER" != "" ]; then
  createUser;
fi;

# Execute custom provided startup scripts
$ORACLE_BASE/$USER_SCRIPTS_FILE $ORACLE_BASE/scripts/sql/

echo "#############################"
echo "DB STARTED AND READY TO USE!"
echo "#############################"
echo "TEST: " $TEST
if ["$TEST" == ""]; then
  tail -f $ORACLE_BASE/diag/rdbms/*/*/trace/alert*.log &
  childPID=$!
  wait $childPID
fi;
