#!/bin/bash

curl http://echoip.com/
wget -O /tmp/qiniu-devtools-linux_amd64-current.tar.gz http://devtools.qiniu.com/qiniu-devtools-linux_amd64-current.tar.gz || exit 1
md5sum /tmp/qiniu-devtools-linux_amd64-current.tar.gz
mkdir qiniu
tar -zxvf /tmp/qiniu-devtools-linux_amd64-current.tar.gz -C ./qiniu/ || exit 2
wget -O /tmp/qshell.zip http://devtools.qiniu.com/qshell-v1.6.5.zip
md5sum /tmp/qshell.zip
unzip /tmp/qshell.zip -d ./qiniu/ || exit 2
cp ./qiniu/qshell_linux_amd64 ./qiniu/qshell
