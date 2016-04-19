#!/bin/bash
top_dir=$(cd `dirname $0`; pwd)
echo $top_dir
source $top_dir/portal.conf
dl_dir=$top_dir/dl
cp $top_dir/docs/index.tpl.md $top_dir/docs/index.md

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
        while IFS='|' read -ra tmp; do
            for part in "${tmp[@]}"; do
            part="$(sed -e 's/[[:space:]]*$//' <<<${part})"
            echo $part
            #第1列是product
            if [ $i -eq 0 ]; then
                product=$part
            elif [ $i -eq 1 ]; then
                #第2列是os
                os=$part
            elif [ $i -eq 2 ]; then
                #第3列是下载地址
                uri=$part
                origin_filename=`basename $uri`
                filename=$origin_filename
                uri_nopro=${part#*//}
                target_path=${uri_nopro#*/}
            elif [ $i -eq 3 ]; then
                #第4列是文件名或路径，如果不写，将使用下载地址里相同的文件名。如果为/dev/null，则不下载。
                if [ $part = '/dev/null' ]; then
                    target_path=$part
                else
                    filename=`basename $part`
                    target_path=${relative_dir#*/}/$part
                    if [ $relative_dir == '/' ]; then
                        target_path=$part
                    fi
                fi
            fi
            i=$(($i+1))
        done
        done <<< "$line"
        echo $product
        tmp=`grep -n {$product} $top_dir/docs/index.md`
        if [ $? -ne 0 ]; then
            continue
        fi
        line_num=`grep -n {$product} $top_dir/docs/index.md | cut -d : -f 1`
        echo $line_num
        #sed -i "/{$product}/i$th" $top_dir/docs/index.md
        origin_domain=`echo $uri | awk -F '/' '{print $3}'`
        tr="$os | $filename | [$origin_domain]($uri) |"
        if [ $target_path != '/dev/null' ]; then
            tr=$tr" [$dl_domain](http://$dl_domain/$target_path)"
        fi
        echo $tr
        #sed -i "|{$product}|a$tr" $top_dir/docs/index.md
        sed -i "$line_num a$tr" $top_dir/docs/index.md
    done
    j=0
    for line_num in `grep -n {*} $top_dir/docs/index.md | cut -d : -f 1`; do
        tmp_num=$(($line_num+$j))
        th='系统 | 文件名 | 官网下载 | CDN下载'
        sed -i "$tmp_num i$th" $top_dir/docs/index.md
        j=$(($j+1))
    done
    for line_num in `grep -n {*} $top_dir/docs/index.md | cut -d : -f 1`; do
        th='-----|--------|----------|--------'
        sed -i "$line_num s/.*/$th/" $top_dir/docs/index.md
    done

done
cd $top_dir
mkdocs build --clean
grep -lr "href='https://fonts.googleapis.com/" ./site | xargs sed -i "s/href='https:\/\/fonts\.googleapis\.com/href='http:\/\/fonts.gmirror.org/g"
echo 'the end'
exit
