<h1 align="center">🖥️ proxmox-dc-lab</h1>

<p align="center">
  Lab completo de infraestrutura local com Controlador de Domínio, DNS autoritativo redundante e roteamento por VLANs — tudo virtualizado no Proxmox VE.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Proxmox_VE-8.4.14-E57000?logo=proxmox&logoColor=white" />
  <img src="https://img.shields.io/badge/RouterOS-7.20.2-293B8A?logo=mikrotik&logoColor=white" />
  <img src="https://img.shields.io/badge/Zentyal_Server-DC%20Primário-0066CC" />
  <img src="https://img.shields.io/badge/Technitium_DNS-primário-5C2D91" />
  <img src="https://img.shields.io/badge/domínio-servidor.lan-green" />
  <img src="https://img.shields.io/badge/licença-MIT-blue" />
</p>

---

## 📌 Sobre o Projeto

Este repositório documenta a construção de um **laboratório de infraestrutura de datacenter local**, com foco em:

- **Controlador de Domínio** (AD/LDAP) com Zentyal Server
- **DNS autoritativo + redundância** (NS1/NS2 + Technitium como forwarder)
- **Segmentação de rede via VLANs** gerenciadas pelo MikroTik CHR
- **Virtualização completa** no Proxmox VE com VMs e LXC containers

O objetivo é simular um ambiente de produção real para estudo, homelab e validação de infraestrutura on-premise, com todas as decisões técnicas documentadas passo a passo.

---

## 🗺️ Topologia da Rede

```
                    INTERNET
                       │
              [MikroTik CHR R2]
          RouterOS 7.20 — VM 102 no Proxmox
           bridge-main / VLAN Trunk (vmbr2)
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   VLAN 410       VLAN 420/430    VLAN 440
   SERVERS         DEV/TEST         PROD
  10.41.10.0/24
        │
  ┌─────┴──────────────────────────────────┐
  │                   │                    │
[VM: DC1 / NS1]   [VM: NS2]         [LXC: Technitium]
Zentyal Server    Technitium DNS    DNS primário DHCP
10.41.10.10       10.41.10.11       10.41.10.2
ns.servidor.lan   ns2.servidor.lan  (forwarder/bloqueio)
• AD / LDAP       • Zona slave      • Zone forward → DC1
• Kerberos        • DNS Secundário  • Filtro DNS
• DNS Autoritativo
• NTP
```

---

## ⚙️ Ambiente de Referência

| Componente         | Detalhe                                             |
|--------------------|-----------------------------------------------------|
| **Hypervisor**     | Proxmox VE 8.4.14 (kernel 6.8.12-17-pve)           |
| **CPU Host**       | 2× Intel Xeon E5-2670 v3 @ 2.30GHz (24 threads)    |
| **Roteador**       | MikroTik CHR — RouterOS 7.20.2 (VM 102)             |
| **VLAN Servidores**| VLAN 410 — `10.41.10.0/24`                          |
| **Bridge Proxmox** | `vmbr2` → MikroTik `ether2-VM-TRUNK`               |
| **Domínio local**  | `servidor.lan`                                      |
| **DC1 / NS1**      | `10.41.10.10` — `ns.servidor.lan` / `ns1.servidor.lan` |
| **NS2 (slave)**    | `10.41.10.11` — `ns2.servidor.lan`                 |
| **Technitium DNS** | `10.41.10.2` — DNS primário DHCP da rede            |

---

## 🧩 Stack de Tecnologias

| Camada            | Tecnologia                            | Função                                |
|-------------------|---------------------------------------|---------------------------------------|
| **Hypervisor**    | Proxmox VE 8.4                        | Virtualização de VMs e LXC containers |
| **Roteamento**    | MikroTik CHR (RouterOS 7.20)          | VLANs, DHCP, firewall, NAT            |
| **AD / LDAP**     | Zentyal Server 8.x                    | Controlador de domínio primário (DC1) |
| **DNS Primário**  | Technitium DNS (LXC)                  | Forwarder, bloqueio de ads, cache     |
| **DNS Redundante**| Technitium DNS (VM NS2)               | Zona slave do `servidor.lan`          |
| **OS Base**       | Ubuntu Server 22.04 LTS               | Base das VMs                          |
| **Protocolo AD**  | Kerberos 5 + LDAP v3                  | Autenticação e diretório              |
| **NTP**           | ntpd via Zentyal                      | Sincronização de horário do domínio   |

---

## 📋 Índice da Documentação

Toda a configuração está documentada em etapas independentes dentro de `/docs`:

