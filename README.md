# proxmox-dc-lab

> **Tutorial completo**: DNS + LDAP/AD + Controlador de Domínio local na Proxmox com MikroTik CHR  
> Ambiente: Proxmox VE 8.4 · RouterOS 7.20 · VLAN 410 (Servers) · domínio `servidor.lan`

---

## 📋 Índice

1. [Visão Geral da Arquitetura](docs/01-arquitetura.md)
2. [Mapa de Rede e VLANs](docs/02-rede-vlans.md)
3. [Criação das VMs na Proxmox](docs/03-proxmox-vms.md)
4. [Instalação do Zentyal Server (DC primário)](docs/04-zentyal-instalacao.md)
5. [Configuração de DNS + Domínio Local](docs/05-dns-dominio.md)
6. [Configuração de LDAP/AD](docs/06-ldap-ad.md)
7. [NS2 — Servidor DNS Secundário Redundante](docs/07-ns2-redundancia.md)
8. [Technitium DNS — DNS Primário da Rede](docs/08-technitium.md)
9. [Ajustes no MikroTik CHR para o Lab](docs/09-mikrotik-ajustes.md)
10. [Ingressar Windows no Domínio](docs/10-windows-join-domain.md)
11. [Verificação e Testes](docs/11-verificacao-testes.md)

---

## 🗺️ Resumo da Topologia

```
                    INTERNET
                       │
              [MikroTik CHR R2]
               bridge-main / VLANs
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   VLAN 410       VLAN 420/430    VLAN 440
   SERVERS         DEV/TEST         PROD
   10.41.10.0/24  ...               ...
        │
  ┌─────┴──────────────────────┐
  │                            │
[VM: DC1 / NS1]          [VM: NS2]            [LXC: Technitium]
Zentyal Server           Technitium DNS        (DNS primário rede)
10.41.10.10/24           10.41.10.11/24        10.41.10.2/24
hostname: ns.servidor.lan hostname: ns1.servidor.lan  ns2: ns2.servidor.lan
• Controlador de Domínio  • DNS Secondário/Slave       • Forwarder / bloqueio
• LDAP / Kerberos         • Zona slave servidor.lan     • Zone forward → DC1
• DNS Autoritativo        • Zone slave 41.10.in-addr.a.
• NTP
```

---

## ⚙️ Ambiente de Referência

| Componente | Detalhe |
|---|---|
| **Hypervisor** | Proxmox VE 8.4.14 (kernel 6.8.12-17-pve) |
| **CPU Host** | 2× Intel Xeon E5-2670 v3 @ 2.30GHz (24 threads) |
| **Roteador** | MikroTik CHR — RouterOS 7.20.2 (VM 102 no Proxmox) |
| **VLAN Servidores** | VLAN 410 — `10.41.10.0/24` |
| **Bridge Proxmox** | `vmbr2` → MikroTik `ether2-VM-TRUNK` |
| **Domínio local** | `servidor.lan` |
| **DC / NS1** | `10.41.10.10` — `ns.servidor.lan` / `ns1.servidor.lan` |
| **NS2 (slave)** | `10.41.10.11` — `ns2.servidor.lan` |
| **Technitium DNS** | `10.41.10.2` — DNS primário DHCP da rede |
