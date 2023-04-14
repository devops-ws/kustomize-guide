#!/bin/bash

function syncToLocalServer() {
    kustomize build config/external | grep image: | sed -e "s/-\ image: //" | sed -e "s/image: //" | sed -e "s/\s*//" | sort | uniq > bin/image.txt

    while read -r line
    do
        if [[ "$line" =~ ^10.121.218.184:30002/quay.io.* ]]; then
            source=$(echo $line | sed -e "s/10.121.218.184:30002\///")
            echo "start to sync from $source to $line"
            docker pull $source
            docker tag $source $line
            docker push $line
        elif [[ "$line" =~ ^10.121.218.184:30002/ghcr.io.* ]]; then
            source=$(echo $line | sed -e "s/10.121.218.184:30002\///")
            echo "start to sync from $source to $line"
            docker pull $source
            docker tag $source $line
            docker push $line
        fi
    done < bin/image.txt
}


function saveToTar() {
    kustomize build config/external | grep image: | sed -e "s/-\ image: //" | sed -e "s/image: //" | sed -e "s/\s*//" | sort | uniq > bin/image.txt

    while read -r line
    do
        echo "start to save $line"
        docker pull $line
        docker image save $line -o bin/$(echo $line | sed -e "s/.*\///" | sed -e "s/:.*//").tar.gz
    done < bin/image.txt
}

if [ "$1" == 'sync' ]; then
    syncToLocalServer
elif [ "$1" == 'save' ]; then
    saveToTar
else
  echo "Usage: image_sync.sh [save|sync]"
  exit 1
fi

