#!/bin/bash

SERVER_DS="server.example.com"

# AutoFS 설정
yum install -y autofs

# AutoFS Indirect Map 설정
cat <<EOL > /etc/auto.master.d/indirect.autofs
/home /etc/auto.home
EOL

# 사용자 홈 디렉터리 NFS 마운트를 위한 Indirect Map 설정
cat <<EOL > /etc/auto.home
user01 -rw,sync,sec=sys $SERVER_DS:/autofs/user01
user02 -rw,sync,sec=sys $SERVER_DS:/autofs/user02
user03 -rw,sync,sec=sys $SERVER_DS:/autofs/user03
EOL

# AutoFS 서비스 재시작 및 활성화
systemctl restart autofs
systemctl enable autofs

# AutoFS 상태 확인
systemctl status autofs

echo "AutoFS NFS 마운트 설정이 완료되었습니다."

# user01, user02, user03 생성
adduser -m user01
adduser -m user02
adduser -m user03

# /etc/skel 디렉터리에서 기본 .bash 파일들 복사
cp /etc/skel/.bash* /home/user01/
cp /etc/skel/.bash* /home/user02/
cp /etc/skel/.bash* /home/user03/

# 각 사용자의 홈 디렉터리 권한 수정
chown -R user01:user01 /home/user01/
chown -R user02:user02 /home/user02/
chown -R user03:user03 /home/user03/
