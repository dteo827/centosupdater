#!/bin/bash

# CentOS Configuration and Updater version 1.0
# I freaking hate Centos 'nuff said
# This script is intended for use in CentOS Linux Installations
# Thanks to Pashapasta for the script template, check out the Kali version at https://github.com/PashaPasta/KaliUpdater/blob/master/KaliConfigAndUpdate.sh
# Please contact dteo827@gmail.com with bugs or feature requests

printf "

#############################
# CentOS Security & Updates #
#############################

#################################
#This script MUST be run as root#
#################################

##############################################################
# Welcome, you will be presented with a few questions, please#
#          answer [y/n] according to your needs.             #
##############################################################\n\n"



#initialize bastille & fail2ban as not installed
bastilleinstalled = n
fail2baninstalled = n

# Questions function
function questions() {
read -p "Do you want to add Google's and Level3's Public DNS to the resolv.conf file? [y/n]" answerGoogleDNS
read -p "Do you want to turn off root login, Ipv6, keep boot as read only,and ignore ICMP broadcast requests and prevent XSS attacks? [y/n]" answerWegettinghard
read -p "Do you want to install updates to CentOS Linux now? [y/n] " answerUpdate
read -p "Do you want to install Bastille [y/n]" answerBastille
read -p "Do you want to install Fail2ban [y/n]" answerFail2ban
read -p "Do you want to install Curl [y/n]" answerCurl
read -p "Do you want to setup OpenVAS? IF THIS IS A SERVER INSTALL SELECT NO!!! (Note: You will be prompted to enter a password for the OpenVAS admin user, this process may take up to an hour) [y/n] " answerOpenVAS
read -p "Do you want to update Nikto's definitions? [y/n] " answerNikto
read -p "Do you want to install PHP5? [y/n] " answerPhp
read -p "Do you want to install Mysql? [y/n]" answerMysql
read -p "Do you want to download (not install) Leopard Flower [y/n]" answerLeopardFlower
}

# Flags!!!!
# If script run with -a flag, all options will automatically default to yes
# IF script run with -h flag, README.md will be displayed
# If script run with -s flag, only items that should be used on a server install will be set to yes

if [[ $1 = -a ]] ; then

read -p "Are you sure you want to install all packages and configure everything by default? [y/n] " answerWarning
if [[ $answerWarning = y ]] ; then
answerGoogleDNS=y
answerWegettinghard=y
answerUpdate=y
answerBastille=y
answerFail2ban=y
answerOpenVAS=y
answerCurl=y
answerNikto=y
answerPhp=y
answerMysql=y
answerLeopardFlower=y
else
printf "Verify would you do and do not want done...."
sleep 2
questions
fi

elif [[ $1 = -s ]] ; then

answerGoogleDNS=y
answerWegettinghard=y
answerUpdate=y
answerBastille=y
answerFail2ban=y
answerCurl=y
answerPhp=y
answerMysql=y
answerLeopardFlower=y

elif [[ $1 = -h ]] ; then

cat README.md
exit
else

questions
fi

# Logic for update and configuration steps

if [[ $answerGoogleDNS = y ]] ; then

echo nameserver 8.8.8.8 >> /etc/resolv.conf
echo nameserver 8.8.4.4 >> /etc/resolv.conf
echo nameserver 4.2.2.2 >> /etc/resolv.conf
fi

if [[ $answerWegettinghard = y]] ; then
echo  1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
sed -i 's/.*PermitRootLogin.*yes/PermitRootLogin no/g' /etc/ssh/sshd_config
yum erase xinetd inetd tftp-server ypserv telnet-server rsh-server
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.all.disable_ipv6=1
fi

if [[ $answerUpdate = y ]] ; then

printf "Updating CentOS, this stage may take about an hour to complete...Hope you have some time to burn...
"
su -c 'yum update'
yum install sudo perl ntp crontabs sendmail mlocate wget -y
wget http://fedora.mirror.nexicom.net/epe1/6/i386/epel-release-6-7.noarch.rpm
yum install epel-release-6-7.noarch.rpm
yum repolist

fi

