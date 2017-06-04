#!/bin/bash
set -e
top_dir=$(cd `dirname $0`; pwd)
echo $top_dir
dl_dir=$top_dir/dl
mkdir -p $dl_dir
tmp_dir=$top_dir/tmp
mkdir -p $tmp_dir
source $top_dir/gmirror.conf

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

favicon_html=""
if [ ! -z $favicon ] && [ "x"$favicon != "x" ]; then
    favicon_html='<link rel="icon" type="image/vnd.microsoft.icon" href="'$favicon'" />'
fi

zhuge_html=""
if [ ! -z $zhuge_app_key ] && [ "x"$zhuge_app_key != "x" ]; then
    zhuge_html='<script>window.zhuge=window.zhuge||[];window.zhuge.methods="_init debug identify track trackLink trackForm page".split(" ");window.zhuge.factory=function(b){return function(){var a=Array.prototype.slice.call(arguments);a.unshift(b);window.zhuge.push(a);return window.zhuge}};for(var i=0;i<window.zhuge.methods.length;i++){var key=window.zhuge.methods[i];window.zhuge[key]=window.zhuge.factory(key)};window.zhuge.load=function(b,x){if(!document.getElementById("zhuge-js")){var a=document.createElement("script");a.type="text/javascript";a.id="zhuge-js";a.async=!0;a.src="https://zgsdk.37degree.com/zhuge-lastest.min.js";var c=document.getElementsByTagName("script")[0];c.parentNode.insertBefore(a,c);window.zhuge._init(b,x)}};window.zhuge.load(\"'$zhuge_app_key'\");</script>'
fi

google_analytics_html=""
if [ ! -z $google_analytics ] && [ "x"$google_analytics != "x" ]; then
    google_analytics_html="<script>(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){ (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o), m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m) })(window,document,'script','//www.google-analytics.com/analytics.js','ga'); ga('create', \''"$google_analytics"'\', 'auto'); ga('send', 'pageview');</script>"
fi

qshell account $QINIU_ACCESS_KEY $QINIU_SECRET_KEY
echo "" > $tmp_dir/refresh.dl.txt
echo "{\"src_dir\": \"$dl_dir\", \"bucket\": \"$qiniu_bucket\" }" > $tmp_dir/qupload.dl.json

dirs=`ls -R $dl_dir | grep ':' | awk -F: '{print $1}'`
for dir in $dirs; do
    echo $dir
    cd $dir
    auto_index_md=0
    if [ ! -f index.md ]; then
        auto_index_md=1
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
                rm files.md
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
    marked index.md > tmp-index-part.html
    if [ $auto_index_md -eq 1 ]; then
        rm index.md
        echo 1;
    fi

    # sed不支持多行文本，所以要先把换行符去掉
    sed -i ':a;N;s/\n//;ta' tmp-index-part.html
    sed -i "s|<table>|<table class=\"pure-table pure-table-striped pure-table-horizontal\">|g" tmp-index-part.html
    sed -e 's/^/s|{body}|/' -e 's/$/|g/' tmp-index-part.html > tmp-sed.sh
    dl_dir_for_sed=${dl_dir//\//\\/}
    path=`pwd | sed -e "s|$dl_dir_for_sed||"`
    path_for_sed=${path//\//\\/}
    sed -e "s|</title>|</title>$favicon_html|g" -e "s#</body>#$google_analytics_html</body>#g" -e "s#</head>#$zhuge_html</head>#g" $top_dir/tpl.html -e "s|{title}|Index of $path_for_sed/|g" > index.html
    sed -i -f tmp-sed.sh index.html
    rm tmp-*
    qiniu_prefix=${path:1}"/"
    if [ $qiniu_prefix = "/" ]; then
        qiniu_prefix=""
    fi
    echo http://$qiniu_domain/"$qiniu_prefix" >> $top_dir/refresh.dl.txt
done
# 上传所有文件
cd $top_dir
qshell qupload $tmp_dir/qupload.dl.json
qshell cdnrefresh $tmp_dir/refresh.dl.txt
echo 'the end'
