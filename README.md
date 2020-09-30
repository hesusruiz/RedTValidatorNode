# Validator node for Alastria Red T

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/alastria/alastria-node/blob/testnet2/LICENSE)

Docker-based Validator node for Alastria Red T

## Installation & configuration

* Clone or download the repository to the machine where you want to install and operate the Red T node and enter into the cloned directory.

* Edit the file `redtval/data_dir/GETH_ARGUMENTS.txt` and modify the line with NODE_NAME attribute according to the name you want for this node. The name SHOULD follow the convention:

    `VAL_XX_Telsius_Y_Z_NN`

    Where XX is your company/entity name, Y is the number of processors of the machine, Z is the amount of memory in Gb and NN is a sequential counter for each machine that you may have (starting at 00). For example:

    `NODE_NAME="VAL_IN2_Telsius_2_8_00"`

    This is the name that will appear in the public listings of nodes of the network. It does not have any other usage.

* In the root directory of the repository (where the file `docker-compose.yml` exists) run:

```console
$ docker-compose up -d
```

* The command runs the service in the background, and you can check its activity by running:
  
```console
$ docker-compose logs -f --tail=20
```

You should see the node initializing and starting to try to contact peers. However, the node is not yet permissioned, so it can not participate in the blockchain network yet.

In order to perform permissioning, follow these steps:

* Display the contents of the ENODE_ADDRESS file (the actual contents of your file will be different than in the example):

```console
$ cat redtval/data_dir/ENODE_ADDRESS
0ede782b7ce6c7398f100ef33aef6c266972dac19910b5aac1c1eededccd7b4769e7df69e4314927417bbdd9592fc9f583c36274976af29e432b8e64059adc03
```

* Get the IP address of your node, as seen from the external world. Please take into account the considerations described above on routable IPs.

* Create the full enode address as:

    `enode://xxx@external_IP:21000?discport=0`

    Where

    **xxx** is the value of the ENODE_ADDRESS file

    **external_IP** is the external IP of your node

* With that value, create a pull request to request permission. When the pull request is accepted, you will see that your node starts connecting to its peers and starts synchronizing the blockchain. The process of synchronization can take hours or even one or two days depending on the speed of your network and machine.

You can use the standard docker-compose commands to manage your node. For example, to stop the node:

```console
$ docker-compose down
```

To restart the node:

```console
$ docker-compose restart
```


## System requirements

**Operating System**: Can be run anywhere Docker runs.

**Hardware**:

| Hardware | minimum | desired |
|:------- |:-------- |:---------|
| **CPU's**: | 2 |  4 |
| **Memory**: | 8 Gb |  16 Gb |
| **Hard Disk**: | 200 Gb |  1000 Gb |


#### TCP/UDP PORTS

You'll need to open the following ports in your firewall, inbound and outbound to deploy a node:


| Port | Type | Definition |
|:------:|:-----:|:---------- |
|21000| TCP/UDP | Ethereum P2P protocol (inbound and outbound for ethereum traffic) |

#### IP ADDRESSES

The IP resulting out of the installation process (e.g. the IPv4 part of the enode) , must not be an RFC1918 IPv4 address

10.0.0.0/8
172.16.0.0/12
192.168.0.0/16

These IP addresses are non-routable and will result in your node being unreachable and unable to participate in the blockchain.

In case the installation process yields a non-routable IP address, you must verify if your node is behind a firewall, in which case you might use the firewall's external address only in the case the firewall provides for Full-cone NAT. 

Restricted-Cone NAT has not been tested yet for p2p functionality.
