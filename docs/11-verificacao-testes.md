# 11 · Verificação e Testes Completos

## 11.1 · Checklist de serviços no DC1

```bash
# Verificar Samba AD DC
systemctl status samba-ad-dc

# Verificar DNS Samba
sudo samba-tool dns serverinfo 127.0.0.1 -U Administrator

# Verificar replicação (se tiver múltiplos DCs)
sudo samba-tool drs showrepl

# Verificar tempo (crítico para Kerberos — deve estar sincronizado)
timedatectl status
ntpq -p
```

## 11.2 · Testes DNS completos

```bash
# --- Do DC1 ---
# Forward lookup
host ns.servidor.lan 127.0.0.1
host sv.servidor.lan 127.0.0.1
host pc1.servidor.lan 127.0.0.1
host ns2.servidor.lan 127.0.0.1

# Reverse lookup
host 10.41.10.10 127.0.0.1
host 10.41.10.11 127.0.0.1

# SRV records do AD (obrigatórios para Windows)
dig @127.0.0.1 _ldap._tcp.servidor.lan SRV
dig @127.0.0.1 _kerberos._tcp.servidor.lan SRV
dig @127.0.0.1 _kerberos._udp.servidor.lan SRV
dig @127.0.0.1 _ldap._tcp.dc._msdcs.servidor.lan SRV
dig @127.0.0.1 _kerberos._tcp.dc._msdcs.servidor.lan SRV

# --- Do NS2 ---
dig @10.41.10.11 ns.servidor.lan
dig @10.41.10.11 _ldap._tcp.servidor.lan SRV

# --- Do Technitium (LXC) ---
dig @10.41.10.2 ns.servidor.lan
dig @10.41.10.2 google.com
```

## 11.3 · Testes LDAP

```bash
# Conexão LDAP anônima (deve falhar — boa prática)
ldapsearch -x -H ldap://10.41.10.10 -b 'DC=servidor,DC=lan' '(objectClass=*)'

# Conexão LDAP autenticada
ldapsearch -x -H ldap://10.41.10.10 \
  -D 'CN=Administrator,CN=Users,DC=servidor,DC=lan' \
  -w 'SuaSenha' \
  -b 'DC=servidor,DC=lan' \
  '(objectClass=user)' cn sAMAccountName

# Verificar portas abertas no DC1
nmap -p 53,88,389,636,445,139,123 10.41.10.10
```

## 11.4 · Testes Kerberos

```bash
# No DC1
kinit Administrator@SERVIDOR.LAN
klist
kdestroy

# Verificar sincronização de tempo (erro > 5 min quebra Kerberos)
date
```

## 11.5 · Teste de failover DNS (NS2)

```bash
# Simular queda do DC1: stop temporário
systemctl stop samba-ad-dc

# No cliente, tentar resolver via NS2
dig @10.41.10.11 sv.servidor.lan   # Deve retornar 10.41.10.20
dig @10.41.10.2  sv.servidor.lan   # Technitium deve forward para NS2 se DC1 cair

# Restaurar DC1
systemctl start samba-ad-dc
```

> **Nota**: Para o Technitium fazer fallback automático para NS2, configure o Conditional Forwarder com **dois forwarders**:
> `10.41.10.10` e `10.41.10.11` (Technitium tenta em ordem, com failover automático).

## 11.6 · Diagrama de fluxo final

```
[Cliente VLAN 410/420/430/440]
        │
        │ DNS query: sv.servidor.lan
        ▼
[Technitium 10.41.10.2]
        │ Conditional Forward: *.servidor.lan
        ▼
[DC1/NS1 Zentyal 10.41.10.10]  ←→  [NS2 Bind9 10.41.10.11]
        │ Autoridade zona servidor.lan    Slave zona replicada
        │ LDAP/Kerberos/AD
        ▼
  Resposta: sv.servidor.lan → 10.41.10.20
```
