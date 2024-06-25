#!/bin/bash

set -e

IMAGE=$1
DESTINATION=$2

function usage() {
    echo "Usage:  <image> <destination>"
}

if [ -z "$IMAGE" ]; then
    usage
    exit 1
fi

if [ ! -d "$DESTINATION" ]; then
    # 等待用户输入一个目录
    while true; do
    read -p "Enter a directory to save the files: " DESTINATION
    if [ -d "$DESTINATION" ]; then
        break
    fi
    echo "Invalid directory. Please enter a valid directory."
    done
fi

function random() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1
}

# 判断destination是文件夹
echo "pulling image: $IMAGE"

docker pull $IMAGE

container_name="download-copy-$(random)"

docker create --name "$container_name" $IMAGE

FILE_LIST=$(docker inspect --format '{{ index .Config.Labels "files" }}' $IMAGE)

if [ "$FILE_LIST" != "" ]; then
    # 获取镜像tag files
    while read -r line; do
        docker cp "$container_name":/$line "$DESTINATION/$line"
    done <<< $(echo "${FILE_LIST}" | tr ';' '\n')
fi

docker rm -f "$container_name"
