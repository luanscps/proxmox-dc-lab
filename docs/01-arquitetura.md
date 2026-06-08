# 01 · Visão Geral da Arquitetura

## Objetivo

Mentar um laboratório com:
- **Controlador de Domínio** (AD/LDAP) — Zentyal Server
- **DNS autoritativo** para a zona `servidor.lan` com registros:
  - `servidor.lan` → DC principal
  - `sv.servidor.lan` → servidor de serviços
  - `pc1.servidor.lan` → estação de trabalho
  - `ns1.servidor.lan` / `ns2.servidor.lan` → nameservers
- **NS2 redundante** em VM separada (Technitium como slave DNS)
- **Technitium DNS** como DNS primário dos clientes DHCP (forwarder inteligente)
- Tudo integrado com o **MikroTik CHR R2** já existente no Proxmox

## Fluxo de resolução DNS

```
Cliente (VLAN 410/420/430/440)
    │
    └─► Technitium DNS (10.41.10.2)
            │
            ├─► Zona *.servidor.lan → Conditional Forward → DC1 (10.41.10.10)
            │       └─► Zentyal DNS responde autoritativamente
            │
            └─► Outras zonas → Forwarders externos (1.1.1.1 / 8.8.8.8)
```

## Fluxo de autenticação LDAP/AD

```
Windows Client
    │
    └─► Kerberos (port 88)  → DC1 10.41.10.10
    └─► LDAP     (port 389) → DC1 10.41.10.10
    └─► DNS SRV  (_ldap._tcp.servidor.lan) → resolvido via Technitium → DC1
```

## Serviços e Portas

| Serviço | Porta | VM |
|---|---|---|
| DNS UDP/TCP | 53 | Technitium (10.41.10.2) |
| DNS UDP/TCP | 53 | Zentyal DC1 (10.41.10.10) |
| DNS UDP/TCP | 53 | NS2 (10.41.10.11) |
| LDAP | 389/tcp | Zentyal DC1 |
| LDAPS | 636/tcp | Zentyal DC1 |
| Kerberos | 88/tcp+udp | Zentyal DC1 |
| NTP | 123/udp | Zentyal DC1 |
| SMB/RPC | 445/139/tcp | Zentyal DC1 |
| Technitium WebUI | 5380/tcp | Technitium |
