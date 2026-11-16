# Dokumentation

Die ausführliche Anleitung zum Purple Team SOC Lab, in der Reihenfolge, in der ich das Lab aufgebaut habe und Tests durchgeführt habe.

| Nr. | Abschnitt | Inhalt |
|---|---|---|
| 01 | [Netzwerk und pfSense](01-netzwerk-und-pfsense.md) | Aufbau der drei Lab-Netze, pfSense als Gateway und Firewall-Regeln |
| 02 | [Wazuh-Installation](02-wazuh-installation.md) | Wazuh All-in-One installieren, Dashboard erreichen, Agents verbinden |
| 03 | [Sysmon auf Windows](03-sysmon-auf-windows.md) | Sysmon mit SwiftOnSecurity-Config installieren und an Wazuh anbinden |
| 04 | [Grundlagen: Decoder und Regeln](04-grundlagen-decoder-und-regeln.md) | Wie aus einer Logzeile ein Alarm wird und wie man eigene Decoder und Regeln testet |
| 05 | [pfSense-Logs an Wazuh](05-pfsense-logs-an-wazuh.md) | Firewall-Logs per Syslog an Wazuh, eigener Decoder und Portscan-Erkennung |
| 06 | [Suricata (IDS)](06-suricata.md) | Suricata auf der pfSense, Alarme an Wazuh und Bewertung nach Severity |
| 07 | [FIM, VirusTotal und Active Response](07-fim-virustotal-active-response.md) | Neue Dateien prüfen lassen und Schadsoftware automatisch entfernen |
| 08 | [Szenario 1: SSH-Bruteforce](08-szenario-1-ssh-bruteforce.md) | Angriff mit hydra, Erkennung in Wazuh und automatische Sperre der Angreifer-IP |
| 09 | [Szenario 2: Persistenz](09-szenario-2-persistenz.md) | Persistenz über eine geplante Aufgabe und Erkennung über Windows-Event 4698 |
| 10 | [Gelöste Probleme](10-geloeste-probleme.md) | Probleme, auf die ich beim Aufbau gestoßen bin, mit Ursache und Lösung |

Zurück zur [Projektübersicht](../README.md)
