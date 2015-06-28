#!/bin/bash
set -e
top_dir=$(cd `dirname $0`; pwd)
echo $top_dir
dl_dir=$top_dir/dl
source $top_dir/dl.conf

# 来自环境变量
u=$qiniu_user
p=$qiniu_passwd

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

# 生成index.html
qrsctl login $qiniu_user $qiniu_passwd

dirs=`ls -R $dl_dir | grep ':' | awk -F: '{print $1}'`
for dir in $dirs; do
    if [ `basename $dir` = 'qiniu' ]; then
        continue
    fi
    echo $dir
    cd $dir
    auto_index_md=0
    if [ ! -f index.md ]; then
        auto_index_md=1
        auto_files_md=0
        if [ ! -f dirs_and_files.md ]; then
            auto_dirs_and_files_md=1
            if [ ! -f dirs.md ]; then
                auto_dirs_md=1
                echo 'filename|size|md5' > dirs.md
                echo '--------|----|---' >> dirs.md
                tmp_lines=`ls --group-directories-first`
                for filename in $tmp_lines; do
                    if [ -d $filename ]; then
                        filename="$filename""/"
                        filename_for_markdown=${filename//_/\\_}
                        filename_for_sed=${filename_for_markdown//\//\\/}
                        echo $filename_for_markdown'||' >> dirs.md
                    fi
                done
            fi
            cp dirs.md dirs_and_files.md
            if [ $auto_dirs_md -eq 1 ]; then
                rm dirs.md
            fi
            if [ -f files.md ]; then
                tail -n +3 files.md >> dirs_and_files.md
            fi
        fi

        head -n 2 dirs_and_files.md > index.md
        if [ $dir != $dl_dir ]; then
            echo '[../](../)|' >> index.md
        fi
        tail -n +3 dirs_and_files.md | while read line; do
            filename=`echo $line | awk -F\| '{print $1}'`
            filename_for_markdown=${filename//_/\\_}
            part2=`echo $line | awk -F\| '{print $2}'`
            part3=`echo $line | awk -F\| '{print $3}'`
            # 把文件名都改成链接
            echo '['$filename_for_markdown']('$filename_for_markdown')|'$part2'|'$part3 >> index.md
        done
        if [ $auto_dirs_and_files_md -eq 1 ]; then
            rm dirs_and_files.md
        fi
    fi

    #空格是为了可读性，机器不需要，所以把空格删除
    sed -i 's/ | /|/g' index.md

    # sudo apt-get install discount
    markdown index.md > tmp-index-part.html
    if [ $auto_index_md -eq 1 ]; then
        rm index.md
    fi

    # sed不支持多行文本，所以要先把换行符去掉
    tmp=`cat tmp-index-part.html | tr '\n' '\f'`
    body=`echo $tmp | sed -e "s|<table>|<table class=\"pure-table pure-table-striped pure-table-horizontal\">|g"`
    rm tmp-*
    dl_dir_for_sed=${dl_dir//\//\\/}
    path=`pwd | sed -e "s|$dl_dir_for_sed||"`
    path_for_sed=${path//\//\\/}
    sed -e "s|{title}|Index of $path_for_sed/|g" -e "s|{body}|$body|g" $top_dir/tpl.html | tr '\f' '\n' > index.html
    qiniu_prefix=${path:1}"/"
    if [ $qiniu_prefix = "/" ]; then
        qiniu_prefix=""
    fi
    echo $qiniu_prefix
    # 把index.html上传到 七牛的xxx/，用于列表服务
    qrsctl put $bucket "$qiniu_prefix" index.html
    qrsctl cdn/refresh $bucket http://$domain/$qiniu_prefix
    rm index.html
done
