# 08 · Technitium DNS — DNS Primário da Rede

## Por que o Technitium como DNS primário dos clientes?

- **Bloqueio de ads/trackers** em toda a rede
- **Conditional Forwarding** para `servidor.lan` → DC1
- **WebUI moderna** para gerenciar registros
- **Alta performance** como resolver recursivo
- Os clientes recebem `10.41.10.2` pelo DHCP do MikroTik

---

## 8.1 · Instalar Technitium via LXC (community-scripts)

No shell da Proxmox:

```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/technitium-dns.sh)"
```

Configurações durante o wizard:
- IP: `10.41.10.2/24`
- Gateway: `10.41.10.1`
- Bridge: `vmbr2`, VLAN Tag: `410`
- RAM: 512 MB, Disco: 4 GB

## 8.2 · Configurar Conditional Forwarder para servidor.lan

Acesse a WebUI: `http://10.41.10.2:5380`

**Zones → Add Zone**:

| Campo | Valor |
|---|---|
| Zone Name | `servidor.lan` |
| Zone Type | **Conditional Forwarder** |
| Forwarder | `10.41.10.10` |
| Forwarder Protocol | UDP |

**Zones → Add Zone** (reverso):

| Campo | Valor |
|---|---|
| Zone Name | `41.10.in-addr.arpa` |
| Zone Type | **Conditional Forwarder** |
| Forwarder | `10.41.10.10` |

## 8.3 · Configurar forwarders externos

**Settings → DNS Client → Forwarders**:

```
1.1.1.1
8.8.8.8
```

## 8.4 · Adicionar block lists

**Settings → Blocking → Block List URLs**:

```
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://adaway.org/hosts.txt
```

Clique em **Save** e depois **Update Block Lists Now**.

## 8.5 · Verificar funcionamento

```bash
# Em qualquer host da rede
dig @10.41.10.2 ns.servidor.lan       # Deve retornar 10.41.10.10
dig @10.41.10.2 google.com            # Deve resolver normalmente
dig @10.41.10.2 doubleclick.net       # Deve retornar 0.0.0.0 (bloqueado)
```

## 8.6 · Atualizar DHCP MikroTik para VLAN 410

Após o Technitium estar funcionando:

```routeros
/ip dhcp-server network
set [find address=10.41.10.0/24] dns-server=10.41.10.2,10.41.10.10
```

Para as demais VLANs que precisam resolver `servidor.lan`:

```routeros
/ip dhcp-server network
set [find address=10.42.20.0/24] dns-server=10.41.10.2,10.41.10.10
set [find address=10.43.30.0/24] dns-server=10.41.10.2,10.41.10.10
set [find address=10.44.40.0/24] dns-server=10.41.10.2,10.41.10.10
```
