#!/bin/bash
set -e
top_dir=$(cd `dirname $0`; pwd)
echo $top_dir
portal_dir=$top_dir/portal
source $top_dir/portal.conf

# 如果环境变量里没有，则要输入
if [ -z $qiniu_user ]; then
    echo "请输入七牛用户名："
    read -s qiniu_user
    if [ -z $qiniu_user ]; then
        echo '错误：未输入'
        exit 1
    fi
fi

if [ -z $qiniu_passwd ]; then
    echo "请输入七牛密码："
    read -s qiniu_passwd
    if [ -z $qiniu_passwd ]; then
        echo '错误：未输入'
        exit 1
    fi
fi

if [ -z $qiniu_access_key ]; then
    echo "请输入七牛access_key："
    read -s qiniu_access_key
    if [ -z $qiniu_access_key ]; then
        echo '错误：未输入'
        exit 1
    fi
fi

if [ -z $qiniu_secret_key ]; then
    echo "请输入七牛secret_key："
    read -s qiniu_secret_key
    if [ -z $qiniu_secret_key ]; then
        echo '错误：未输入'
        exit 1
    fi
fi

qrsctl login $qiniu_user $qiniu_passwd
qshell account $qiniu_access_key $qiniu_secret_key

dirs=`ls -R $portal_dir | grep ':' | awk -F: '{print $1}'`
for dir in $dirs; do
    echo $dir
    cd $dir

    path=`pwd | sed -e "s|$portal_dir||"`
    qiniu_prefix=${path:1}"/"
    if [ $qiniu_prefix = "/" ]; then
        qiniu_prefix=""
    fi
    echo $qiniu_prefix
    tmp_lines=`find . -maxdepth 1 -type f -printf '%f\n'`
    for filename in $tmp_lines; do
        echo $filename
        echo $qiniu_prefix
        target="$qiniu_prefix"$filename
        if [ $filename == "index.html" ]; then
            target=$qiniu_prefix
        fi
        echo $target
        mime=`file -b --mime-type $filename`
        echo $mime
        qshell fput $qiniu_bucket "$target" $filename true "http://upws.qiniug.com"
        qrsctl cdn/refresh $qiniu_bucket http://$qiniu_domain/$target
    done
done
rm $portal_dir/index.html
echo 'the end'
