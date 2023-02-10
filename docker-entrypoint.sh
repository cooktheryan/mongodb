#!/bin/bash

# This is the entrypoint for the docker container
# this will initialize mongo and start the server
# and keep it running

set -e

# Set default arguments
: ${MONGO_DATA_DIR:=/data/db}

# Check for the expected command
if [ -z "$(ls -A ${MONGO_DATA_DIR})" ]; then
	echo "=> An empty or uninitialized MongoDB volume is detected in $MONGO_DATA_DIR"
	echo "=> Installing MongoDB ..."
	"$MONGO_HOME/bin/mongod" --quiet --dbpath "$MONGO_DATA_DIR" --logpath /dev/null --bind_ip_all --fork
	# Create the database pacman using a javascript file
	echo "=> Creating pacman database ..."
	mongosh --host localhost:27017 --authenticationDatabase admin --norc --file /usr/local/bin/create_pacman_db.js
	echo "=> Done!"
else
	echo "=> Using an existing volume of MongoDB"
fi

# Start MongoDB
echo "=> Starting MongoDB ..."
exec "$MONGO_HOME/bin/mongod" --quiet --dbpath "$MONGO_DATA_DIR" --logpath /dev/null --bind_ip_all $CMDARG

exec "$@"
