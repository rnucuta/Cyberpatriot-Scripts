echo "Welcome to the UBUNTU 16.04 SCRIPT!"
echo "Property of BASIS Scottsdale Cryptorally Team!"
echo "Updating..."
sudo add-apt-repository -y ppa:libreoffice/ppa
wait
sudo apt-get update -y
wait
sudo apt-get upgrade -y
wait
sudo apt-get dist-upgrade -y
wait
killall firefox
wait
sudo apt-get --purge --reinstall install firefox -y
wait
sudo apt-get install clamtk -y	
wait
pause

echo "Automatic updates..."
sed -i -e 's/APT::Periodic::Update-Package-Lists.*\+/APT::Periodic::Update-Package-Lists "1";/' /etc/apt/apt.conf.d/10periodic
sed -i -e 's/APT::Periodic::Download-Upgradeable-Packages.*\+/APT::Periodic::Download-Upgradeable-Packages "0";/' /etc/apt/apt.conf.d/10periodic
##Sets default broswer
sed -i 's/x-scheme-handler\/http=.*/x-scheme-handler\/http=firefox.desktop/g' /home/$UserName/.local/share/applications/mimeapps.list
##Set "install security updates"
cat /etc/apt/sources.list | grep "deb http://security.ubuntu.com/ubuntu/ trusty-security universe main multiverse restricted"
if [ $? -eq 1 ]
then
	echo "deb http://security.ubuntu.com/ubuntu/ trusty-security universe main multiverse restricted" >> /etc/apt/sources.list
fi

echo "Configuring SSH..."
sudo apt-get install -y openssh-server ssh
wait
sed -i 's/LoginGraceTime .*/LoginGraceTime 60/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/Protocol .*/Protocol 2/g' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords .*/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication .*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/X11Forwarding .*/X11Forwarding no/g' /etc/ssh/sshd_config
sed -i '$a AllowUsers' /etc/ssh/sshd_config
for x in `cat users`
do
	sed -i "/^AllowUser/ s/$/ $x /" /etc/ssh/sshd_config
done

