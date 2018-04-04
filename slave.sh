#!/bin/bash

## SLAVE ##

# Variaveis Slave
SLAVELAN="192.168.100.20" #EM0
SLAVEFW="10.10.10.2"	 #EM1
SLAVEWAN="192.168.254.202" #EM2
# Variaveis Compartilhado
SHAREDLAN="192.168.100.100"
SHAREDLANBC="192.168.100.255"
SHAREDWAN="192.168.254.250"
SHAREDWANBC="192.168.254.255"
DEFAULTGW="192.168.254.2"

#Cria arquivos hostname
touch /etc/hostname.em0
touch /etc/hostname.em1
touch /etc/hostname.em2
touch /etc/hostname.pfsync0
touch /etc/hostname.carp1
touch /etc/hostname.carp2
touch /etc/sysctl.conf
#Cria arquivo para default gw
touch /etc/mygate
echo $DEFAULTGW > /etc/mygate

##Permite o redirecionamento de pacotes IP
sysctl -w net.inet.ip.forwarding=1
echo "net.inet.ip.forwarding=1" >> /etc/sysctl.conf
## Habilitar o protocolo CARP
sysctl -w net.inet.carp.allow=1
echo "net.inet.carp.allow=1" >> /etc/sysctl.conf
## Habilitar o preemption e o grupo de interface failover
echo "net.inet.carp.preempt=1" >> /etc/sysctl.conf
sysctl -w net.inet.carp.preempt=1

## Configuracao LAN MASTER
ifconfig em0 $SLAVELAN netmask 255.255.255.0
#Adiciona configuracoes no boot
echo "inet $SLAVELAN 255.255.255.0 NONE" > /etc/hostname.em0

## Configuracao WAN SLAVE
ifconfig em2 $SLAVEWAN net mask 255.255.255.0
echo "inet $SLAVEWAN 255.255.255.0 NONE" > /etc/hostname.em2

## Configuracao PFSYNC
ifconfig em1 $SLAVEFW netmask 255.255.255.0
echo "inet $SLAVEFW 255.255.255.0 NONE" > /etc/hostname.em1
ifconfig pfsync0 syncdev em1
ifconfig pfsync0 up
echo "up syncdev em1" > /etc/hostname.pfsync0

## Configuracao CARP LAN
ifconfig carp1 create
ifconfig carp1 vhid 1 carpdev em0 pass senhalan advskew 200 state backup $SHAREDLAN 255.255.255.0
echo "inet $SHAREDLAN 255.255.255.0 $SHAREDLANBC vhid 1 carpdev em0 pass senhalan advskew 200 state backup" > /etc/hostname.carp1

## Configuracao CARP WAN
ifconfig carp2 create
ifconfig carp2 vhid 2 carpdev em2 pass senhawan advskew 200 state backup $SHAREDWAN 255.255.255.0
echo "inet $SHAREDWAN 255.255.255.0 $SHAREDWANBC vhid 2 carpdev em2 pass senhawan advskew 200 state backup" > /etc/hostname.carp2

#Liga todas interfaces
ifconfig em0 up
ifconfig em1 up
ifconfig em2 up

sh /etc/netstart

