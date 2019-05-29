#!/bin/bash
# example: ./etcd.sh etcd01 172.16.194.128 etcd01=https//172.16.194.128:2380,etcd02=https://172.16.194.129:2380,etcd03=https://172.16.194.130:2380

ETCD_NAME=${1:-"etcd01"}  #etcd当前节点的名称
ETCD_IP=${2:-"127.0.0.1"}   # etcd当前节点的ip
ETCD_CLUSTER=${3:-"etcd01=http://127.0.0.1:2379"}  # 填写etcd集群的所有节点

WORK_DIR=/opt/etcd

cat <<EOF >${WORK_DIR}/cfg/etcd
#[Member]
ETCD_NAME="${ETCD_NAME}"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://${ETCD_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${ETCD_IP}:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ETCD_IP}:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_IP}:2379"
ETCD_INITIAL_CLUSTER="${ETCD_CLUSTER}"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

cat <<EOF >/usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=-${WORK_DIR}/cfg/etcd
ExecStart=${WORK_DIR}/bin/etcd \\
--name=\${ETCD_NAME} \\
--data-dir=\${ETCD_DATA_DIR} \\
--listen-peer-urls=\${ETCD_LISTEN_PEER_URLS} \\
--listen-client-urls=\${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \\
--advertise-client-urls=\${ETCD_ADVERTISE_CLIENT_URLS} \\
--initial-advertise-peer-urls=\${ETCD_INITIAL_ADVERTISE_PEER_URLS} \\
--initial-cluster=\${ETCD_INITIAL_CLUSTER} \\
--initial-cluster-token=\${ETCD_INITIAL_CLUSTER_TOKEN} \\
--initial-cluster-state=new \\
--cert-file=${WORK_DIR}/ssl/server.pem \\
--key-file=${WORK_DIR}/ssl/server-key.pem \\
--peer-cert-file=${WORK_DIR}/ssl/server.pem \\
--peer-key-file=${WORK_DIR}/ssl/server-key.pem \\
--trusted-ca-file=${WORK_DIR}/ssl/ca.pem \\
--peer-trusted-ca-file=${WORK_DIR}/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
