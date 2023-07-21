#!/bin/bash 

read -p "请输入 IP 或者域名：" IP

# 下载 sub-web 源码
git clone https://github.com/CareyWang/sub-web.git sub-web

# 下载源码补丁
git clone https://github.com/shidahuilang/SS-SSR-TG-iptables-bt "subweb"

# 复制补丁文件
cp -R /root/subweb/subweb/* "/root/sub-web/"
cp -R "/root/subweb/subweb/.env" "/root/sub-web/.env"
cp -R "/root/subweb/Subconverter.vue" "/root/sub-web/src/views/Subconverter.vue"

# 修改 IP 地址
sed -i "s/127.0.0.1/$IP/g" "/root/sub-web/.env"
sed -i "s/127.0.0.1/$IP/g" "/root/sub-web/src/views/Subconverter.vue"

# 修改 nginx 版本
sed -i "s/nginx:1.16-alpine/nginx:alpine/g" "/root/sub-web/Dockerfile"

# 进入构建目录
cd sub-web/

# 开始构建
docker build -t sub-web:latest .

# 删除目录
cd /root
rm -rf /root/subweb/
rm -rf /root/sub-web/

# 运行容器
docker run -d -p 25501:80 --restart unless-stopped --name Sub-Web sub-web:latest

# 处理订阅链接后端
docker pull tindy2013/subconverter:latest

# 新建subconverter目录下载二进制文件
mkdir -p /root/subconverter
cd /root/subconverter
wget https://ghproxy.com/https://github.com/MetaCubeX/subconverter/releases/latest/download/subconverter_linux64.tar.gz

# 解压二进制文件
tar -zxf subconverter_linux64.tar.gz

# 运行容器
docker run -d \
--name Subconverter \
--restart=unless-stopped \
-p 25500:25500 \
-v /opt/subconverter/subconverter/subconverter:/usr/bin/subconverter \
tindy2013/subconverter:latest

echo "Sub-Web 已经启动，访问 http://$IP:25501 即可使用。"