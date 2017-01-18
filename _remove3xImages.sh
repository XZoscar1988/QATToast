# Readme
# 您需要先安装jq（shell json处理）
# brew install jq
# 用法：sh _remove3xImages.sh asset目录绝对路径

#!/bin/sh

set -e

function parasValidate {
    if [ "${1}" = "" ]; then
        echo "请指定操作路径，作为第一个参数"
        exit 0
    fi
}

parasValidate "${1}"

function removePNG {
    iteor="${1}"
    afile="${iteor%@*}@2x.png"

    #如果有@2x的删除xxx.png 和xxx@3x.png
    if [ -f "${afile}" ] ; then

        echo "处理中...\n"
        #echo "${iteor%@*}\n"
        aname="${iteor%@*}"

        rm -fr "${iteor%@*}@3x.png"
        rm -fr "${iteor%@*}.png"

        #
        ajson="${iteor%/*}"
        modifyContentJson "${ajson}/Contents.json" "${aname##*/}"
    fi
}

function modifyContentJson {
    filename="${2}@2x.png"

    ajson=`jq 'del(.images[] | select(.scale == "3x"))' "${1}"`

    echo "${ajson}" > "${1}"
}

function removeImagesAtDir {

        parasValidate "${1}"

        for iteor in $(ls -1 "${1}"|awk '{print i$0}' i="${1}"'/')
        do
            if [ -f "${iteor}" ] ; then
                if [ "${iteor##*.}" = "png" ] ; then
                    removePNG "${iteor}"
                fi
            elif [ -d "${iteor}" ]; then
                removeImagesAtDir "${iteor}"
            fi
        done
}

removeImagesAtDir "${1}"
exit 0

