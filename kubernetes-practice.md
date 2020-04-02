---
description: >-
  Здесь описывается что мне было интересно проверить и что я делал практически с
  кластером kubernetes
---

# Kubernetes Practice

### **1.Установка k8s в GCP \(Google Cloud Platform\)**

  
****За основу взят гайд [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way) для версии 1.15.3 переработанный под версию 1.17.  
OS - Centos 7.7  
Создаем проект в GCP.    
Имя проекта - kuberhard  
Устанавливаем tmux  
`brew install tmux`  
Основные комманды tmux, которые нам понадобятся:  
`^ + b <command>`  - общий шаблон  
&lt;command&gt;:  
`"` - разбить окна горизонтально  
`shift+:` - ввести что то в коммандную строку  
`set synchronize-panes on/off` - одновременный ввод комманд во всех tmux панелях  
`<up>,<down> keys` - перемещение между окнами  
  
Качаем google cloud SDK. Проверяем sdk:  
`gcloud auth login`  
  
Настраиваем дефолтную compute регион и зону:  
`gcloud config set compute/region europe-west3  
gcloud config set compute/zone europe-west3-a`  
Посмотреть все доступные зоны:  
`gcloud compute zones list`  
  
Устанавливаем cfssl и cfssljson для OS X:  
`wget https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/darwin/cfssl  
wget https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/darwin/cfssljson  
chmod +x cfssl cfssljson  
sudo mv cfssl cfssljson /usr/local/bin/`  
  
Устанавливаем kubectl для OS X:  
`curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/darwin/amd64/kubectl  
chmod +x kubectl  
sudo mv kubectl /usr/local/bin/`  
  
Создаем виртуальную частную сеть \(VPC\):  
`--subnet-mode custom` - означает что мы создаем VPC без подсетей с предопределенными IP адрессами.   
`--range` - говорит о том какой именно диапазон IP адрессов мы хотим выделить нашей подсети.  
`--source-ranges` - говорит о том что мы позволяем весь траффик по протоколам и портам указанным в `--allow` с диапазона этих IP адрессов.  
  
`gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom   
  
gcloud compute networks subnets create kubernetes  --network kubernetes-the-hard-way --range 10.240.0.0/24  
  
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal --allow tcp,udp,icmp --network kubernetes-the-hard-way --source-ranges 10.240.0.0/24,10.200.0.0/16`  
  
`gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external --allow tcp:22,tcp:6443,icmp --network  kubernetes-the-hard-way --source-ranges 0.0.0.0/0`  
  
Смотрим правила фаерволла внутри нашей VPC:  
`--filter` - применяет логическое выражение, если оно true, то показываются только эти результаты  
`--filter="some_column:some_value"` - вернет все строки из столбца `some_column` у которых есть `some_value` в имени  
  
`gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"`  
  
Выделяем статические IP что будут назначены для внешнего балансировщика нагрузки:  
`gcloud compute addresses create kubernetes-the-hard-way --region $(gcloud config get-value compute/region)`  
  
Проверяем что они были созданы в нашем регионе:  
`gcloud compute addresses list --filter="name:kubernetes-the-hard-way"`  
  
Создаем вычислительные ресурсы для k8s контроллеров:  
`for i in 0 1 2; do   
gcloud compute instances create controller-${i}` `--async --boot-disk-size 200GB --can-ip-forward --image-family centos-7-v20200309 --image-project centos-cloud --machine-type n1-standard-1 --private-network-ip 10.240.0.1${i} --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring --subnet kubernetes --tags kubernetes-the-hard-way,controller  
done`  
  
Создаем вычислительные ресурсы для k8s воркеров:  
`for i in 0 1 2;   
do gcloud compute instances create worker-${i} --async --boot-disk-size 200GB --can-ip-forward --image-family centos-7-v20200309 --image-project centos-cloud --machine-type n1-standard-1 --metadata pod-cidr=10.200.${i}.0/24 --private-network-ip 10.240.0.2${i} --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring --subnet kubernetes --tags kubernetes-the-hard-way,worker`  
`done`

