#!/bin/bash

# To run this script, use the following command at a terminal prompt:
# sudo wget -O - https://raw.githubusercontent.com/chamilton6983/RasPiSetup/master/RasPiSetup.sh | bash

#Updates
echo "Updating and Upgrading"
apt-get update
apt-get upgrade

#Change root password
echo "Changing the root password"
passwd root

#Change Hostname
echo "Changing hostname"
read -p "Enter New Hostname: " hostname	#Ask the user for the new hostname
sed -i "s/raspberrypi/$hostname/g" /etc/hostname	#Replaces the hostname in the /etc/hostname file
sed -i "s/raspberrypi/$hostname/g" /etc/hosts	#Replaces the hostname in the /etc/hosts file

#New Username
echo "adding new user"
read -p "Enter New Username: " username	#Ask the user for the new username
adduser $username	#Create the new user
usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi $username	#Add the new user to the required groups
echo -e "$username ALL=(ALL) PASSWD: ALL" >> /etc/sudoers.d/010_pi-nopasswd	#Appends the new user to the end of the nopasswd list and requires the password to be entered for sudo activities
echo -e "AllowUsers $username" >> /etc/ssh/sshd_config	#Append the new user to the end of the sshd_config file to allow sshd connections
systemctl restart ssh	#restart ssh to pick previous line

#Harden the pi account
echo "pi account hardening"
passwd	#Change the pi user account password
passwd pi -l	#Disable the pi account

#Hardening
echo "Other hardening actions"
sed -i 's/NOPASSWD/PASSWD/g' /etc/sudoers.d/010_pi-nopasswd	#Ensure all accounts need to enter their password when carrying out sudo