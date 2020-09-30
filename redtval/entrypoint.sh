#!/bin/bash

# This is the main entrypoint to the docker container for a
# VALIDATOR node

set -e

# USE the trap if you need to also do manual cleanup after the service is stopped,
#     or need to start multiple services in the one container
trap "echo TRAPed signal" HUP INT QUIT TERM

if [ "$1" = 'start' ]; then
    
    echo "Starting the node"
    # Create the data/geth directory if it does not exist yet
    mkdir -p /root/alastria/data/geth

    # Make sure we are in /root
    cd /root

    # Update the list of permissioned nodes (validator + boot) every time that we start
    wget -q -O boot-nodes.json https://raw.githubusercontent.com/alastria/alastria-node/testnet2/data/boot-nodes.json
    wget -q -O validator-nodes.json https://raw.githubusercontent.com/alastria/alastria-node/testnet2/data/validator-nodes.json

    # Create the JSON files with the permissioned nodes from the Alastria Git repository
    echo "[" > temporal.json
    cat /root/boot-nodes.json >> temporal.json
    cat /root/validator-nodes.json >> temporal.json
    sed '$ s/,//' temporal.json > /root/alastria/data/static-nodes.json
    echo "]" >> /root/alastria/data/static-nodes.json
    cp /root/alastria/data/static-nodes.json /root/alastria/data/permissioned-nodes.json
    rm -f temporal.json

    # Generate the nodekey and enode_address if it is not already generated
    if [ ! -e /root/alastria/data/ENODE_ADDRESS ]
    then

	echo "Generating nodekey and ENODE_ADDRESS"
        ls -l /root/alastria/data/
        # Create the nodekey in the /root/alastria/data/geth directory
        cd /root/alastria/data/geth
        bootnode -genkey nodekey

        # Get the enode key and write it in a local file for later starts of the docker
        ENODE_ADDRESS=$(bootnode -nodekey nodekey -writeaddress)
        echo $ENODE_ADDRESS > /root/alastria/data/ENODE_ADDRESS

        # Go back to /root
        cd /root

        echo "INFO [00-00|00:00:00.000|entrypoint.sh:46] ENODE_ADDRESS generated."

    fi


    # Perform one-time initialization if not already
    if [ ! -e /root/alastria/data/INITIALIZED ]
    then

	echo "Generating genesis.json and initialize blockchain structure"

        # Download the genesis block from the Alastria node repository
        wget -q -O genesis.json https://raw.githubusercontent.com/alastria/alastria-node/testnet2/data/genesis.json
        echo "INFO [00-00|00:00:00.000|entrypoint.sh:57] Genesis block downloaded."

        # Initialize the Blockchain structure
        echo "INFO [00-00|00:00:00.000|entrypoint.sh:60] Initialize the Blockchain with the genesis block"
        geth --datadir /root/alastria/data init /root/genesis.json

        # Signal that the initialization process has been performed
        # Write the file INITIALIZED in the /root directory
        cd /root
        echo "INITIALIZED" > /root/alastria/data/INITIALIZED

    fi

    # Set the arguments to start geth
    cd /root

    # Set the environment variables for the geth arguments from a file
    source /root/alastria/data/GETH_ARGUMENTS.txt

    GLOBAL_ARGS="--networkid $NETID \
--identity $NODE_NAME \
--permissioned \
--cache $CACHE \
$ENABLE_RPC \
--rpcaddr $RPCADDR \
--rpcapi $RPCAPI \
--rpcport $RPCPORT \
--port $P2P_PORT \
--istanbul.requesttimeout $ISTANBUL_REQUESTTIMEOUT \
--ethstats $NODE_NAME:$NETSTATS_TARGET \
--verbosity $VERBOSITY \
--emitcheckpoints \
--targetgaslimit $TARGETGASLIMIT \
--syncmode $SYNCMODE \
--gcmode $GCMODE \
--vmodule $VMODULE  "

    # Start the geth node
    export PRIVATE_CONFIG="ignore"
    echo "INFO [00-00|00:00:00.000|entrypoint.sh:101] Start geth --datadir /root/alastria/data $GLOBAL_ARGS $ADDITIONAL_ARGS"
    exec geth --datadir /root/alastria/data $GLOBAL_ARGS $ADDITIONAL_ARGS

fi

exec "$@"

