# 01 Netzwerk und pfSense

Aufbau der drei Lab-Netze, pfSense als Gateway und Firewall-Regeln.

## VMs im Netzwerk

| VM                       | Netz                 | IP                                                     |
| ------------------------ | -------------------- | ------------------------------------------------------ |
| pfSense                  | alle Netze (Gateway) | 192.168.X.54 (WAN), 10.10.10.1, 10.10.20.1, 10.10.30.1 |
| Wazuh                    | Management           | 10.10.10.10 (feste IP per DHCP Static Mapping)         |
| Windows 11 (win11-opfer) | Opfer                | DHCP                                                   |
| Linux (linux-opfer)      | Opfer                | 10.10.20.100                                           |
| Kali                     | Angreifer            | 10.10.30.100                                           |


## Netzwerkarchitektur


## VLan Planung 

| Interface | Netz       | pfSense-IP      | DHCP-Bereich für die VMs |
| --------- | ---------- | --------------- | ------------------------ |
| WAN       | Heimnetz   | DHCP vom Router | -                        |
| LAN       | Management | 10.10.10.1      | .100 bis .200            |
| OPT1      | Opfer      | 10.10.20.1      | .100 bis .200            |
| OPT2      | Angreifer  | 10.10.30.1      | .100 bis .200            |

> [!NOTE]
> Die drei Lab-Netze sind in Proxmox eigene Bridges ohne Bridge-Port (vmbr1, vmbr2, vmbr3).
> Sie haben also keine Verbindung nach außen, der ganze Verkehr läuft über die pfSense.

## Erstellen der VLans in der pfSense Konsole

**Interface zuweisen**:  WAN = vtnet0, LAN = vtnet1, OPT1 = vtnet2, OPT2 = vtnet3
**LAN-IP**:              10.10.10.1/24 (kein Gateway, kein IPv6)
**DHCP auf LAN**:        10.10.10.100 bis 10.10.10.200
**Webinterface**:        bleibt bei HTTPS



> [!NOTE]
> Inhalt folgt.

---

[Inhaltsverzeichnis](README.md) · Weiter: [02 Wazuh-Installation](02-wazuh-installation.md)
