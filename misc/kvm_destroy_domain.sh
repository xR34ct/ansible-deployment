#!/bin/bash
echo "Destroying host $1..."
virsh destroy "$1"
virsh undefine "$1"
rm -f "/var/lib/libvirt/images/$1.qcow2"
hosts=$( cat /etc/ansible/hosts | grep -v "$1" )
#dns=$( cat /etc/bind/zones/db.sciion.me | grep -v "$1" )
#echo "$dns" > /etc/bind/zones/db.sciion.me
echo "$hosts" > /etc/ansible/hosts
#service bind9 restart
