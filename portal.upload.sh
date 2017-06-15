#!/bin/bash
set -e
top_dir=$(cd `dirname $0`; pwd)
echo $top_dir
portal_dir=$top_dir/site
mkdir -p $portal_dir
tmp_dir=$top_dir/tmp
mkdir -p $tmp_dir
source $top_dir/portal.conf

# 如果环境变量里没有，则要输入
if [ -z $QINIU_ACCESS_KEY ]; then
    echo "请输入七牛access_key："
    read -s QINIU_ACCESS_KEY
    if [ -z $QINIU_ACCESS_KEY ]; then
        echo '错误：未输入'
        exit 1
    fi
fi

if [ -z $QINIU_SECRET_KEY ]; then
    echo "请输入七牛secret_key："
    read -s QINIU_SECRET_KEY
    if [ -z $QINIU_SECRET_KEY ]; then
        echo '错误：未输入'
        exit 1
    fi
fi

qshell account $QINIU_ACCESS_KEY $QINIU_SECRET_KEY
echo "" > $tmp_dir/refresh.portal.txt
echo "{\"src_dir\": \"$portal_dir\", \"bucket\": \"$qiniu_bucket\", \"overwrite\": true, \"check_hash\": true }" > $tmp_dir/qupload.portal.json

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
        qshell fput $qiniu_bucket "$target" $filename true
        if [ $filename == "index.html" ]; then
            # html 链接不变，所以需要刷新。而img、js、css可以修改链接跳过老的缓存。
            # 刷新https即可，http会跟着变。
            echo "https://$domain/$target" >> $tmp_dir/refresh.portal.txt
        fi
    done
done
cd $top_dir
qshell cdnrefresh $tmp_dir/refresh.portal.txt
echo 'the end'
