# MikroTik CHR R2 — Regras de Firewall para Active Directory
# Adicionar ANTES da regra 'Default deny forward'
# RouterOS 7.x

/ip firewall filter

# DNS para Technitium (10.41.10.2)
add chain=forward action=accept comment="DNS UDP para Technitium" \
  dst-address=10.41.10.2 dst-port=53 protocol=udp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

add chain=forward action=accept comment="DNS TCP para Technitium" \
  dst-address=10.41.10.2 dst-port=53 protocol=tcp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

# DNS para DC1/NS1 (10.41.10.10)
add chain=forward action=accept comment="DNS UDP para DC1" \
  dst-address=10.41.10.10 dst-port=53 protocol=udp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

add chain=forward action=accept comment="DNS TCP para DC1" \
  dst-address=10.41.10.10 dst-port=53 protocol=tcp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

# DNS para NS2 (10.41.10.11)
add chain=forward action=accept comment="DNS UDP para NS2" \
  dst-address=10.41.10.11 dst-port=53 protocol=udp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

# Kerberos (88/tcp+udp) para DC1
add chain=forward action=accept comment="Kerberos TCP ao DC1" \
  dst-address=10.41.10.10 dst-port=88 protocol=tcp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

add chain=forward action=accept comment="Kerberos UDP ao DC1" \
  dst-address=10.41.10.10 dst-port=88 protocol=udp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

# LDAP (389/tcp) e LDAPS (636/tcp)
add chain=forward action=accept comment="LDAP ao DC1" \
  dst-address=10.41.10.10 dst-port=389 protocol=tcp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

add chain=forward action=accept comment="LDAPS ao DC1" \
  dst-address=10.41.10.10 dst-port=636 protocol=tcp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

# SMB/RPC
add chain=forward action=accept comment="SMB ao DC1" \
  dst-address=10.41.10.10 dst-port=445,139 protocol=tcp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

# NTP (123/udp)
add chain=forward action=accept comment="NTP ao DC1" \
  dst-address=10.41.10.10 dst-port=123 protocol=udp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]

# RPC dinâmico — necessário para Group Policy
add chain=forward action=accept comment="RPC dinamico ao DC1" \
  dst-address=10.41.10.10 dst-port=49152-65535 protocol=tcp \
  src-address-list=redes-permitidas place-before=[find comment="Default deny forward"]
