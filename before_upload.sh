#!/bin/bash

wget -O /tmp/qiniu-devtools-linux_amd64-current.tar.gz http://devtools.qiniu.io/qiniu-devtools-linux_amd64-current.tar.gz || exit 1
mkdir qiniu
tar -zxvf /tmp/qiniu-devtools-linux_amd64-current.tar.gz -C ./qiniu/ || exit 2
wget -O /tmp/qshell.zip http://qdisk.qiniudn.com/qshell-v1.4.6.zip
unzip /tmp/qshell.zip -d ./qiniu/ || exit 2
cp ./qiniu/qshell_linux_amd64 ./qiniu/qshell
