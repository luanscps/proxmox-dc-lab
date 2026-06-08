# 06 · Configuração LDAP / Active Directory

## 6.1 · Estrutura do AD criada pelo Zentyal/Samba4

Após o provisionamento, o AD terá:

```
DC=servidor,DC=lan
├── CN=Users
│   ├── CN=Administrator
│   └── CN=Guest
├── CN=Computers
├── OU=Domain Controllers
│   └── CN=NS (DC1)
└── CN=Builtin
    ├── CN=Administrators
    ├── CN=Domain Admins
    └── CN=Domain Users
```

## 6.2 · Criar Usuários via Zentyal Web UI

**Domain → Users and Computers → Users → Add**

| Campo | Exemplo |
|---|---|
| First Name | João |
| Last Name | Silva |
| Username | joao.silva |
| Password | (senha forte) |
| OU | Users |

Ou via CLI:

```bash
sudo samba-tool user create joao.silva 'Senha@2026' --given-name=João --surname=Silva
sudo samba-tool user create maria.santos 'Senha@2026' --given-name=Maria --surname=Santos
```

## 6.3 · Criar Grupos

```bash
sudo samba-tool group add TI
sudo samba-tool group add Financeiro
sudo samba-tool group addmembers TI joao.silva
```

## 6.4 · Testar LDAP via ldapsearch

```bash
# Instalar ldap-utils
apt install ldap-utils -y

# Query LDAP para listar usuários
ldapsearch -x -H ldap://10.41.10.10 \
  -D "CN=Administrator,CN=Users,DC=servidor,DC=lan" \
  -w 'SuaSenha' \
  -b "DC=servidor,DC=lan" \
  "(objectClass=user)" cn sAMAccountName mail
```

## 6.5 · Habilitar LDAPS (LDAP sobre TLS/SSL)

```bash
# Verificar certificado Samba
ls /var/lib/samba/private/tls/
# cert.pem  key.pem  ca.pem

# Testar LDAPS
ldapsearch -x -H ldaps://10.41.10.10:636 \
  -D "CN=Administrator,CN=Users,DC=servidor,DC=lan" \
  -w 'SuaSenha' \
  -b "DC=servidor,DC=lan" \
  "(objectClass=user)" cn
```

## 6.6 · Testar Kerberos

```bash
# Obter ticket Kerberos
kinit Administrator@SERVIDOR.LAN

# Listar tickets
klist

# Destruir ticket
kdestroy
```

## 6.7 · Integrar Proxmox ao LDAP/AD (Bônus)

No Proxmox WebUI:
1. **Datacenter → Permissions → Realms → Add → Active Directory**

| Campo | Valor |
|---|---|
| Realm | servidor.lan |
| Domain | servidor.lan |
| Server | 10.41.10.10 |
| Port | 389 |
| User Attribute | sAMAccountName |
| Base DN | DC=servidor,DC=lan |
| Bind DN | CN=Administrator,CN=Users,DC=servidor,DC=lan |
| Password | (senha admin AD) |

2. **Datacenter → Permissions → Groups → Add** → mapeie grupos AD
3. Teste o login com `joao.silva@servidor.lan`
