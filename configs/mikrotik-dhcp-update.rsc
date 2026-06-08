# MikroTik CHR R2 — Atualização DHCP para usar DC Lab
# Aplicar após subir Technitium (10.41.10.2) e DC1 (10.41.10.10)
# RouterOS 7.x

# VLAN 410 - SERVERS
/ip dhcp-server network
set [find address=10.41.10.0/24] \
  dns-server=10.41.10.2,10.41.10.10 \
  domain=servidor.lan

# VLAN 420 - DEV
/ip dhcp-server network
set [find address=10.42.20.0/24] \
  dns-server=10.41.10.2,10.41.10.10 \
  domain=servidor.lan

# VLAN 430 - TEST
/ip dhcp-server network
set [find address=10.43.30.0/24] \
  dns-server=10.41.10.2,10.41.10.10 \
  domain=servidor.lan

# VLAN 440 - PROD
/ip dhcp-server network
set [find address=10.44.40.0/24] \
  dns-server=10.41.10.2,10.41.10.10 \
  domain=servidor.lan
