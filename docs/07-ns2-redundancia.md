# 07 · NS2 — Servidor DNS Secundário Redundante

## Conceito

O **NS2** é um servidor DNS slave que replica as zonas do DC1/NS1.  
Se o DC1 cair, o NS2 continua respondendo consultas DNS (mas não autentica via AD).

Pode ser implementado de duas formas:

| Opção | Vantagem | Desvantagem |
|---|---|---|
| **Technitium** (VM separada) | Fácil via Web UI | Não é slave nativo do Samba |
| **Bind9** (VM Debian separada) | Slave real, suporta AXFR/IXFR | Configuração manual |

**Recomendado**: Bind9 como slave real para o Samba4 DNS.

---

## 7.1 · Permitir transferência de zona no DC1 (Samba4)

No DC1:

```bash
# /etc/samba/smb.conf — adicionar dentro de [global]
sudo nano /etc/samba/smb.conf
```

Adicionar dentro de `[global]`:

```ini
dns forwarder = 10.41.10.2
allow transfer = 10.41.10.11
```

```bash
sudo systemctl restart samba-ad-dc
```

---

## 7.2 · Instalar Bind9 no NS2 (Debian 12)

```bash
apt update && apt install bind9 bind9utils bind9-doc -y
```

## 7.3 · Configurar Bind9 como slave

### `/etc/bind/named.conf.options`

```
options {
    directory "/var/cache/bind";
    recursion no;                  // slave não precisa de recursão
    listen-on { 10.41.10.11; };
    allow-query { 10.41.10.0/24; 10.42.20.0/24; 10.43.30.0/24; 10.44.40.0/24; };
    allow-transfer { none; };      // NS2 não transfere para ninguém
    forwarders { };
    dnssec-validation no;          // Samba4 não suporta DNSSEC
};
```

### `/etc/bind/named.conf.local`

```
// Zona forward slave
zone "servidor.lan" {
    type slave;
    masters { 10.41.10.10; };
    file "/var/cache/bind/db.servidor.lan";
    allow-notify { 10.41.10.10; };
};

// Zona reversa slave
zone "41.10.in-addr.arpa" {
    type slave;
    masters { 10.41.10.10; };
    file "/var/cache/bind/db.41.10.rev";
    allow-notify { 10.41.10.10; };
};

// Zona _msdcs slave (registros SRV do AD)
zone "_msdcs.servidor.lan" {
    type slave;
    masters { 10.41.10.10; };
    file "/var/cache/bind/db._msdcs.servidor.lan";
    allow-notify { 10.41.10.10; };
};
```

```bash
named-checkconf
systemctl enable --now named
systemctl status named
```

## 7.4 · Verificar replicação

```bash
# No NS2 — forçar transferência
rndc retransfer servidor.lan

# Verificar se a zona foi transferida
ls -la /var/cache/bind/

# Consultar NS2 diretamente
dig @10.41.10.11 ns.servidor.lan
dig @10.41.10.11 sv.servidor.lan
dig @10.41.10.11 _ldap._tcp.servidor.lan SRV
```

## 7.5 · Sobre múltiplas redes físicas

**Pergunta: "Posso ter duas redes físicas para o mesmo sistema ou outra VM com NS2?"**

Sim! Você tem 3 opções no seu ambiente Proxmox:

### Opção A — NS2 em VM separada (mesma VLAN 410)
Conforme descrito acima. **Recomendado.**

### Opção B — NS2 em VM com 2 NICs (duas VLANs)
```bash
# No NS2, adicionar segunda NIC para VLAN 420
qm set 201 --net1 virtio,bridge=vmbr2,tag=420
```
E configurar segunda interface no Debian:
```
auto ens19
iface ens19 inet static
  address 10.42.20.11
  netmask 255.255.255.0
```
O Bind9 já vai responder nas duas interfaces se `listen-on` incluir os dois IPs.

### Opção C — DC1 com 2 NICs (multi-homed DC)
Não recomendado para Samba4 AD — pode causar problemas com Kerberos e replicação.

> **Conclusão**: O NS2 em VM separada na VLAN 410 com replicação via AXFR é a solução mais simples, estável e redundante.