Резервирование CA и генерация сертификатов  
Создаем CA конфиг файл, сертификат и частный ключ:

```text
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RB",
      "L": "Minsk",
      "O": "Kubernetes",
      "OU": "Minsk",
      "ST": "Minsk"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca
ls ca-key.pem ca-key.pem
```

Сгенерируем клиентский и серверный сертификат для компонентов k8s и клиентский сертификат для admin пользователя k8s:  
Клиентский сертификат `admin` и частный ключ:

```text
cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RB",
      "L": "Minsk",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Minsk"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

ls admin.pem admin-key.pem admin.csr
```

Клиентский сертификат `kubelet` и частный ключ:

```text
for instance in worker-0 worker-1 worker-2; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RB",
      "L": "Minsk",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Minsk"
    }
  ]
}
EOF

EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

INTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].networkIP)')

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done
ls worker*pem
```

Клиентский сертификат `controller manager` и частный ключ:

```text
cat > kube-controller-manager-csr.json << EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RB",
      "L": "Minsk",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "Minsk"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

ls kube-controller*pem
```

Клиентский сертификат `kube proxy` и частный ключ:

```text
cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RB",
      "L": "Minsk",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Minsk"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
  
ls kube-proxy*pem
```

Клиентский сертификат `kube scheduler` и частный ключ:

```text
cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RB",
      "L": "Minsk",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "Minsk"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
  
ls kube-scheduler*pem
```

Клиентский сертификат `kube API server` и частный ключ:

```text
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RB",
      "L": "Minsk",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Minsk"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
  
ls kubernetes*pem
```

Клиентский сертификат `Service Account Key` и частный ключ:

```text
cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
  
ls service-account*pem
```

Распределим клиентские сертификаты по рабочим нодам:  
`for instance in worker-0 worker-1 worker-2;`  
`do gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/   
done`  
Распределим клиентские сертификаты по нодам контроллеров:  
`for instance in controller-0 controller-1 controller-2;  
do gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem  service-account-key.pem service-account.pem ${instance}:~/   
done`

Генерация конфиг. файлов для аутентификации `kubelet`

```text
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

```

Генерация конфиг. файлов для аутентификации `kube-proxy`

```text
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
```

Генерация конфиг. файлов для аутентификации `kube-controller-manager`

```text
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
```

Генерация конфиг. файлов для аутентификации `kube-scheduller`

```text
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
```

Генерация конфиг. файлов для пользователя `admin`

```text
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig
```

Распределим `kubelet`  и `kube-proxy` конфиги по рабочим нодам:  
`for instance in worker-0 worker-1 worker-2;`   
`do gcloud compute scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/  
done`  
Распределим `admin` ,`kube-controller-manager`  и `kube-scheduler` конфиги по контроллер нодам:  
`for instance in controller-0 controller-1 controller-2;`   
`do gcloud compute scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/  
done`  


Создадим Encryption config and key:  
Создадим ключ:  
`ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)`  
  
Создадим encryption-config.yaml конфиг и скопируем его на все контроллер ноды:

```text
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp encryption-config.yaml ${instance}:~/
done
```

Изначальная генерация \(bootstrapping\) etcd кластера:  
Используя комманды tmux выше, создаем 3 панели и синхронно вводим в них следующие комманды:

```text
wget -q --show-progress --https-only --timestamping "https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz"

tar -xvf etcd-v3.4.0-linux-amd64.tar.gz --warning=no-unknown-keyword
sudo mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/

sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
    
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)     
      
ETCD_NAME=$(hostname -s)

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \
  --name ${ETCD_NAME} \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \
  --listen-peer-urls https://${INTERNAL_IP}:2380 \
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://${INTERNAL_IP}:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster controller-0=https://10.240.0.10:2380,controller-1=https://10.240.0.11:2380,controller-2=https://10.240.0.12:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF   

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
```

