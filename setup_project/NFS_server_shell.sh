#!/bin/bash

# NFS 서버 자동 설치 및 설정 스크립트

# 1. 네트워크 설정 - Static IP 설정
echo "Static IP 설정 중..."
nmcli device status

# 여기서 본인의 네트워크 인터페이스 이름을 확인한 후, 디바이스 이름을 수정해 주세요.
DEVICE_NAME="enp0s3"
STATIC_IP="192.168.138.100/24"
GATEWAY="192.168.138.1"
DNS="192.168.138.100,168.126.63.1,8.8.8.8"

sudo nmcli con modify $DEVICE_NAME ipv4.addresses $STATIC_IP ipv4.gateway $GATEWAY ipv4.dns $DNS ipv4.method manual
sudo nmcli con down $DEVICE_NAME
sudo nmcli con up $DEVICE_NAME
echo "IP 설정 완료!"
ip a

# 2. NFS 유틸리티 설치
echo "NFS 유틸리티 설치 중..."
sudo dnf install nfs-utils -y

# 3. NFS 서비스 활성화 및 시작
echo "NFS 서비스 활성화 및 시작 중..."
sudo systemctl enable --now nfs-server rpcbind
sudo systemctl start nfs-server rpcbind

# 4. NFS 서비스 상태 확인
echo "NFS 서비스 상태 확인 중..."
sudo systemctl status nfs-server

# 5. NFS 공유 디렉토리 생성 및 권한 설정
echo "사용자 생성 중..."
sudo useradd -m user01
sudo useradd -m user02
sudo useradd -m user03

chmod 755 /home/user01
chmod 755 /home/user02
chmod 755 /home/user03

# 6. /etc/exports 설정 및 적용
# 사용자별 디렉터리 공유 설정 추가
echo "/home/user01  192.168.138.0/24(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a $EXPORTS_FILE
echo "/home/user02  192.168.138.0/24(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a $EXPORTS_FILE
echo "/home/user03  192.168.138.0/24(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a $EXPORTS_FILE

sudo exportfs -r
echo "NFS exports 적용 완료."
sudo exportfs -v

# 7. 방화벽 설정
echo "방화벽 설정 중..."
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --reload
echo "방화벽 설정 완료."

# 스크립트 완료
echo "NFS 서버 설정이 완료되었습니다."
