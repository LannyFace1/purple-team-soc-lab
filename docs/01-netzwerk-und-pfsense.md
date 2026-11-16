# 01 Netzwerk und pfSense

Aufbau der drei Lab-Netze, pfSense als Gateway und Firewall-Regeln.

## Netzwerkarchitektur

<!-- Diagramm einbinden, sobald es in diagrams/ liegt:
![Netzwerkarchitektur](../diagrams/netzwerkarchitektur.png)
-->

## Netze und Interfaces

| Interface | Netz       | pfSense-IP      | DHCP-Bereich für die VMs |
| --------- | ---------- | --------------- | ------------------------ |
| WAN       | Heimnetz   | DHCP vom Router | -                        |
| LAN       | Management | 10.10.10.1      | .100 bis .200            |
| OPT1      | Opfer      | 10.10.20.1      | .100 bis .200            |
| OPT2      | Angreifer  | 10.10.30.1      | .100 bis .200            |

> [!NOTE]
> Die drei Lab-Netze sind in Proxmox eigene Bridges ohne Bridge-Port (vmbr1, vmbr2, vmbr3).
> Sie haben also keine Verbindung nach außen, der ganze Verkehr läuft über die pfSense.

## VMs im Netzwerk

| VM                       | Netz                 | IP                                                     |
| ------------------------ | -------------------- | ------------------------------------------------------ |
| pfSense                  | alle Netze (Gateway) | 192.168.X.54 (WAN), 10.10.10.1, 10.10.20.1, 10.10.30.1 |
| Wazuh                    | Management           | 10.10.10.10 (feste IP per DHCP Static Mapping)         |
| Windows 11 (win11-opfer) | Opfer                | DHCP                                                   |
| Linux (linux-opfer)      | Opfer                | 10.10.20.100                                           |
| Kali                     | Angreifer            | 10.10.30.100                                           |

## Grundeinrichtung in der pfSense-Konsole direkt nach der Installation

| Einstellung          | Wert                                                     |
| -------------------- | -------------------------------------------------------- |
| VLANs                | keine                                                    |
| Interfaces zuweisen  | WAN = vtnet0, LAN = vtnet1, OPT1 = vtnet2, OPT2 = vtnet3 |
| LAN-IP               | 10.10.10.1/24 (kein Gateway, kein IPv6)                  |
| DHCP auf LAN         | 10.10.10.100 bis 10.10.10.200                            |
| Webinterface         | bleibt bei HTTPS                                         |

Schritte für das LAN-Interface (Menüpunkt 2):

1. `Enter an option` → `2` (Set interface(s) IP address)
2. `Enter the number of the interface you wish to configure` → `2` (LAN)
3. `Configure IPv4 address LAN interface via DHCP?` → `n`
4. `Enter the new LAN IPv4 address` → `10.10.10.1`
5. `Enter the new LAN IPv4 subnet bit count` → `24`
6. `For a LAN, press <ENTER> for none` (Gateway) → Enter
7. `Configure IPv6 address LAN interface via DHCP6?` → `n`
8. `Enter the new LAN IPv6 address` → Enter (keine)
9. `Do you want to enable the DHCP server on LAN?` → `y`
10. `Enter the start address of the IPv4 client address range` → `10.10.10.100`
11. `Enter the end address of the IPv4 client address range` → `10.10.10.200`
12. `Do you want to revert to HTTP as the webConfigurator protocol?` → `n`
13. Enter zum Abschließen. Danach ist das Webinterface unter `https://10.10.10.1` erreichbar.

> [!NOTE]
> Das wird für OPT1 (Opfer) und OPT2 (Angreifer) wiederholt, nur mit den jeweiligen IPs aus der Tabelle oben.

> [!NOTE]
> Inhalt folgt.

---

[Inhaltsverzeichnis](README.md) · Weiter: [02 Wazuh-Installation](02-wazuh-installation.md)
