#!/bin/sh

# Global variables
DIR_CONFIG="/etc/mysevv"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

cat << EOF > ${DIR_TMP}/mysevv.json
{
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vless",
        "settings": {
            "clients": [{
                "id": "${ID}"
            }],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "${WSPATH}"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/v2fly/v2ray-core/releases/latest/download/linux-64.zip -o ${DIR_TMP}/dist.zip
busybox unzip ${DIR_TMP}/dist.zip -d ${DIR_TMP}

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/ctl config ${DIR_TMP}/mysevv.json > ${DIR_CONFIG}/config.pb

install -m 755 ${DIR_TMP}/bbb ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

${DIR_RUNTIME}/mysevv -config=${DIR_CONFIG}/config.pb
