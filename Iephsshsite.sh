#!/bin/bash
#
# AutoScript Modified by: IEPH DEVELOPERS
# =================================

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Manila /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/iephdevs/iephscript/master/sources.list.debian7"
wget "http://www.dotdeb.org/dotdeb.gpg"
wget "http://www.webmin.com/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# update
apt-get update

# install webserver
apt-get -y install nginx

# install essential package
apt-get -y install nano iptables dnsutils openvpn screen whois ngrep unzip unrar

# install neofetch
echo "deb http://dl.bintray.com/dawidd6/neofetch jessie main" | sudo tee -a /etc/apt/sources.list
curl -L "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" -o Release-neofetch.key && sudo apt-key add Release-neofetch.key && rm Release-neofetch.key
apt-get update
apt-get install neofetch

echo 'echo -e "
 (         (        )                                       
 )\ )      )\ )  ( /(                                       
(()/( (   (()/(  )\())                                      
 /(_)))\   /(_))((_)\                                       
(_)) ((_) (_))   _((_)                                      
|_ _|| __|| _ \ | || |                                      
 | | | _| |  _/ | __ |                                      
|___||___||_|   |_||_|                                      
 (                        (        )   (         (    (     
 )\ )                     )\ )  ( /(   )\ )      )\ ) )\ )  
(()/(   (    (   (   (   (()/(  )\()) (()/( (   (()/((()/(  
 /(_))  )\   )\  )\  )\   /(_))((_)\   /(_)))\   /(_))/(_)) 
(_))_  ((_) ((_)((_)((_) (_))    ((_) (_)) ((_) (_)) (_))   
 |   \ | __|\ \ / / | __|| |    / _ \ | _ \| __|| _ \/ __|  
 | |) || _|  \ V /  | _| | |__ | (_) ||  _/| _| |   /\__ \  
 |___/ |___|  \_/   |___||____| \___/ |_|  |___||_|_\|___/  
                                                            
"' >> .bashrc
echo "clear" >> .bashrc
echo 'echo -e "Welcome to the server $HOSTNAME"' >> .bashrc
echo 'echo -e "Script modified by IEPH DEVELOPERS"' >> .bashrc
echo 'echo -e "Type menu to display a list of commands"' >> .bashrc
echo 'echo -e ""' >> .bashrc

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/iephdevs/iephscript/master/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by IEPH DEVELOPERS</pre>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/iephdevs/iephscript/master/vps.conf"
service nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar "https://raw.githubusercontent.com/iephdevs/iephscript/master/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/iephdevs/iephscript/master/1194.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables_yg_baru_dibikin.conf
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/iephdevs/iephscript/master/iptables"
chmod +x /etc/network/if-up.d/iptables
service openvpn restart

# configuration openvpn
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn "https://raw.githubusercontent.com/iephdevs/iephscript/master/client-1194.conf"
sed -i $MYIP2 /etc/openvpn/client.ovpn;
cp client.ovpn /home/vps/public_html/

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/iephdevs/iephscript/master/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/iephdevs/iephscript/master/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# setting port ssh
cd
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 443 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# blockir torrent
iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP
iptables -A OUTPUT -p udp --dport 1024:65534 -j DROP
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP


# install fail2ban
apt-get -y install fail2ban;
service fail2ban restart

# install squid3
cd
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/iephdevs/iephscript/master/squid3.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
wget -O webmin_1.881_all.deb "http://prdownloads.sourceforge.net/webadmin/webmin_1.881_all.deb"
dpkg -i --force-all webmin_1.881_all.deb;
apt-get -y -f install;
rm /root/webmin_1.881_all.deb
service webmin restart

# install ddos deflate
apt-get -y install dnsutils dsniff
wget https://raw.githubusercontent.com/iephdevs/iephscript/master/ddos-deflate-master.zip
unzip ddos-deflate-master.zip
cd ddos-deflate-master
./install.sh

# banner
rm /etc/issue.net
wget -O /etc/issue.net "https://raw.githubusercontent.com/iephdevs/iephscript/master/issue.net"
sed -i 's@#Banner@Banner@g' /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear
service ssh restart
service dropbear restart

# install ssh site
apt-get -y install zip unzip
cd /var/www/html
wget https://raw.githubusercontent.com/iephdevs/iephscript/master/iephsshsite.zip
unzip iephsshsite.zip
rm -f iephsshsite.zip
chown -R www-data:www-data /var/www/html
chmod -R g+rw /var/www/html

# download script
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/iephdevs/iephscript/master/menu.sh"
wget -O usernew "https://raw.githubusercontent.com/iephdevs/iephscript/master/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/iephdevs/iephscript/master/trial.sh"
wget -O delete "https://raw.githubusercontent.com/iephdevs/iephscript/master/delete.sh"
wget -O check "https://raw.githubusercontent.com/iephdevs/iephscript/master/user-login.sh"
wget -O userlimit "https://raw.githubusercontent.com/iephdevs/iephscript/master/userlimit.sh"
wget -O userlimitssh "https://raw.githubusercontent.com/iephdevs/iephscript/master/userlimitssh.sh"
wget -O member "https://raw.githubusercontent.com/iephdevs/iephscript/master/user-list.sh"
wget -O resvis "https://raw.githubusercontent.com/iephdevs/iephscript/master/resvis.sh"
wget -O speedtest "https://raw.githubusercontent.com/iephdevs/iephscript/master/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/iephdevs/iephscript/master/info.sh"
wget -O about "https://raw.githubusercontent.com/iephdevs/iephscript/master/about.sh"

echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

chmod +x menu
chmod +x usernew
chmod +x trial
chmod +x delete
chmod +x check
chmod +x member
chmod +x resvis
chmod +x speedtest
chmod +x info
chmod +x userlimit
chmod +x userlimitssh
chmod +x about

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
service nginx start
service openvpn restart
service cron restart
service ssh restart
service dropbear restart
service squid3 restart
service fail2ban restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "Autoscript Include:" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenSSH  : 22, 143"  | tee -a log-install.txt
echo "Dropbear : 80, 443"  | tee -a log-install.txt
echo "Squid3   : 8080, 3128 (limit to IP SSH)"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.ovpn)"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "nginx    : 81"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Script"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo "menu         (Menu list)"  | tee -a log-install.txt
echo "usernew      (New user SSH)"  | tee -a log-install.txt
echo "trial        (Trial Account)"  | tee -a log-install.txt
echo "delete       (Delete Account)"  | tee -a log-install.txt
echo "check        (Check User Login)"  | tee -a log-install.txt
echo "member       (Check Member SSH)"  | tee -a log-install.txt
echo "userlimit    (Limit login Dropbear)"  | tee -a log-install.txt
echo "userlimitssh (Limit login SSHD)"  | tee -a log-install.txt
echo "resvis       (Restart Service dropbear, webmin, squid3, openvpn dan ssh)"  | tee -a log-install.txt
echo "reboot       (Reboot VPS)"  | tee -a log-install.txt
echo "speedtest    (Speedtest VPS)"  | tee -a log-install.txt
echo "info         (System Information)"  | tee -a log-install.txt
echo "about        (About AutoScript)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Other features"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/"  | tee -a log-install.txt
echo "Timezone : Asia/Manila(GMT +7)"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "===================="  | tee -a log-install.txt
echo "===================="  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Installation Log --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Auto Reboot 12AM"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
cd
rm -f /root/Iephdevs.sh
