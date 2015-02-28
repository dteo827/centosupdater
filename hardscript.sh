#!/bin/bash

# CentOS Configuration and Updater version 2.0
# I hate Centos.
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
read -p "Do you want to install security updates to CentOS Linux now? [y/n] " answerSecUpdate
read -p "Do you want to install all updates to CentOS Linux now? [y/n] " answerUpdate
read -p "Do you want to install Lynis [y/n]" answerLynis
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
answerSecUpdate=y
answerUpdate=y
answerLynis=y
else
printf "Verify would you do and do not want done...."
sleep 2
questions
fi

elif [[ $1 = -h ]] ; then

cat README.md
exit
else

questions
fi

# Logic for update and configuration steps

if [[ $answerGoogleDNS = y ]] ; then

sudo echo nameserver 8.8.8.8 >> /etc/resolv.conf
sudo echo nameserver 8.8.4.4 >> /etc/resolv.conf
sudo echo nameserver 4.2.2.2 >> /etc/resolv.conf
fi

if [[ $answerWegettinghard = y ]] ; then
sudo echo  1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
sudo sed -i 's/.*PermitRootLogin.*yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sysctl net.ipv6.conf.all.disable_ipv6=1
yum install sudo perl ntp crontabs sendmail wget -y
wget http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
sudo rpm -Uvh remi-release-5*.rpm epel-release-5*.rpm
yum repolist

userdel shutdown
userdel halt
userdel games
userdel operator
userdel gopher
awk -F: '($3 == "0") (print)' /etc/passwd
yum erase xinetd inetd tftp-server ypserv telnet-server rsh-server

#prevent running root cron tasks
touch /etc/cron.allow
chmod 600 /etc/cron.allow
awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/cron.deny
touch /etc/at.allow
chmod 600 /etc/at.allow
awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/at.deny

#Narrowing rights
chmod 700 /root
chmod 700 /var/log/audit
chmod 740 /etc/rc.d/init.d/iptables
chmod 740 /sbin/iptables
chmod -R 700 /etc/skel
chmod 600 /etc/rsyslog.conf
chmod 640 /etc/security/access.conf
chmod 600 /etc/syctrl.conf

#ignore ping broadcasts
cat << 'EOF' >> /etc/sysctl.conf
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_echo_ignore_bogus_error_responses = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accepts_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
authconfig --passalgo=sha512 --update

fi

if [[ $answerSecUpdate = y ]] ; then

printf "Downloading Security updates for CentOS..."
yum -y install yum-plugin-security
sudo yum install yum
sudo --security update

fi

if [[ $answerUpdate = y ]] ; then

printf "Updating CentOS, this stage may take about an hour to complete...Hope you have some time to burn...
"
su -c 'yum update'
yum update -y
sudo yum install sudo perl ntp crontabs sendmail mlocate wget -y
wget http://fedora.mirror.nexicom.net/epe1/6/i386/epel-release-6-7.noarch.rpm
sudo yum install epel-release-6-7.noarch.rpm
sudo yum repolist

fi

if [[ $answerLynis = y ]]; then
wget -q -O https://cisofy.com/files/lynis-1.6.4.tar.gz
tar - xjf lynis-1.6.4.tar.gz


pause '
Press [Enter] key to exit...
'
fi

pause '
    Press [Enter] key to exit...
     '
