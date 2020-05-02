#!/bin/bash

# To run this script, use the following command at a terminal prompt:
# sudo wget -O - https://raw.githubusercontent.com/chamilton6983/RasPiSetup/master/RasPiSetup.sh | bash

#Updates
#echo "-----Updating and Upgrading-----"
#apt-get update
#apt-get upgrade

#Change Hostname
echo "-----Changing Hostname-----"
read -p "Enter new Hostname: " hostname	#Ask the user for the new hostname
sed -i "s/raspberrypi/$hostname/g" /etc/hostname	#Replaces the hostname in the /etc/hostname file
sed -i "s/raspberrypi/$hostname/g" /etc/hosts	#Replaces the hostname in the /etc/hosts file

#New Username
echo "-----Adding new admin account-----"
read -p "Enter username : " username
read -s -p "Enter password : " password
egrep "^$username" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
	echo "$username exists!"
	exit 1
else
	pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
	useradd -m -p "$pass" "$username"
	[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
fi
usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi $username	#Add the new user to the required groups
echo -e "$username ALL=(ALL) PASSWD: ALL" >> /etc/sudoers.d/010_pi-nopasswd	#Appends the new user to the end of the nopasswd list and requires the password to be entered for sudo activities
echo -e "AllowUsers $username" >> /etc/ssh/sshd_config	#Append the new user to the end of the sshd_config file to allow sshd connections
systemctl restart ssh	#restart ssh to pick previous line

#Harden the pi account
echo "-----Hardening pi account-----"
read -p "Enter new password for pi" pipassword
echo -e "pi:$pipassword" | chpasswd	#use the chpasswd util to change to pi user password
passwd pi -l	#Disable the pi account

#Change root password
echo "-----Hardening root account-----"
read -p "Enter new password for root" rootpassword
echo -e "root:$rootpassword" | chpasswd	#use the chpasswd util to change to root user password

#Hardening
echo "-----Other hardening actions-----"
sed -i 's/NOPASSWD/PASSWD/g' /etc/sudoers.d/010_pi-nopasswd	#Ensure all accounts need to enter their password when carrying out sudo