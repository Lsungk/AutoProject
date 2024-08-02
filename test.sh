#!/bin/bash

echo --------------------------------------------------
echo "                    시 작                       "
echo --------------------------------------------------
# apt 업데이트
apt update -y
apt upgrade -y

# SSH 서버 다운 & 스타트
apt install -y openssh-server


systemctl start sshd
systemctl enable sshd

# Openstack 계정 생성 및 openstack 계정 접속
useradd -s /bin/bash -d /opt/openstack -m openstack
chmod +x /opt/openstack

echo "openstack ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/openstack

# gnutls-bin 설치
apt install -y gnutls-bin

# git clone (devstack 설치)
su - openstack -c "git clone https://opendev.org/openstack/devstack"

# devstack 디렉터리 이동 및 local.conf 복사

cp /opt/openstack/devstack/samples/local.conf ./local.conf"

# IP 저장
IP=`hostname -I | cut -f 1 -d ' '`"

# local.conf 파일 수정
sudo sed -i 's/ADMIN_PASSWORD=nomoresecret/ADMIN_PASSWORD=openstack/g' /opt/openstack/devstack/local.conf
sudo sed -i 's/DATABASE_PASSWORD=stackdb/DATABASE_PASSWORD=openstack/g' /opt/openstack/devstack/local.conf
sudo sed -i 's/RABBIT_PASSWORD=stackqueue/RABBIT_PASSWORD=openstack/g' /opt/openstack/devstack/local.conf
sudo sed -i 's/SERVICE_PASSWORD=$ADMIN_PASSWORD/SERVICE_PASSWORD=openstack/g' /opt/openstack/devstack/local.conf
sudo sed -i 's/HOST_IP=w.x.y.z/HOST_IP=$IP/g' /opt/openstack/devstack/local.conf

# disutils 설치
apt install -y python3.10-distutils

# git config 추가
git config --global http.sslVerify false
git config --global http.postBuffer 1048576000
git config --global core.longpaths true
git config --global core.compression -1

su - openstack -c "sudo git clone --depth=1 https://opendev.org/openstack/neutron.gi --branch stable/zed"

# 쉘 실행
source /opt/openstack/devstack/stack.sh

echo --------------------------------------------------
echo "                    종 료                       "
echo --------------------------------------------------
