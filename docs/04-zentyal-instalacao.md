# 04 · Instalação do Zentyal Server (DC Primário)

## 4.1 · Instalação via ISO

1. Inicie a VM `DC1-Zentyal` e acesse pelo console da Proxmox
2. Selecione **Install Zentyal 8.0**
3. Idioma: **English** (recomendado para evitar bugs de locale)
4. Layout teclado: **Portuguese (Brazil)**
5. Nome do host: **ns** (FQDN ficará `ns.servidor.lan`)
6. IP: **10.41.10.10 / 24**, gateway **10.41.10.1**, DNS **1.1.1.1** (temporário)
7. Senha root / usuário admin: defina senhas fortes
8. Particionamento: **Guided - use entire disk**
9. Aguarde a instalação (~15 min)

## 4.2 · Primeiro acesso — Web UI

Após reiniciar, acesse no browser:

```
https://10.41.10.10:8443
```

> Aceite o certificado autoassinado.

## 4.3 · Seleção de módulos

No wizard inicial, selecione **apenas**:

- [x] **Domain Controller and File Sharing** (AD DS + DNS + LDAP + Kerberos + Samba)
- [x] **DNS** (servidor DNS autoritativo)
- [x] **NTP** (sincronização de tempo — obrigatório para Kerberos)

> Não instale módulos desnecessários. Deixe HTTP/HTTPS/DHCP para o MikroTik.

## 4.4 · Configuração do módulo Domain Controller

Em **Domain → Domain Controller → Configuration**:

| Campo | Valor |
|---|---|
| **Realm / Domain** | `servidor.lan` |
| **NetBIOS name** | `SERVIDOR` |
| **Administrator password** | `(senha forte)` |
| **DNS forwarder** | `10.41.10.2` (Technitium) |

Clique em **Save** e depois em **Save Changes** (botão laranja no topo).

> O Zentyal irá provisionar o AD DS, DNS, Kerberos e LDAP automaticamente.  
> Esse processo leva 2–5 minutos.

## 4.5 · Verificar serviços ativos

```bash
# SSH no DC1 ou via console
sudo samba-tool domain info 10.41.10.10
sudo samba-tool user list
```

Saída esperada:

```
Forest           : servidor.lan
Domain           : servidor.lan
NetBIOS domain   : SERVIDOR
Domain SID       : S-1-5-21-...
```
