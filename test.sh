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
useradd -s /bin/bash -d /opt/stack -m stack
chmod +x /opt/stack

echo "stack ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/stack

# gnutls-bin 설치
apt install -y gnutls-bin

# git clone (devstack 설치)
su - stack -c "git clone https://opendev.org/openstack/devstack"

# devstack 디렉터리 이동 및 local.conf 복사

cp /opt/stack/devstack/samples/local.conf /opt/stack/devstack/local.conf

# IP 저장
IP=`hostname -I | cut -f 1 -d ' '`"

# local.conf 파일 수정
sed -i 's/ADMIN_PASSWORD=nomoresecret/ADMIN_PASSWORD=openstack/g' /opt/stack/devstack/local.conf
sed -i 's/DATABASE_PASSWORD=stackdb/DATABASE_PASSWORD=openstack/g' /opt/stack/devstack/local.conf
sed -i 's/RABBIT_PASSWORD=stackqueue/RABBIT_PASSWORD=openstack/g' /opt/stack/devstack/local.conf
sed -i 's/SERVICE_PASSWORD=$ADMIN_PASSWORD/SERVICE_PASSWORD=openstack/g' /opt/stack/devstack/local.conf
sed -i 's/#HOST_IP=w.x.y.z/HOST_IP=$IP/g' /opt/stack/devstack/local.conf

# disutils 설치
apt install -y python3.10-distutils

# git config 추가
git config --global http.sslVerify false
git config --global http.postBuffer 1048576000
git config --global core.longpaths true
git config --global core.compression -1

su - stack -c "sudo git clone --depth=1 https://opendev.org/openstack/neutron.git --branch stable/zed"

# 쉘 실행
su - stack -c "sh /opt/stack/devstack/unstack.sh"
su - stack -c "sh /opt/stack/devstack/stack.sh"

echo --------------------------------------------------
echo "                    종 료                       "
echo --------------------------------------------------