| # | Arquivo | Conteúdo |
|---|---------|----------|
| 01 | [Visão Geral da Arquitetura](docs/01-arquitetura.md) | Decisões de design, objetivos e componentes |
| 02 | [Mapa de Rede e VLANs](docs/02-rede-vlans.md) | Tabela de VLANs, CIDRs e segmentação |
| 03 | [Criação das VMs na Proxmox](docs/03-proxmox-vms.md) | Specs das VMs, disco, RAM, CPU, rede |
| 04 | [Instalação do Zentyal (DC1)](docs/04-zentyal-instalacao.md) | ISO, particionamento, módulos instalados |
| 05 | [DNS + Domínio Local](docs/05-dns-dominio.md) | Zonas DNS, registros A/PTR, servidor.lan |
| 06 | [LDAP / Active Directory](docs/06-ldap-ad.md) | OU, usuários, grupos, GPOs básicas |
| 07 | [NS2 — DNS Secundário Redundante](docs/07-ns2-redundancia.md) | AXFR, zona slave, failover de resolução |
| 08 | [Technitium DNS](docs/08-technitium.md) | Instalação LXC, forwarders, zone forward |
| 09 | [Ajustes no MikroTik CHR](docs/09-mikrotik-ajustes.md) | VLAN 410, DHCP server, DNS apontamento |
| 10 | [Ingressar Windows no Domínio](docs/10-windows-join-domain.md) | Join domain, GPO aplicada, validação |
| 11 | [Verificação e Testes](docs/11-verificacao-testes.md) | nslookup, dig, kinit, LDAP queries, ping |

---

## 🚀 Como Usar Este Repositório

Este projeto **não é um script automatizado** — é uma documentação técnica step-by-step. Para replicar o ambiente:

### 📋 Pré-requisitos

- Proxmox VE 8.x instalado (bare metal ou nested)
- MikroTik CHR como VM no Proxmox (ou hardware físico)
- Acesso à ISO do Zentyal Server 8.x
- Mínimo recomendado de hardware:
  - 32 GB RAM
  - 4 cores físicos (8+ threads)
  - 500 GB de armazenamento (SSD recomendado)

### 🔧 Ordem de Execução

Siga os documentos na ordem numérica:

```bash
# 1. Leia o planejamento antes de começar
docs/01-arquitetura.md

# 2. Configure as VLANs no MikroTik
docs/02-rede-vlans.md
docs/09-mikrotik-ajustes.md

# 3. Crie as VMs no Proxmox
docs/03-proxmox-vms.md

# 4. Instale e configure o DC1 (Zentyal)
docs/04-zentyal-instalacao.md
docs/05-dns-dominio.md
docs/06-ldap-ad.md

# 5. Configure redundância DNS
docs/07-ns2-redundancia.md
docs/08-technitium.md

# 6. Ingresse clientes Windows
docs/10-windows-join-domain.md

# 7. Valide o ambiente completo
docs/11-verificacao-testes.md
```

---

## 🔐 Segurança e Boas Práticas

- **Segmentação por VLANs**: tráfego de servidores isolado em VLAN 410
- **Kerberos** para autenticação de domínio (sem NTLM legado)
- **DNS redundante**: dois resolvers independentes evitam single point of failure
- **NTP via Zentyal**: sincronização de horário crítica para Kerberos (tolerância: ±5 min)
- **Zona PTR configurada**: registros reversos `/24` garantem resolução inversa

> ⚠️ **Atenção**: este é um ambiente de **laboratório**. Para produção, adicione:
> - Segundo DC para replicação AD/Kerberos
> - Backup automatizado do Proxmox (PBS)
> - Firewall por VLAN com regras explícitas de saída

---

## 📁 Estrutura do Repositório

```
proxmox-dc-lab/
├── README.md                   # Este arquivo
├── configs/                    # Arquivos de configuração exportados
│   └── ...
└── docs/                       # Documentação step-by-step
    ├── 01-arquitetura.md
    ├── 02-rede-vlans.md
    ├── 03-proxmox-vms.md
    ├── 04-zentyal-instalacao.md
    ├── 05-dns-dominio.md
    ├── 06-ldap-ad.md
    ├── 07-ns2-redundancia.md
    ├── 08-technitium.md
    ├── 09-mikrotik-ajustes.md
    ├── 10-windows-join-domain.md
    └── 11-verificacao-testes.md
```

---

## 🧪 Testes de Validação

Após seguir toda a documentação, o ambiente deve passar nos seguintes testes:

```bash
# Resolução direta
nslookup ns.servidor.lan 10.41.10.10

# Resolução reversa
dig -x 10.41.10.10 @10.41.10.10

# Autenticação Kerberos
kinit administrator@SERVIDOR.LAN
klist

# Query LDAP
ldapsearch -H ldap://10.41.10.10 -b "dc=servidor,dc=lan" -x

# Redundância DNS (com DC1 offline)
nslookup ns.servidor.lan 10.41.10.11
```

Todos os testes esperados e saídas de referência estão em [`docs/11-verificacao-testes.md`](docs/11-verificacao-testes.md).

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para reportar erros de configuração ou sugerir melhorias na documentação:

1. Abra uma [Issue](https://github.com/luanscps/proxmox-dc-lab/issues) descrevendo o problema ou sugestão
2. Faça um fork e crie uma branch: `git checkout -b fix/descricao-do-ajuste`
3. Abra um Pull Request com a correção

---

## 📄 Licença

Distribuído sob a licença **MIT**. Veja [`LICENSE`](LICENSE) para mais detalhes.

---

## ✒️ Autor

**Luan** — [@luanscps](https://github.com/luanscps)

> Desenvolvido como projeto pessoal de infraestrutura homelab / datacenter local.
