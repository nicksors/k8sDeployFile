#!/bin/bash

export SSL_DIR=/root/ssl/k8s-cret

# 创建用户“nicksors”证书
cat > nicksors-csr.json <<EOF
{
    "CN": "nicksors",
    "hosts": [],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "BeiJing",
            "ST": "BeiJing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
cfssl gencert -ca=${SSL_DIR}/ca.pem -ca-key=${SSL_DIR}/ca-key.pem -config=${SSL_DIR}/ca-config.json -profile=kubernetes nicksors-csr.json | cfssljson -bare nicksors
