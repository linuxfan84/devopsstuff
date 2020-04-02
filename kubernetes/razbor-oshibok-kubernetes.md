# Kubernetes errors and troubleshooting

**Как исправить "Failed to get system container stats for /system.slice/kubelet.service"**  
 Добавляем в `/etc/sysconfig/kubelet`:  
 `KUBELET_EXTRA_ARGS=--runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice`

