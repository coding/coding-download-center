#!/bin/bash
set -ev

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
top_path=$(cd `dirname $0`; pwd)

$top_path/qiniu/qrsctl login $qiniu_user $qiniu_passwd

echo $top_path
dirs=`ls -R $top_path | grep ':' | awk -F: '{print $1}'`
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
        if [ ! -f files.md ]; then
            auto_files_md=1
            echo 'filename|size' > files.md
            echo '--------|----' >> files.md
            tmp_lines=`ls --group-directories-first`
            for filename in $tmp_lines; do
                if [ -d $filename ]; then
                    size=''
                    filename="$filename""/"
                else
                    size=`ls -lh $filename | awk '{print $5}'`
                fi
                if [ $filename = 'files.md' ] || [ $filename = 'origin.md' ] || [ $filename = 'index.html' ] || [ $filename = 'index.md' ] || [ $filename = 'README.md' ]; then
                    continue
                fi
                echo $filename'|'$size >> files.md
            done
        fi
        thead_line_num=`grep -n "\-|\-" files.md | awk -F: '{print $1}'`
        head -n $thead_line_num files.md > index.md
        if [ $dir != $top_path ]; then
            echo '[../](../)|' >> index.md
        fi
        offset=$(($thead_line_num+1))
        tail -n +$offset files.md | while read line; do
            filename=`echo $line | awk -F\| '{print $1}'`
            part2=`echo $line | awk -F\| '{print $2}'`
            # 把文件名都改成链接
            echo '['$filename']('$filename')|'$part2 >> index.md
        done
        if [ $auto_files_md -eq 1 ]; then
            rm files.md
        fi
        #空格是为了可读性，机器不需要，所以把空格删除
        sed -i 's/ | /|/g' index.md
    fi

    # sudo apt-get install discount
    markdown index.md > tmp-index-part.html
    if [ $auto_index_md -eq 1 ]; then
        rm index.md
    fi

    # sed不支持多行文本，所以要先把换行符去掉
    tmp=`cat tmp-index-part.html | tr '\n' '\f'`
    body=`echo $tmp | sed -e "s|<table>|<table class=\"pure-table pure-table-striped pure-table-horizontal\">|g"`
    rm tmp-*
    path=`pwd | sed -e "s|$top_path||"`
    sed -e "s|{title}|Index of $path/|g" -e "s|{body}|$body|g" $top_path/tpl.html | tr '\f' '\n' > index.html
    if [ $dir = $top_path ]; then
        # 首页有标题，不需要这个标题
        sed -i '/<h1>Index of \/<\/h1>/d' index.html
        title=`grep '<h1>' index.html | sed -e 's|h1|title|g'`
        sed -i "s|<title>Index of /</title>|$title|g" index.html
    fi
    qiniu_prefix=${path:1}"/"
    if [ $qiniu_prefix = "/" ]; then
        qiniu_prefix=""
    fi
    echo $qiniu_prefix
    # 把index.html上传到 七牛的xxx/，用于列表服务
    $top_path/qiniu/qrsctl put dl-gmirror-org "$qiniu_prefix" index.html
    $top_path/qiniu/qrsctl cdn/refresh dl-gmirror-org http://dl.gmirror.org/$qiniu_prefix
    rm index.html
done
