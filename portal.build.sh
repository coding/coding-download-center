#!/bin/bash
top_dir=$(cd `dirname $0`; pwd)
echo $top_dir
source $top_dir/portal.conf
dl_dir=$top_dir/dl
cp $top_dir/portal/index.tpl.html $top_dir/portal/index.html

cd $dl_dir
files=`find $dl_dir -name 'origin.md'`
for file in $files; do
    absolute_dir=`dirname $file`
    echo 'absolute_dir '$absolute_dir
    relative_dir=`echo $file | sed -e "s|$dl_dir||" | xargs dirname`
    echo 'relative_dir '$relative_dir

    thead_line_num=`grep -n "\-|\-" $file | awk -F: '{print $1}'`
    offset=$(($thead_line_num+1))
    tail -n +$offset $file | while read line; do
        i=0
        new_line=""
        echo -e "\n"$line
        for part in `echo $line | sed 's/|/ /g'`; do
            echo $part
            #第1列是id
            if [ $i -eq 0 ]; then
                id=$part
            elif [ $i -eq 1 ]; then
                #第2列必须是下载地址
                uri=$part
                origin_filename=`basename $uri`
                filename=$origin_filename
                echo 'filename '$filename
                uri_nopro=${part#*//}
                target_path=${uri_nopro#*/}
                echo 'ttt '$target_path
            elif [ $i -eq 2 ]; then
                #第3列必须是文件名或路径，如果为空的话，将使用下载地址里相同的文件名
                filename=`basename $part`
                target_path=${relative_dir#*/}/$part
                echo 't2222 '$target_path
                if [ $relative_dir == '/' ]; then
                    target_path=$part
                fi
                echo 't333 '$target_path
            fi
            i=$(($i+1))
        done
        sed -i "s|{$id-filename}|$filename|g" $top_dir/portal/index.html
        origin_domain=`echo $uri | awk -F '/' '{print $3}'`
        sed -i "s|{$id-origin-uri}|$uri|g" $top_dir/portal/index.html
        sed -i "s|{$id-origin-domain}|$origin_domain|g" $top_dir/portal/index.html
        sed -i "s|{$id-gmirror-uri}|http://$dl_domain/$target_path|g" $top_dir/portal/index.html
        sed -i "s|{$id-gmirror-domain}|$dl_domain|g" $top_dir/portal/index.html
        continue;
    done
done
echo 'the end'
exit
