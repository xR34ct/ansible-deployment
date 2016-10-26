#!/bin/bash
set -e 
echo "This script should be run from the samedirectory as ansible root"
echo "Cloning from $1 to $2"
virt-clone --connect=qemu:///system -o "$1" -n "$2" --auto-clone
virsh start "$2"
echo "Started host $2..."
hwaddress=$( virsh domiflist "$2" | grep "bridge" | awk '{ print $5 }' ) 
while true; do
	ipaddress=$(  arp-scan --interface=br0 -l | grep "$hwaddress" | awk '{ print $1 }' )
	if [ -z "$ipaddress" ]; then     
		echo "Scanning for ARP response..."
	else
		echo "Ip: $ipaddress found for host: $hwaddress/$2" 
		break;
	fi
done
echo "Host $2 got MAC: $hwaddress and IP: $ipaddress"
echo "$2	IN	A	$ipaddress" >> /etc/bind/zones/db.sciion.me
service bind9 restart
echo "$ipaddress	 hostname=$2" >> /etc/ansible/hosts
echo "Running ansible provisioning..."
su ansible -c "ansible-playbook ~/ansible/deploy_new_host.yml --limit=$ipaddress --ask-vault-pass"
ping -c 1 "$2" > /dev/null
echo "Deployment successfull!"
exit 0
