#!/bin/bash


#### Configuracoes MASTER ####
# Variaveis Master
MASTERLAN="192.168.100.10"  # EM0
MASTERFW="10.10.10.1"	    # EM1
MASTERWAN="192.168.254.201" # EM2
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
ifconfig em0 $MASTERLAN netmask 255.255.255.0
#Adiciona configuracoes no boot
echo "inet $MASTERLAN 255.255.255.0 NONE" > /etc/hostname.em0

## Configuracao WAN MASTER
ifconfig em2 $MASTERWAN net mask 255.255.255.0
echo "inet $MASTERWAN 255.255.255.0 NONE" > /etc/hostname.em2

## Configuracao PFSYNC
ifconfig em1 $MASTERFW netmask 255.255.255.0
echo "inet $MASTERFW 255.255.255.0 NONE" > /etc/hostname.em1
ifconfig pfsync0 syncdev em1
ifconfig pfsync0 up
echo "up syncdev em1" > /etc/hostname.pfsync0

## Configuracao CARP LAN
ifconfig carp1 create
ifconfig carp1 vhid 1 carpdev em0 pass senhalan advskew 100 state master $SHAREDLAN 255.255.255.0
echo "inet $SHAREDLAN 255.255.255.0 $SHAREDLANBC vhid 1 carpdev em0 pass senhalan advskew 100 state master" > /etc/hostname.carp1

## Configuracao CARP WAN
ifconfig carp2 create
ifconfig carp2 vhid 2 carpdev em2 pass senhawan advskew 100 state master $SHAREDWAN 255.255.255.0
echo "inet $SHAREDWAN 255.255.255.0 $SHAREDWANBC vhid 2 carpdev em2 pass senhawan adskew 100 state master" > /etc/hostname.carp2

#Liga todas interfaces
ifconfig em0 up
ifconfig em1 up
ifconfig em2 up

sh /etc/netstart