http://metadata.google.internal - внутренний metadata сервер GCP

Проверка etcd кластера:

```text
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
```

**Bootstrapping контрольной плоскости \(control plane\) кластера:**  
В tmux выполняем следующие комманды

```text
sudo mkdir -p /etc/kubernetes/config
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl"
  
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/ 
  
sudo mkdir -p /var/lib/kubernetes/

sudo mv ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
 service-account-key.pem service-account.pem \
 encryption-config.yaml /var/lib/kubernetes/ 
  
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://10.240.0.10:2379,https://10.240.0.11:2379,https://10.240.0.12:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv kube-controller-manager.kubeconfig /var/lib/kubernetes/

cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv kube-scheduler.kubeconfig /var/lib/kubernetes/

cat <<EOF | sudo tee /etc/kubernetes/config/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
```

Включение HTTP проверок здоровья кластера \(health checks\):

```text
sudo apt-get update
sudo apt-get install -y nginx

cat > kubernetes.default.svc.cluster.local <<EOF
server {
  listen      80;
  server_name kubernetes.default.svc.cluster.local;

  location /healthz {
     proxy_pass                    https://127.0.0.1:6443/healthz;
     proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
  }
}
EOF

sudo mv kubernetes.default.svc.cluster.local \
    /etc/nginx/sites-available/kubernetes.default.svc.cluster.local

sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/

sudo systemctl restart nginx
sudo systemctl enable nginx
```

Проверка health checks:

```text
kubectl get componentstatuses --kubeconfig admin.kubeconfig

curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz
```

Проверка RBAC для авторизации`kubelet`   
Создаем `system:kube-apiserver-to-kubelet` кластерную роль с привилегиями необходимыми для доступа к k8s API и выполнения основных задач управления подами

```text
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF
```

Связываем \(binding\) эту роль с пользователем `kubernetes`

```text
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF
```

Настройка Frontend балансировщика нагрузки:

```text
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

gcloud compute http-health-checks create kubernetes \
    --description "Kubernetes Health Check" \
    --host "kubernetes.default.svc.cluster.local" \
    --request-path "/healthz"

gcloud compute firewall-rules create kubernetes-the-hard-way-allow-health-check \
    --network kubernetes-the-hard-way \
    --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
    --allow tcp

gcloud compute target-pools create kubernetes-target-pool \
    --http-health-check kubernetes

gcloud compute target-pools add-instances kubernetes-target-pool \
   --instances controller-0,controller-1,controller-2

gcloud compute forwarding-rules create kubernetes-forwarding-rule \
    --address ${KUBERNETES_PUBLIC_ADDRESS} \
    --ports 6443 \
    --region $(gcloud config get-value compute/region) \
    --target-pool kubernetes-target-pool
```

Проверка работы балансировщика:

```text
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

curl --cacert ca.pem https://$KUBERNETES_PUBLIC_ADDRESS:6443/version
```

**Bootstrapping рабочих нод кластера:**  
Выполним некоторые пререквизиты и скачаем бинарники

```text
sudo apt-get update
sudo apt-get -y install socat conntrack ipset
sudo swapon --show
sudo swapoff -a

wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.15.0/crictl-v1.15.0-linux-amd64.tar.gz \
  https://github.com/opencontainers/runc/releases/download/v1.0.0-rc8/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz \
  https://github.com/containerd/containerd/releases/download/v1.2.9/containerd-1.2.9.linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubelet

sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

mkdir containerd
tar -xvf crictl-v1.15.0-linux-amd64.tar.gz
tar -xvf containerd-1.2.9.linux-amd64.tar.gz -C containerd
sudo tar -xvf cni-plugins-linux-amd64-v0.8.2.tgz -C /opt/cni/bin/
sudo mv runc.amd64 runc
chmod +x crictl kubectl kube-proxy kubelet runc 
sudo mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
sudo mv containerd/bin/* /bin/
```