##Removes hack tools
hackTools() {
##CHANGE TO GREP -i
echo "$LogTime uss: [$UserName]# Removing hacking tools..." >> output.log
##Looks for apache web server
	dpkg -l | grep apache >> output.log
	if [ $? -eq 0 ];
	then
        	read -p "Do you want apache installed on the system[y/n]: "
        	if [ $a = n ];
        	then
      	        	apt-get autoremove -y --purge apache2 >> output.log
			else
            		if [ -e /etc/apache2/apache2.conf ]
				then
					chown -R root:root /etc/apache2
					chown -R root:root /etc/apache
					echo \<Directory \> >> /etc/apache2/apache2.conf
					echo -e ' \t AllowOverride None' >> /etc/apache2/apache2.conf
					echo -e ' \t Order Deny,Allow' >> /etc/apache2/apache2.conf
					echo -e ' \t Deny from all' >> /etc/apache2/apache2.conf
					echo UserDir disabled root >> /etc/apache2/apache2.conf
				else
					##Installs and configures apache
					apt-get install apache2 -y
						chown -R root:root /etc/apache2
						chown -R root:root /etc/apache
						echo \<Directory \> >> /etc/apache2/apache2.conf
						echo -e ' \t AllowOverride None' >> /etc/apache2/apache2.conf
						echo -e ' \t Order Deny,Allow' >> /etc/apache2/apache2.conf
						echo -e ' \t Deny from all' >> /etc/apache2/apache2.conf
						echo UserDir disabled root >> /etc/apache2/apache2.conf

					##Installs and configures sql
					apt-get install mysql-server -y

					##Installs and configures php5
					apt-get install php5 -y
					chmod 640 /etc/php5/apache2/php.ini
				fi
        	fi
	else
        echo "Apache is not installed"
		sleep 1
	fi
##Looks for john the ripper
	dpkg -l | grep john >> output.log
	if [ $? -eq 0 ];
	then
        	apt-get autoremove -y --purge john >> output.log
        	echo "John has been ripped"
			sleep 1
	else
        	echo "John The Ripper has not been found on the system"
			sleep 1
	fi
##Look for HYDRA
	dpkg -l | grep hydra >>output.log
	if [ $? -eq 0 ];
	then
		echo "Hydra removed"
		apt-get autoremove -y --purge hydra >> output.log
	else
		echo "Hydra has not been found."
	fi
##Looks for nginx web server
	dpkg -l | grep nginx >> output.log
	if [ $? -eq 0 ];
	then
        	echo "NGINX Removed"
        	apt-get autoremove -y --purge nginx >> output.log
	else
        	echo "NGINX has not been found"
			sleep 1
	fi
##Looks for samba
	if [ -d /etc/samba ];
	then
		read -p "Samba has been found on this system, do you want to remove it?[y/n]: " a
		if [ $a = y ];
		then
echo "$LogTime uss: [$UserName]# Uninstalling samba..." >> output.log
			sudo apt-get autoremove --purge -y samba >> output.log
			sudo apt-get autoremove --purge -y samba >> output.log
echo "$LogTime uss: [$UserName]# Samba has been removed." >> output.log
		else
			sed -i '82 i\restrict anonymous = 2' /etc/samba/smb.conf
			##List shares
		fi
	else
		echo "Samba has not been found."
		sleep 1
	fi
##LOOK FOR DNS
	if [ -d /etc/bind ];
	then
		read -p "DNS server is running would you like to shut it down?[y/n]: " a
		if [ $a = y ];
		then
			apt-get autoremove -y --purge bind9 
		fi
	else
		echo "DNS not found."
		sleep 1
	fi
##Looks for FTP
	dpkg -l | grep -i 'vsftpd|ftp' >> output.log
	if [ $? -eq 0 ]
	then	
		read -p "FTP Server has been installed, would you like to remove it?[y/n]: " a
		if [ $a = y ]
		then
			PID = `pgrep vsftpd`
			sed -i 's/^/#/' /etc/vsftpd.conf
			kill $PID
			apt-get autoremove -y --purge vsftpd ftp
		else
			sed -i 's/anonymous_enable=.*/anonymous_enable=NO/' /etc/vsftpd.conf
			sed -i 's/local_enable=.*/local_enable=YES/' /etc/vsftpd.conf
			sed -i 's/#write_enable=.*/write_enable=YES/' /etc/vsftpd.conf
			sed -i 's/#chroot_local_user=.*/chroot_local_user=YES/' /etc/vsftpd.conf
		fi
	else
		echo "FTP has not been found."
		sleep 1
	fi
##Looks for TFTPD
	dpkg -l | grep tftpd >> output.log
	if [ $? -eq 0 ]
	then
		read -p "TFTPD has been installed, would you like to remove it?[y/n]: " a
		if [ $a = y ]
		then
			apt-get autoremove -y --purge tftpd
		fi
	else
		echo "TFTPD not found."
		sleep 1
	fi
##Looking for VNC
	dpkg -l | grep -E 'x11vnc|tightvncserver' >> output.log
	if [ $? -eq 0 ]
	then
		read -p "VNC has been installed, would you like to remove it?[y/n]: " a
		if [ $a = y ]
		then
			apt-get autoremove -y --purge x11vnc tightvncserver 
		##else
			##Configure VNC
		fi
	else
		echo "VNC not found."
		sleep 1
	fi

##Looking for NFS
	dpkg -l | grep nfs-kernel-server >> output.log
	if [ $? -eq 0 ]
	then	
		read -p "NFS has been found, would you like to remove it?[y/n]: " a
		if [ $a = 0 ]
		then
			apt-get autoremove -y --purge nfs-kernel-server
		##else
			##Configure NFS
		fi
	else
		echo "NFS has not been found."
		sleep 1
	fi
##Looks for snmp
	dpkg -l | grep snmp >> output.log
	if [ $? -eq 0 ]
	then	
		echo "SNMP removed!"
		apt-get autoremove -y --purge snmp
	else
		echo "SNMP has not been found."
		sleep 1
	fi
##Looks for sendmail and postfix
	dpkg -l | grep -E 'postfix|sendmail' >> output.log
	if [ $? -eq 0 ]
	then
		echo "Mail servers have been found."
		apt-get autoremove -y --purge postfix sendmail
	else
		echo "Mail servers have not been located."
		sleep 1
	fi
##Looks xinetd
	dpkg -l | grep xinetd >> output.log
	if [ $? -eq 0 ]
	then
		echo "XINIT HAS BEEN FOUND!"
		apt-get autoremove -y --purge xinetd
	else
		echo "XINETD has not been found."
		sleep 1
	fi
	pause
	sudo apt-get purge --auto-remove zenmap nmap
	wait
}
hackTools

