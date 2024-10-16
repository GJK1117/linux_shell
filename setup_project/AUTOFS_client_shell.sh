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