Сконфигурируем сеть \(CNI\)

```text
POD_CIDR=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/pod-cidr)
cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.3.1",
    "name": "lo",
    "type": "loopback"
}
EOF

sudo mkdir -p /etc/containerd/

cat << EOF | sudo tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
EOF

cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF
```

Сконфигурируем `kubelet`

```text
sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv ca.pem /var/lib/kubernetes/

cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF

cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig

cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable containerd kubelet kube-proxy
sudo systemctl start containerd kubelet kube-proxy
```

Проверка состояних рабочих нод:

```text
gcloud compute ssh controller-0 \
  --command "kubectl get nodes --kubeconfig admin.kubeconfig"
```

**Конфигурирование kubectl для удаленного доступа:**

```text
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem

kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

kubectl config use-context kubernetes-the-hard-way

kubectl get componentstatuses

kubectl get nodes
```

**Настройка сетевых маршрутов для подов:**

```text
for instance in worker-0 worker-1 worker-2; do
  gcloud compute instances describe ${instance} \
    --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
done

for i in 0 1 2; do
  gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
    --network kubernetes-the-hard-way \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.200.${i}.0/24
done
```

**Установка CoreDNS:**

```text
kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml

kubectl get pods -l k8s-app=kube-dns -n kube-system
```

Проверка работы coredns:

```text
kubectl run --generator=run-pod/v1 busybox --image=busybox:1.28 --command -- sleep 3600
kubectl get pods -l run=busybox
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl exec -ti $POD_NAME -- nslookup kubernetes
```

**Смоук тест нашего кластера:**

```text
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"

gcloud compute ssh controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"
  
kubectl create deployment nginx --image=nginx

kubectl get pods -l app=nginx

POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")

kubectl port-forward $POD_NAME 8080:80

curl --head http://127.0.0.1:8080

kubectl logs $POD_NAME

kubectl exec -ti $POD_NAME -- nginx -v

kubectl expose deployment nginx --port 80 --type NodePort

NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')

gcloud compute firewall-rules create kubernetes-the-hard-way-allow-nginx-service \
  --allow=tcp:${NODE_PORT} \
  --network kubernetes-the-hard-way
  
EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
  
curl -I http://${EXTERNAL_IP}:${NODE_PORT}
```

**Удаление ресурсов и сервисов, использующих кластер:**  
`gcloud -q compute instances delete controller-0 controller-1 controller-2  worker-0 worker-1 worker-2 --zone $(gcloud config get-value compute/zone)`  
  
Удаление сетевых ресурсов балансировщика:  
`gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule --region $(gcloud config get-value compute/region)   
gcloud -q compute target-pools delete kubernetes-target-pool  
gcloud -q compute http-health-checks delete kubernetes  
gcloud -q compute addresses delete kubernetes-the-hard-way`  
  
Удаление правил фаерволла:  
`gcloud -q compute firewall-rules delete  kubernetes-the-hard-way-allow-nginx-service  kubernetes-the-hard-way-allow-internal kubernetes-the-hard-way-allow-external  kubernetes-the-hard-way-allow-health-check`  
  
Удаление VPC:  
`gcloud -q compute routes delete kubernetes-route-10-200-0-0-24 kubernetes-route-10-200-1-0-24 kubernetes-route-10-200-2-0-24`   
`gcloud -q compute networks subnets delete kubernetes   
gcloud -q compute networks delete kubernetes-the-hard-way`



### 2. Сделать скрипт \(python/bash\) который резервирует и удаляет инфраструктуру выше. Инструменты - terraform, ansible.

Github - [https://github.com/linuxfan84/k8s.yaml](https://github.com/linuxfan84/k8s.yaml)

### 3. Сделать "отвердевший" кластер k8s. \(Hardening cluster\). Проверить на различные атаки и уязвимости.



