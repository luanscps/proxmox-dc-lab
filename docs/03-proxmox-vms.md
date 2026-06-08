# 03 · Criação das VMs na Proxmox

## VMs a criar

| VM | SO | CPU | RAM | Disco | VLAN | IP |
|---|---|---|---|---|---|---|
| DC1-Zentyal | Zentyal 8.0 (Ubuntu 22.04) | 2 cores | 4 GB | 40 GB | 410 | 10.41.10.10 |
| NS2-Technitium | Debian 12 | 1 core | 1 GB | 10 GB | 410 | 10.41.10.11 |

> O **Technitium DNS principal** (10.41.10.2) pode rodar como **LXC** pela interface da Proxmox,  
> usando o script de https://community-scripts.org/.

---

## 3.1 · LXC Technitium DNS (DNS primário da rede)

No shell da Proxmox:

```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/technitium-dns.sh)"
```

Durante o wizard:
- **IP**: `10.41.10.2/24`
- **Gateway**: `10.41.10.1`
- **Bridge**: `vmbr2`
- **VLAN Tag**: `410`
- **RAM**: 512 MB
- **Disco**: 4 GB

---

## 3.2 · VM DC1-Zentyal (Controlador de Domínio)

### Baixar ISO

```bash
# Na Proxmox, pelo browser ou CLI:
wget -O /var/lib/vz/template/iso/zentyal-8.0-development.iso \
  https://zentyal-public-resources.s3-eu-west-1.amazonaws.com/zentyal-8.0-development.iso
```

### Criar VM via CLI (ou pela WebUI)

```bash
qm create 200 \
  --name DC1-Zentyal \
  --memory 4096 \
  --cores 2 \
  --cpu host \
  --bios ovmf \
  --machine q35 \
  --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=0 \
  --scsihw virtio-scsi-pci \
  --scsi0 local-lvm:40,format=raw \
  --cdrom local:iso/zentyal-8.0-development.iso \
  --boot order=cdrom\;scsi0 \
  --net0 virtio,bridge=vmbr2,tag=410 \
  --agent enabled=1 \
  --onboot 1

qm start 200
```

### Criar VM NS2 via CLI

```bash
qm create 201 \
  --name NS2-TechnitiumSlave \
  --memory 1024 \
  --cores 1 \
  --cpu host \
  --bios ovmf \
  --machine q35 \
  --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=0 \
  --scsihw virtio-scsi-pci \
  --scsi0 local-lvm:10,format=raw \
  --cdrom local:iso/debian-12-netinst.iso \
  --boot order=cdrom\;scsi0 \
  --net0 virtio,bridge=vmbr2,tag=410 \
  --agent enabled=1 \
  --onboot 1

qm start 201
```

> **Dica**: Use `vmbr2` com `tag=410` para que as VMs entrem direto na VLAN 410 (SERVERS), que o MikroTik já gerencia.

---

## 3.3 · Configuração de rede pós-instalação

### DC1-Zentyal — `/etc/netplan/01-netcfg.yaml`

```yaml
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
      addresses:
        - 10.41.10.10/24
      routes:
        - to: default
          via: 10.41.10.1
      nameservers:
        addresses:
          - 127.0.0.1
          - 1.1.1.1
```

```bash
netplan apply
```

### NS2 (Debian) — `/etc/network/interfaces`

```
auto lo
iface lo inet loopback

auto ens18
iface ens18 inet static
  address 10.41.10.11
  netmask 255.255.255.0
  gateway 10.41.10.1
  dns-nameservers 10.41.10.10 1.1.1.1
```

```bash
systemctl restart networking
```
