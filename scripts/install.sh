#!/bin/bash
echo "Installing necessary packages"


# # display all updates that are security relevant, and get a reutrn code on whether there are security updates enter:
# sudo yum --security check-update
# To upgrade packages that have security errata (upgrades to the latest available package) use
sudo yum update -y
sudo yum --security update -y

#install tree, mtr and telnet
sudo yum install tree -y
sudo yum install mtr -y
sudo yum install telnet -y
# enabling ntpd service as deamon
# sudo sed -i -e \
#         's/.*OPTIONS=.*/OPTIONS="-g -4"/g' \
#         /etc/sysconfig/ntpd

# if ! grep -q 'tinker panic' /etc/ntp.conf; then
#     sudo sed -i -e \
#             '/.*restrict -6.*$/d;/.*restrict ::1$/d;2a\\ntinker panic 0' \
#             /etc/ntp.conf
# fi
#Chrony is introduced as new NTP client to replace the ntp as the default time syncing package since RHEL7
#To stop chronyd
sudo systemctl stop chronyd
sudo systemctl disable chronyd
sudo yum install ntp -y
sudo systemctl enable ntpd.service
sudo systemctl start ntpd.service
sudo yum update -y

#kernel limtis

cat <<EOF | sudo tee -a /etc/sysctl.d/10-kernel-limits.conf
fs.file-max = 65535
kernel.pid_max = 65535
EOF

cat <<EOF | sudo tee -a /etc/security/limits.conf
*  soft     nproc          65535
*  hard     nproc          65535
*  soft     nofile         65535
*  hard     nofile         65535
EOF

cat <<EOF | sudo tee /etc/security/limits.d/*.conf
*  soft     nproc          65535
*  hard     nproc          65535
*  soft     nofile         65535
*  hard     nofile         65535
EOF


cat <<EOF | sudo tee -a /etc/sysctl.conf
fs.file-max = 65535
EOF

#ipv6 block
#export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cat <<EOF | sudo tee -a /etc/modprobe.d/blacklist-ipv6.conf
options ipv6 disable=1
alias net-pf-10 off
alias ipv6 off
install ipv6 /bin/true
blacklist ipv6
EOF

cat <<'EOF' | sudo tee -a /etc/sysctl.d/10-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sudo chown root: /etc/modprobe.d/blacklist-ipv6.conf \
            /etc/sysctl.d/10-disable-ipv6.conf \
            /etc/sysctl.d/10-kernel-limits.conf

cat /etc/sysctl.conf /etc/sysctl.d/*.conf /etc/security/limits.conf /etc/security/limits.d/*.conf | sudo sysctl -e -p