if [[ $answerBastille = y ]] ; then
http://www.cipherdyne.com/psad/download/psad-2.2.3-1.x86_64.rpm
rpm -Uvh psad-2.2.3-1.x86_64.rpm
rpm -ivh Bastille-3.2.1-0.1.noarch.rpm
rpm -ivh perl-Tk-a.b-c.i386.rpm
bastille -c
bastilleinstalled = y
fi

if [[ $answerFail2ban = y ]] ; then
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum install fail2ban
fail2baninstalled = y
fi

if [[ $answerOpenVAS = y ]] ; then
wget -q -O - http://www.atomicorp.com/installers/atomic |sh
yum upgrade
yum install openvas
openvas-setup
fi

if [[ $answerCurl = y ]] ; then
yum install php-common
yum install php-curl
fi

if [[ $answerNikto = y]] ; then
#wget https://www.cirt.net/nikto/nikto-2.1.5.tar.bz2
#tar -zxvf nikto-2.1.5.tar.bz2
#chmod +x /nikto-2.1.5/nikto.pl
wget http://www6.atomicorp.com/channels/atomic/centos/6/i386/RPMS/atomic-release-1.0-18.el6.art.noarch.rpm
rpm -Uvh atomic-release-1.0-18.el6.art.noarch.rpm
yum install nikto
"
fi

if [[ $answerPhp = y]] ; then
yum install php
sed -i 's/memory_limit = 16M/memory_limit = 8M' /etc/php5/apache/php.ini
fi

if [[ $answerLeopardFlower = y ]] ; then
wget http://iweb.dl.sourceforge.net/project/leopardflower/Source/lpfw-0.4-src.zip
fi

if [[ $answerMysql = y]] ; then
sudo yum install mysql-server
sudo /sbin/service mysqld start
fi

# Not sure about this part
# If OpenVAS was installed, check for error file, if present, print alert

function filecheck () {
file="/root/Desktop/openvas-info.txt"

if [ -f "$file" ] ; then
printf "Check /root/Desktop/openvas-info.txt for errors and recommendations
"
fi
}
if [[ $answerOpenVAS = y ]] ; then

file="/root/Desktop/openvas-info.txt"

filecheck
printf "Note: OpenVAS user name is [admin]
"
sleep 3
fi

function pause () {
read -p "$*"
}

if [[ $bastilleinstalled = y]] ; then
read -p "Do you want to configure Bastille? [y/n]" answerConfigBastille
fi

if [[answerConfigBastille = y]] ;
printf"Here we go...."
printf"

#################################
#This is what you need to select#
#################################

#File permissions module: Yes (suid)
#Disable SUID for mount/umount: Yes
#Disable SUID on ping: Yes
#Disable clear-text r-protocols that use IP-based authentication? Yes
#Enforce password aging? No (situation dependent, I have no users accessing my machines except me, and I only allow ssh keys)
#Default umask: Yes
#Umask: 077
#Disable root login on tty’s 1-6: No
#Password protect GRUB prompt: No (situation dependent, I’m on a VPS and would like to get support in case I need it)
#Password protect su mode: Yes
#default-deny on tcp-wrappers and xinetd? No
#Ensure telnet doesn’t run? Yes
#Ensure FTP does not run? Yes
#Display authorized use message? No (situation dependent, if you had other users, Yes)
#Put limits on system resource usage? Yes
#Restrict console access to group of users? Yes (then choose root)
#Add additional logging? Yes
#Setup remote logging if you have a remote log host, I don’t so I answered No
#Setup process accounting? Yes
#Disable acpid? Yes
#Deactivate nfs + samba? Yes (situation dependent)
#Stop sendmail from running in daemon mode? No (I have this firewalled off, so I’m not concerned)
#Deactivate apache? Yes
#Disable printing? Yes
#TMPDIR/TMP scripts? No (if a multi-user system, yes)
#Packet filtering script? No (we configured the firewall previously)
#Finished? YES! & reboot"

fi

if [[fail2baninstalled = y]] ; then
read -p "Do you want to configure fail2ban? [y/n]" answerConfigfail2ban
fi

if [[answerConfigfail2ban = y]] ; then
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i '/s/enabled  = true/enabled = false/g'/etc/fail2ban/jail.local
sed -i '/s/600/360000/g' /etc/fail2ban/jail.local
printf"Restarting Fail2ban..."
sudo service fail2ban restart



pause '
Press [Enter] key to exit...
'
