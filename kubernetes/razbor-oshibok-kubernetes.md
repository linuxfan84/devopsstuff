# Kubernetes errors and troubleshooting

**Как исправить "Failed to get system container stats for /system.slice/kubelet.service"**  
 Добавляем в `/etc/sysconfig/kubelet`:  
 `KUBELET_EXTRA_ARGS=--runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice`

**Q: Не работал dns. След комманда висит:  
kubectl exec -ti dnsutils -- nslookup kubernetes**  
A: Проверить чтобы подсети в pod\_cidr у кублетов не пересекались

