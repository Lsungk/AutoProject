#!/bin/bash

echo ----------------------------------------
echo                 시 작
echo ----------------------------------------
# apt 업데이트
apt update -y
apt upgrade -y

# SSH 서버 다운 & 스타트
apt install -y openssh-server


systemctl start sshd
systemctl enable sshd

# Openstack 계정 생성 및 openstack 계정 접속
useradd -s /bin/bash -d /opt/stack -m openstack
chmod +x /opt/stack

echo "stack ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/stack

# gnutls-bin 설치
su - openstack -c "apt install -y gnutls-bin"

# git clone (devstack 설치)
su - openstack -c "git clone https://opendev.org/openstack/devstack"

# devstack 디렉터리 이동 및 local.conf 복사
su - openstack -c "cd /devstack"
su - openstack -c "sudo cp ./samples/local.conf local.conf"

# IP 저장
su - openstack -c "IP=`hostname -I | cut -f 1 -d ' '`"

# local.conf 파일 수정
su - openstack -c "sudo sed -i 's/ADMIN_PASSWORD=nomoresecret/ADMIN_PASSWORD=openstack/g' local.conf"
su - openstack -c "sudo sed -i 's/DATABASE_PASSWORD=stackdb/DATABASE_PASSWORD=openstack/g' local.conf"
su - openstack -c "sudo sed -i 's/RABBIT_PASSWORD=stackqueue/RABBIT_PASSWORD=openstack/g' local.conf"
su - openstack -c "sudo sed -i 's/SERVICE_PASSWORD=$ADMIN_PASSWORD/SERVICE_PASSWORD=openstack/g' local.conf"
su - openstack -c "sudo sed -i 's/HOST_IP=w.x.y.z/HOST_IP=$IP/g' local.conf"

# disutils 설치
su - openstack -c "sudo apt install -y python3.10-disutils"

# git config 추가
su - openstack -c "sudo git config --global http.sslVerify false"
su - openstack -c "sudo git config --global http.postBuffer 1048576000"
su - openstack -c "sudo git config --global core.longpaths true"
su - openstack -c "sudo git config --global core.compression -l"

su - openstack -c "sudo git clone --depth=1 https://opendev.org/openstack/neutron.gi --branch stable/zed"

# 쉘 실행
su - openstack -c "sh /stack.sh"

echo --------------------------------------------------
echo                        종료
echo --------------------------------------------------
