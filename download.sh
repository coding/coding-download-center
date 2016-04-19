#!/bin/bash
top_dir=$(cd `dirname $0`; pwd)
echo $top_dir
source $top_dir/gmirror.conf
dl_dir=$top_dir/dl

has_numfmt=0
which numfmt
if [ $? -eq 0 ]; then
    has_numfmt=1
fi
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
        http_code=200
        md5=""
        expected_md5=""
        echo -e "\n"$line
        while IFS='|' read -ra tmp; do
            for part in "${tmp[@]}"; do
            part="$(sed -e 's/[[:space:]]*$//' <<<${part})"
            echo $part
            if [ $i -eq 2 ]; then
                #第3列是下载地址
                uri=$part
                origin_filename=`basename $uri`
                filename=$origin_filename
                echo 'filename '$filename
                uri_nopro=${part#*//}
                target_path=${uri_nopro#*/}
                echo 'ttt '$target_path
            elif [ $i -eq 3 ]; then
                #第3列是文件名或路径，如果为空的话，将使用下载地址里相同的文件名
                if [ $part = '/dev/null' ]; then
                    continue;
                fi
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
        done <<< "$line"
        target_dir=""
        if [ $target_path != $filename ]; then
            target_dir=${target_path%/*}
            mkdir -p $target_dir
        fi
        if [ $target_path = $filename ]; then
            target_path=${relative_dir#*/}/$filename
        fi
        echo 'target_path '$target_path
        echo 'target_dir '$target_dir
        if [ ! -f $dl_dir/$target_dir/files.md ]; then
            echo 'filename|size|md5' > $dl_dir/$target_dir/files.md
            echo '--------|----|---' >> $dl_dir/$target_dir/files.md
        fi

        echo "check http://$qiniu_domain/$target_path"
        header=`curl -sI "http://$qiniu_domain/$target_path"`
        if [ $? -ne 0 ]; then
            exit 500
        fi
        http_code=`echo "$header" | head -n 1 | awk '{print $2}'`
        echo $http_code
        if [ $http_code -eq 200 ]; then
            size_byte=`echo "$header" | grep "Content-Length" | awk '{print $2}' | tr -d '\r'`
        fi
        if [ $http_code -ne 200 ]; then
            if [ ! -f $dl_dir/$target_path ]; then
                echo "Downloading..."
                if [ ${uri:0:27} = "http://download.oracle.com/" ]; then
                    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O $dl_dir/$target_path "$uri"
                else
                    wget -O $dl_dir/$target_path "$uri"
                fi
            fi
            if [ $? -ne 0 ]; then
                exit 404
            fi
            size_byte=`ls -l $dl_dir/$target_path | awk '{print $5}'`
            md5=`md5sum $dl_dir/$target_path | awk '{print $1}'`
        fi
        if [ $has_numfmt -eq 1 ]; then
            size=`echo $size_byte | numfmt --to=iec-i --suffix=B --padding=7`
        else
            size=$size_byte
        fi

        filename_for_markdown=${filename//_/\\_}
        grep "$filename_for_markdown"'|' $dl_dir/$target_dir/files.md
        if [ $? -ne 0 ]; then
            echo "$filename_for_markdown"'|'$size'|'$md5 >> $dl_dir/$target_dir/files.md
        fi
    done
done
echo 'the end'
exit
