#!/bin/bash

CURDIR=$PWD
CORES=`cat /proc/cpuinfo | grep "processor" | wc -l`

rpm -Uhv http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
yum -y install gcc gcc-c++ glibc-devel make nasm pkgconfig lib-devel openssl-devel expat-devel gettext-devel libtool zlib-devel pcre-devel yamdi unzip patch lua
tar -zxvf nginx_mod_h264_streaming-2.2.7.tar.gz
unzip nginx-rtmp-module-master.zip
tar -zxvf LuaJIT-2.0.2.tar.gz
cd LuaJIT-2.0.2 && make -j$CORES && make install && cd $CURDIR
unzip ngx_devel_kit-master.zip
unzip lua-nginx-module-master.zip
unzip nginx_upstream_check_module-master.zip
export LUAJIT_LIB=/usr/local/lib 
export LUAJIT_INC=/usr/local/include/luajit-2.0
tar -zxvf nginx-1.8.0.tar.gz
cd nginx_mod_h264_streaming-2.2.7
patch -p1 < ../nginx_mod_h264_streaming-2.2.7.patch
cd ../nginx-1.8.0

patch -p1 < ../nginx_upstream_check_module-master/check_1.7.5+.patch
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_flv_module --with-http_mp4_module --add-module=../nginx-rtmp-module-master --add-module=../nginx_mod_h264_streaming-2.2.7 --with-ld-opt="-Wl,-rpath,$LUAJIT_LIB" --add-module=../ngx_devel_kit-master --add-module=../lua-nginx-module-master --add-module=../nginx_upstream_check_module-master --with-debug
sed -i 's/-Werror//' ./objs/Makefile
make -j$CORES && make install
mkdir -p /usr/local/nginx/html/nginx-rtmp-module
cp $CURDIR/nginx-rtmp-module-master/test/ /usr/local/nginx/html/nginx-rtmp-module/test -r
cp $CURDIR/nginx-rtmp-module-master/stat.xsl /usr/local/nginx/html/nginx-rtmp-module/
cp $CURDIR/nginx /etc/init.d/ && chmod a+x /etc/init.d/nginx && echo "/etc/init.d/nginx start" >> /etc/rc.local

