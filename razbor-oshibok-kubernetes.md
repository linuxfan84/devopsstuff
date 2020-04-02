---
description: >-
  Здесь находятся все ошибки с которым я столкнулся в процессе эксплуатации
  кластера k8s
---

# Разбор ошибок Kubernetes

**Как исправить "Failed to get system container stats for /system.slice/kubelet.service"**  
Добавляем в `/etc/sysconfig/kubelet`:  
`KUBELET_EXTRA_ARGS=--runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice`  


