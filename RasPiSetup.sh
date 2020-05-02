#!/bin/bash

# To run this script, use the following command at a terminal prompt:
# sudo wget - https://raw.githubusercontent.com/chamilton6983/RasPiSetup/master/RasPiSetup.sh | bash

#Updates
sudo echo "-----Updating and Upgrading-----"
sudo apt-get update
sudo apt-get upgrade

#Change Hostname
sudo echo "-----Changing Hostname-----"
sudo read -p "Enter new Hostname: " hostname	#Ask the user for the new hostname
sudo sed -i "s/raspberrypi/$hostname/g" /etc/hostname	#Replaces the hostname in the /etc/hostname file
sudo sed -i "s/raspberrypi/$hostname/g" /etc/hosts	#Replaces the hostname in the /etc/hosts file

#New admin account
sudo echo "-----Adding new admin account-----"
sudo read -p "Enter username : " username
sudo read -s -p "Enter password : " password
sudo egrep "^$username" /etc/passwd >/dev/null
sudo if [ $? -eq 0 ]; then
	sudo echo "$username exists!"
	sudo exit 1
sudo else
	sudo pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
	sudo useradd -m -p "$pass" "$username"
	sudo [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
sudo fi
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi $username	#Add the new user to the required groups
sudo echo -e "$username ALL=(ALL) PASSWD: ALL" >> /etc/sudoers.d/010_pi-nopasswd	#Appends the new user to the end of the nopasswd list and requires the password to be entered for sudo activities
sudo echo -e "AllowUsers $username" >> /etc/ssh/sshd_config	#Append the new user to the end of the sshd_config file to allow sshd connections
sudo systemctl restart ssh	#restart ssh to pick previous line

#Harden the pi account
sudo echo "-----Hardening pi account-----"
sudo read -p "Enter new password for pi" pipassword
sudo echo -e "pi:$pipassword" | chpasswd	#use the chpasswd util to change to pi user password
sudo passwd pi -l	#Disable the pi account

#Change root password
sudo echo "-----Hardening root account-----"
sudo read -p "Enter new password for root" rootpassword
sudo echo -e "root:$rootpassword" | chpasswd	#use the chpasswd util to change to root user password

#Hardening
sudo echo "-----Other hardening actions-----"
sudo sed -i 's/NOPASSWD/PASSWD/g' /etc/sudoers.d/010_pi-nopasswd	#Ensure all accounts need to enter their password when carrying out sudo

#Application Installation
sudo echo "-----Installing applications-----"
sudo apt-get install cockpit