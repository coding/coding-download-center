#!/bin/bash
set -e

if [ "$CODING_GENERIC_REGISTRY" = "" ]; then
    echo "WARNING: env CODING_GENERIC_REGISTRY not set, use default value"
    CODING_GENERIC_REGISTRY="https://coding-public-generic.pkg.coding.net/public/downloads/"
fi
if [ "$CODING_ARTIFACTS_USERNAME" = "" ]; then
    echo "WARNING: env CODING_ARTIFACTS_USERNAME not set, only run check and download"
fi

top_dir=$(cd `dirname $0`; pwd)
dl_dir=$top_dir/dl
mkdir -p "$dl_dir"

index_file="$top_dir/index.md"
thead_line_num=$(grep -n "\-|\-" "$index_file" | awk -F: '{print $1}')
offset=$(($thead_line_num+1))
tail -n +$offset "$index_file" | while read line; do
    i=0
    http_code=200
    sha256=""
    while IFS='|' read -ra tmp; do
        for part in "${tmp[@]}"; do
        part=$(echo "${part}" | tr -d '[:space:]')
        if [ $i -eq 0 ]; then
            package=$part
            printf "\n%s\n" "$package"
            file_prefix=$(echo "${part%%.*}")
            file_suffix=""
            if [[ $part == *"."* ]]; then
                file_suffix="."`echo ${part#*.}`
            fi
        elif [ $i -eq 1 ]; then
            version=$part
            filename=$file_prefix-$version$file_suffix
        elif [ $i -eq 2 ]; then
            uri=$part
        elif [ $i -eq 3 ]; then
            sha256=$part
            echo "$sha256 $dl_dir/$filename" > "$dl_dir/$filename.sha256sum"
        fi
        i=$(($i+1))
    done
    done <<< "$line"

    http_code=404
    if [ "$CODING_GENERIC_REGISTRY" != "" ]; then
        mirror_full_url="${CODING_GENERIC_REGISTRY}$package?version=$version"
        echo "check $mirror_full_url"
        header=$(curl -sI "$mirror_full_url")
        http_code=$(echo "$header" | head -n 1 | awk '{print $2}')
        if [ "$http_code" -eq 200 ]; then
            echo "skip: file exists on mirror"
        fi
    fi
    if [ "$http_code" -ne 200 ]; then
        if [ -f "$dl_dir/$filename" ] && sha256sum -c "$dl_dir/$filename.sha256sum"; then
            echo "skip: file exists on local"
        else
            wget -O "$dl_dir/$filename" "$uri"
            sha256sum -c "$dl_dir/$filename.sha256sum"
        fi
        # coding-generic 自带校验功能，上传成功即可，无需再下载校验。
        if [ "$CODING_GENERIC_REGISTRY" != "" ] \
            && [ "$CODING_ARTIFACTS_USERNAME" != "" ] \
            && [ "$CODING_ARTIFACTS_PASSWORD" != "" ]; then
            coding-generic --username="${CODING_ARTIFACTS_USERNAME}:${CODING_ARTIFACTS_PASSWORD}" \
            --path="${dl_dir}/${filename}" \
                --registry="${CODING_GENERIC_REGISTRY}chunks/${package}?version=${version}"
        fi
    fi
done
echo 'the end'
