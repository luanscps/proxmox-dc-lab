# 09 · Ajustes no MikroTik CHR para o Lab

## 9.1 · Adicionar static lease para IPs fixos dos servidores

No MikroTik R2, fixar os IPs dos servidores do lab:

```routeros
/ip dhcp-server lease
add address=10.41.10.2  mac-address=XX:XX:XX:XX:XX:XX server=dhcp-410 comment="Technitium-DNS"
add address=10.41.10.10 mac-address=YY:YY:YY:YY:YY:YY server=dhcp-410 comment="DC1-Zentyal-NS1"
add address=10.41.10.11 mac-address=ZZ:ZZ:ZZ:ZZ:ZZ:ZZ server=dhcp-410 comment="NS2-Bind9"
```

> Substitua XX/YY/ZZ pelos MACs reais das interfaces das VMs.

## 9.2 · Atualizar DNS do servidor DHCP 410

```routeros
/ip dhcp-server network
set [find address=10.41.10.0/24] \
  dns-server=10.41.10.2,10.41.10.10 \
  domain=servidor.lan
```

> O campo `domain` faz com que os clientes DHCP usem `servidor.lan` como search domain,
> permitindo que `ping ns` resolva como `ns.servidor.lan`.

## 9.3 · Atualizar DNS das demais VLANs

```routeros
/ip dhcp-server network
set [find address=10.42.20.0/24] dns-server=10.41.10.2,10.41.10.10 domain=servidor.lan
set [find address=10.43.30.0/24] dns-server=10.41.10.2,10.41.10.10 domain=servidor.lan
set [find address=10.44.40.0/24] dns-server=10.41.10.2,10.41.10.10 domain=servidor.lan
```

## 9.4 · Firewall — Liberar portas AD nas VLANs

Adicionar regras para permitir que VMs das outras VLANs acessem o DC1:

```routeros
/ip firewall filter

# Permitir DNS para Technitium e DC1
add chain=forward action=accept comment="DNS para Technitium" \
  dst-address=10.41.10.2 dst-port=53 protocol=udp
add chain=forward action=accept comment="DNS para DC1" \
  dst-address=10.41.10.10 dst-port=53 protocol=udp

# Permitir LDAP/Kerberos/SMB ao DC1
add chain=forward action=accept comment="LDAP/Kerberos/SMB ao DC1" \
  dst-address=10.41.10.10 dst-port=88,389,636,445,139 protocol=tcp \
  src-address-list=redes-permitidas
add chain=forward action=accept comment="Kerberos UDP ao DC1" \
  dst-address=10.41.10.10 dst-port=88 protocol=udp \
  src-address-list=redes-permitidas
add chain=forward action=accept comment="NTP ao DC1" \
  dst-address=10.41.10.10 dst-port=123 protocol=udp \
  src-address-list=redes-permitidas
```

> **Atenção**: Adicione essas regras **antes** da regra `Default deny forward` existente.

## 9.5 · DNS Forwarder do MikroTik → Technitium (opcional)

Se quiser que o próprio MikroTik use o Technitium:

```routeros
/ip dns
set servers=10.41.10.2,10.41.10.10
set allow-remote-requests=yes
```

## 9.6 · Adicionar VLAN 410 nas allowed VLANs do bridge

Verifique se `VLAN-410-SERVERS` já está tagged em `ether2-VM-TRUNK` (já está pela config existente):

```routeros
/interface bridge vlan print where vlan-ids=410
```

Saída esperada inclui `ether2-VM-TRUNK` tagged — confirmado pela config atual.
