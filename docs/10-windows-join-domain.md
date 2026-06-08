# 10 · Ingressar Windows no Domínio servidor.lan

## Pré-requisitos

- PC Windows com DNS apontando para `10.41.10.2` ou `10.41.10.10`
- Conectividade com DC1 (VLAN 410 ou roteamento via MikroTik)
- Conta de usuário no AD com permissão de ingresso

---

## 10.1 · Configurar DNS no cliente Windows

**PowerShell (Admin)**:

```powershell
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex `
  -ServerAddresses ('10.41.10.2','10.41.10.10')
```

Verificar:

```powershell
Resolve-DnsName ns.servidor.lan
Resolve-DnsName _ldap._tcp.servidor.lan -Type SRV
```

## 10.2 · Ingressar no domínio

**Método 1 — GUI**:
1. Botão direito em **Este PC → Propriedades → Configurações avançadas do sistema**
2. **Nome do computador → Alterar → Domínio: `servidor.lan`**
3. Credenciais: `Administrator` + senha do AD
4. Reiniciar

**Método 2 — PowerShell**:

```powershell
$cred = Get-Credential -UserName 'SERVIDOR\Administrator' -Message 'Senha AD'
Add-Computer -DomainName 'servidor.lan' -Credential $cred -OUPath 'CN=Computers,DC=servidor,DC=lan' -Restart
```

## 10.3 · Verificar ingresso no domínio

```powershell
# Verificar domínio
(Get-WmiObject Win32_ComputerSystem).Domain
# Saída: servidor.lan

# Listar usuários do domínio
net user /domain

# Listar grupos do domínio
net group /domain
```

## 10.4 · Login com usuário do domínio

Na tela de login do Windows:
- Usuário: `SERVIDOR\joao.silva` ou `joao.silva@servidor.lan`
- Senha: (senha do AD)

## 10.5 · Mapear compartilhamento SMB (Samba4)

```powershell
# Criar compartilhamento no Zentyal primeiro:
# Domain → File Sharing → Add Share

# No Windows, mapear:
New-PSDrive -Name 'S' -PSProvider FileSystem `
  -Root '\\ns.servidor.lan\share' `
  -Credential (Get-Credential 'SERVIDOR\Administrator') `
  -Persist
```
