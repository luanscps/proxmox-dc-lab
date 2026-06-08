# 05 · Configuração DNS + Domínio Local

## 5.1 · Zonas DNS criadas automaticamente pelo Zentyal

Ao instalar o módulo Domain Controller, o Zentyal/Samba4 cria automaticamente:

| Zona | Tipo | Descrição |
|---|---|---|
| `servidor.lan` | Forward autoritativo | Zona principal do domínio |
| `41.10.in-addr.arpa` | Reverse (PTR) | Zona reversa da subnet 10.41.10.0/24 |
| `_msdcs.servidor.lan` | SRV records | Records Kerberos/LDAP para Windows |

## 5.2 · Adicionar registros A manualmente

No **Zentyal Web UI → DNS → Domains → servidor.lan → Hostnames**:

| Hostname | IP | Descrição |
|---|---|---|
| `ns` | `10.41.10.10` | DC1 / NS1 |
| `ns1` | `10.41.10.10` | Alias do NS1 |
| `ns2` | `10.41.10.11` | NS secundário |
| `sv` | `10.41.10.20` | Servidor de serviços |
| `pc1` | `10.41.10.50` | Estação de trabalho |
| `technitium` | `10.41.10.2` | DNS forwarder |

Ou via CLI (samba-tool):

```bash
sudo samba-tool dns add 10.41.10.10 servidor.lan ns   A 10.41.10.10 -U Administrator
sudo samba-tool dns add 10.41.10.10 servidor.lan ns1  A 10.41.10.10 -U Administrator
sudo samba-tool dns add 10.41.10.10 servidor.lan ns2  A 10.41.10.11 -U Administrator
sudo samba-tool dns add 10.41.10.10 servidor.lan sv   A 10.41.10.20 -U Administrator
sudo samba-tool dns add 10.41.10.10 servidor.lan pc1  A 10.41.10.50 -U Administrator
sudo samba-tool dns add 10.41.10.10 servidor.lan technitium A 10.41.10.2 -U Administrator
```

## 5.3 · Registros NS na zona

```bash
# Adicionar NS records para ns1 e ns2
sudo samba-tool dns add 10.41.10.10 servidor.lan @ NS ns1.servidor.lan -U Administrator
sudo samba-tool dns add 10.41.10.10 servidor.lan @ NS ns2.servidor.lan -U Administrator
```

## 5.4 · Registros PTR (reverso)

```bash
# Zona reversa 41.10.in-addr.arpa
sudo samba-tool dns add 10.41.10.10 41.10.in-addr.arpa 10 PTR ns.servidor.lan  -U Administrator
sudo samba-tool dns add 10.41.10.10 41.10.in-addr.arpa 11 PTR ns2.servidor.lan -U Administrator
sudo samba-tool dns add 10.41.10.10 41.10.in-addr.arpa 20 PTR sv.servidor.lan  -U Administrator
sudo samba-tool dns add 10.41.10.10 41.10.in-addr.arpa 50 PTR pc1.servidor.lan -U Administrator
```

## 5.5 · Verificar DNS

```bash
# No DC1
host ns.servidor.lan 127.0.0.1
host sv.servidor.lan 127.0.0.1
host pc1.servidor.lan 127.0.0.1

# Verificar SRV records AD
host -t SRV _ldap._tcp.servidor.lan 127.0.0.1
host -t SRV _kerberos._tcp.servidor.lan 127.0.0.1
```

Saída esperada:
```
_ldap._tcp.servidor.lan has SRV record 0 100 389 ns.servidor.lan.
_kerberos._tcp.servidor.lan has SRV record 0 100 88 ns.servidor.lan.
```