echo "Configure firewall..."
dpkg -l | grep ufw
if [ $? -eq 1 ]
then
	sudo apt-get install ufw
fi
sudo ufw enable

echo "Disabling ctrl-alt-del..."
sed -i '/exec shutdown -r not "Control-Alt-Delete pressed"/#exec shutdown -r not "Control-Alt-Delete pressed"/' /etc/init/control-alt-delete.conf

echo "Changing sudo timeout..."
echo "Defaults	timestamp_timeout=0" >> sudo visudo

echo "Listing cronjobs in cron.log..."
echo "###CRONTABS###" > cron.log
for x in $(cat users); do crontab -u $x -l; done >> cron.log
echo "###CRON JOBS###" >> cron.log
ls /etc/cron.* >> cron.log
ls /var/spool/cron/crontabs/.* >> cron.log
ls /etc/crontab >> cron.log

#	Listing the init.d/init files
echo "###Init.d###" >> cron.log
ls /etc/init.d >> cron.log

echo "###Init###" >> cron.log
ls /etc/init >> cron.log
cat cron.log
pause

echo "Removing media files..."
find / -type f -name "*.mp3" -exec rm -i {} 
find / -type f -name "*.mov" -exec rm -i {} 
find / -type f -name "*.mp4" -exec rm -i {} 
find / -type f -name "*.avi" -exec rm -i {}
find / -type f -name "*.mpg" -exec rm -i {} 
find / -type f -name "*.mpeg" -exec rm -i {}
find / -type f -name "*.m4a" -exec rm -i {}
find / -type f -name "*.flv" -exec rm -i {}
find / -type f -name "*.ogg" -exec rm -i {}
find / -type f -name "*.gif" -exec rm -i {}
find / -type f -name "*.png" -exec rm -i {}


echo "Editing /etc/lightdm/lightdm.conf"
sed -i '$a allow-guest=false' /etc/lightdm/lightdm.conf
sed -i '$a greeter-hide-users=true' /etc/lightdm/lightdm.conf
sed -i '$a greeter-show-manual-login=true' /etc/lightdm/lightdm.conf
read -p 'Restart lightdm?[y/n]: ' lightdm_bool
cat /etc/ligthdm/lightdm.conf | grep autologin-user >> /dev/null
if [ $? -eq 0 ]
then
	USER=`cat /etc/lightdm/lightdm.conf | grep autologin-user | cut -d= -f2`
	if [ "$USER" != "none" ]
	then
		echo "$USER has ben set to autologin."
		sed -i 's/autologin-user=.*/autologin-user=none/' /etc/lightdm/lightdm.conf
	fi
else
	sed -i '$a autologin-user=none' /etc/lightdm/lightdm.conf
fi
if [ $lightdm_bool==y ];
then
	sudo restart lightdm
	wait
else
	echo "Thank you for using the UBUNTU 16.04 SCRIPT!"
fi