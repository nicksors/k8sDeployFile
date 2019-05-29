#ntp
yum -y install ntp
systemctl start ntpd
systemctl enable ntpd

#编码
echo 'export LANG="zh_CN.UTF-8"' >> /etc/profile

#文件数
ulimit -SHn 65535
echo "ulimit -SHn 65535" >> /etc/rc.local
#修改所有用户的文件描述符大小(65536)
cat >> /etc/security/limits.conf << EOF
* soft nofile 60000
* hard nofile 65535
EOF
#内核调优
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 32768
EOF
/sbin/sysctl -p

#vim setting
echo "syntax on" >> /root/.vimrc
echo "set nohlsearch" >> /root/.vimrc

#关闭selinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#防火墙
iptables -F
systemctl stop firewalld
systemctl disable firewalld

#安装软件包
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
yum -y install epel-release
yum -y install telnet
yum -y install net-tools
yum -y install zabbix-agent
yum -y install nc
yum -y install tcpdump
yum -y install tmux
yum -y install lrzsz
yum -y install iotop
yum -y install iftop
yum -y install vim
yum -y install htop

systemctl stop postfix
systemctl disable postfix
systemctl stop rpcbind
systemctl disable rpcbind
