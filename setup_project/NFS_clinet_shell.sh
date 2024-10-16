#!/bin/bash

# NFS 클라이언트 설정 자동화 스크립트

# 1. NFS 클라이언트 유틸리티 설치
echo "NFS 클라이언트 유틸리티 설치 중..."
sudo dnf install nfs-utils -y

# 2. 마운트 포인트 생성
MOUNT_DIR="/mnt/nfs/home"
echo "마운트 포인트 생성 중: $MOUNT_DIR"
sudo mkdir -p $MOUNT_DIR

# 3. NFS 공유 디렉토리 마운트
NFS_SERVER_IP="192.168.138.100"
NFS_SHARE_DIR="/srv/nfs/home"
echo "NFS 공유 디렉토리 마운트 중: $NFS_SERVER_IP:$NFS_SHARE_DIR"
sudo mount -t nfs $NFS_SERVER_IP:$NFS_SHARE_DIR $MOUNT_DIR

# 4. 마운트 검증
echo "마운트 검증 중..."
df -h | grep $MOUNT_DIR

# 5. 읽기/쓰기 테스트
echo "NFS 읽기/쓰기 테스트 중..."
TEST_FILE="$MOUNT_DIR/testfile"
sudo touch $TEST_FILE
ls -l $MOUNT_DIR

# 스크립트 완료
echo "NFS 클라이언트 설정 및 테스트 완료."
