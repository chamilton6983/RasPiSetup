#!/bin/bash

#Updates
echo "Updating and Upgrading"
sudo apt-get update
sudo apt-get upgrade

#Change root password
echo "Changing the root password"
sudo passwd root

#Switch to root
echo "Switching to root account"
sudo su

#Change Hostname
echo "Changing hostname"
read -p "Enter New Hostname: " hostname	#Ask the user for the new hostname
sudo sed -i "s/raspberrypi/$hostname/g" /etc/hostname	#Replaces the hostname in the /etc/hostname file
sudo sed -i "s/raspberrypi/$hostname/g" /etc/hosts	#Replaces the hostname in the /etc/hosts file

#New Username
echo "adding new user"
read -p "Enter New Username: " username	#Ask the user for the new username
sudo adduser $username	#Create the new user
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi $username	#Add the new user to the required groups
sudo echo -e "$username ALL=(ALL) PASSWD: ALL" >> /etc/sudoers.d/010_pi-nopasswd	#Appends the new user to the end of the nopasswd list and requires the password to be entered for sudo activities
sudo echo -e "AllowUsers $username" >> /etc/ssh/sshd_config	#Append the new user to the end of the sshd_config file to allow sshd connections
sudo systemctl restart ssh	#restart ssh to pick previous line

#Harden the pi account
echo "pi account hardening"
sudo passwd	#Change the pi user account password
sudo passwd pi -l	#Disable the pi account

#Hardening
echo "Other hardening actions"
sudo sed -i 's/NOPASSWD/PASSWD/g' /etc/sudoers.d/010_pi-nopasswd	#Ensure all accounts need to enter their password when carrying out sudo