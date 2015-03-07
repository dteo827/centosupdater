#!/bin/bash

# CentOS Configuration and Updater version 2.0
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
read -p "Do you want to update bash? [y/n] " answerUpdateBash
read -p "Do you want to add Google's and Level3's Public DNS to the resolv.conf file? [y/n]" answerGoogleDNS
read -p "Do you want to fix the secruity repos to archive repos? [y/n]" answerFixRepos
read -p "Do you want to install *ONLY* security updates to CentOS Linux now? [y/n] " answerSecUpdate
read -p "Do you want to install *ALL* updates to Ubuntu Linux now? [y/n] " answerUpdate
read -p "Do you want to turn off root login, Ipv6, keep boot as read only,and ignore ICMP broadcast requests and prevent XSS attacks? [y/n]" answermasshardening
read -p "Do you want to install Bastille [y/n]" answerBastille
read -p "Do you want to install Lynis [y/n]" answerLynis
read -p "Do you want to install Fail2ban [y/n]" answerFail2ban
}

# Flags!!!!
# If script run with -a flag, all options will automatically default to yes

echo "version"
lsb_release -r >> file
uname -r >> file
echo date >> file
echo
echo "my name" >> file
echo
echo dpkg -l >> file

if [[ $1 = -a ]] ; then

    read -p "Are you sure you want to install all packages and configure everything by default? Only Security Updates will be installed [y/n] " answerWarning
    if [[ $answerWarning = y ]] ; then
        answerGoogleDNS=y
        answerFixRepos=y
        answerSecUpdate=y
        answermasshardening=y
        answerBastille=y
        answerLynis=y
        answerFail2ban=y
    else
        printf "Verify what you do and do not want done...."
        sleep 2
        questions
fi

else
    echo "unknown command"
    questions
fi

elif [[ $1 = -h ]] ; then

cat README.md
exit
else

questions
fi

# Logic for update and configuration steps


if [[ $answerUpdateBash = y ]] ; then
    cd /src
    wget http://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz
    #download all patches
    for i in $(seq -f "%03g" 1 28); do wget http://ftp.gnu.org/gnu/bash/bash-4.3-patches/bash43-$i; done
    tar zxvf bash-4.3.tar.gz
    cd bash-4.3
    #apply all patches
    for i in $(seq -f "%03g" 1 28);do patch -p0 < ../bash43-$i; done
    #build and install
    ./configure --prefix=/ && make && make install
    cd /root
    rm -r src
fi

if [[ $answerGoogleDNS = y ]] ; then

sudo echo nameserver 8.8.8.8 >> /etc/resolv.conf
sudo echo nameserver 8.8.4.4 >> /etc/resolv.conf
sudo echo nameserver 4.2.2.2 >> /etc/resolv.conf
echo "Updated DNS resolutions to Google DNS, this task was completed at: " $(date) >> changes
fi

if  [[$answerFixRepos = y]] ; then
    wget http://download.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
	rpm -ivh epel-release-5-4.noarch.rpm
	sudo yum install epel-release-5-4.noarch.rpm
	sudo yum repolist
fi

if [[ $answermasshardening = y ]] ; then
sudo echo  1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
userdel shutdown
userdel halt
userdel games
userdel operator
userdel gopher
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
wget -q -O https://cisofy.com/files/lynis-1.6.4.tar.gz --no-check-certificate
tar - xjf lynis-1.6.4.tar.gz

echo "version"
lsb_release -r >> file
uname -r >> file
echo date >> file
echo
echo "my name" >> file
echo
echo dpkg -l >> file

function pause () {
        read -p "$*"
}

pause '
Press [Enter] key to exit...
'
