# 02 · Mapa de Rede e VLANs

## VLANs existentes no MikroTik CHR R2

| VLAN ID | Nome | Subnet | Gateway (MikroTik) | Uso |
|---|---|---|---|---|
| 410 | SERVERS | `10.41.10.0/24` | `10.41.10.1` | Servidores/VMs (Lab DC) |
| 420 | DEV | `10.42.20.0/24` | `10.42.20.1` | Desenvolvimento |
| 430 | TEST | `10.43.30.0/24` | `10.43.30.1` | Testes |
| 440 | PROD | `10.44.40.0/24` | `10.44.40.1` | Produção |
| 450 | MULLVAD | `10.45.0.0/24` | `10.45.0.1` | VPN WireGuard |
| 470 | NAC-MGMT | `10.47.0.0/24` | `10.47.0.1` | Gerência NAC |
| 800 | UPSTREAM | (via R1) | `10.80.80.1` | Uplink |

## Bridges Proxmox × MikroTik

| Bridge Proxmox | MikroTik Interface | Uso |
|---|---|---|
| `vmbr0` | — | Management Proxmox (10.0.110.130) |
| `vmbr1` | `ether6-UPSTRREAM-ether5` | Uplink R1 físico |
| `vmbr2` | `ether2-VM-TRUNK` | VM Trunk (todas VLANs) |
| `vmbr3` | `ether3-VM-TRUNK` | VM Trunk secundário |
| `vmbr4` | `ether4-VM-TRUNK` | VM Trunk terciário |
| `vmbr5` | `ether5-VM-TRUNK` | VLAN 460 Guest / outras |

## IPs alocados para o Lab DC

| Host | IP | VLAN | Hostname DNS |
|---|---|---|---|
| MikroTik R2 (GW) | `10.41.10.1` | 410 | — |
| **Technitium DNS** | `10.41.10.2` | 410 | `technitium.servidor.lan` |
| **DC1 / NS1** (Zentyal) | `10.41.10.10` | 410 | `ns.servidor.lan` / `ns1.servidor.lan` |
| **NS2** (Technitium slave) | `10.41.10.11` | 410 | `ns2.servidor.lan` |
| **sv** (servidor genérico) | `10.41.10.20` | 410 | `sv.servidor.lan` |
| **pc1** (workstation) | `10.41.10.50` | 410 | `pc1.servidor.lan` |
| DHCP Pool | `10.41.10.10–10.41.10.200` | 410 | (dinâmico) |

> **Nota**: O MikroTik já tem `dns-server=10.0.110.1,1.1.1.1` na rede 410.  
> Após o lab, atualizaremos para `dns-server=10.41.10.2` (Technitium).

## Ajuste no DHCP do MikroTik para VLAN 410

Após subir o Technitium, atualizar no MikroTik:

```routeros
/ip dhcp-server network
set [find address=10.41.10.0/24] dns-server=10.41.10.2,10.41.10.10
```
