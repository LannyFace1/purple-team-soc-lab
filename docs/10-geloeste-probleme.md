# 10 Gelöste Probleme

Probleme, auf die ich beim Aufbau gestoßen bin, mit Ursache und Lösung.

### Ziel:
Eine Übersicht über alles, was beim Aufbau nicht auf Anhieb funktioniert hat. Die Spalte „Mehr dazu“ führt zu dem Abschnitt, in dem das Problem ausführlich beschrieben ist.

### pfSense und Netzwerk

| Problem | Ursache | Lösung | Mehr dazu |
|---|---|---|---|
| Kein Zugriff aufs pfSense-Webinterface vom Heimnetz | „Block private networks“ auf WAN blockt das Heimnetz | Haken entfernt, WAN-Regel für 443 aus 192.168.X.0/24 | [01](01-netzwerk-und-pfsense.md) |
| DNS Resolver (unbound) abgestürzt | Hostname/Domain im General Setup leer | Werte eingetragen | [01](01-netzwerk-und-pfsense.md) |
| Befehle in der Proxmox-Konsole kaputt (`anz` statt `any`) | Konsole nutzt US-Layout, Y und Z vertauscht | `loadkeys de` bzw. SSH vom Gaming-PC | |
| SSH auf linux-opfer über NAT: Timeout, WAN-Regel mit 0 States | NAT- und WAN-Regel gespeichert, aber nicht angewendet | „Apply Changes“ in pfSense |  |

### Wazuh und Agents

| Problem | Ursache | Lösung | Mehr dazu |
|---|---|---|---|
| Linux-Agent abgelehnt | gleicher Hostname „debian“ wie der Wazuh-Server | Hostname der Opfer-VM auf linux-opfer geändert |  |
| Windows-Agent-Installation scheitert (Fehler 1603) | Festplatte voll | Disk auf 80 GB erweitert, Recovery-Partition gelöscht |  |
| `Restart-Service -Name wazuh`: Dienst kann nicht geöffnet werden | PowerShell ohne Administratorrechte | PowerShell mit „Als Administrator ausführen“ starten |  |
| Lab-VMs eingefroren (gelbes Dreieck in Proxmox, Status `io-error`) | Systempartition des Proxmox-Hosts voll (94 GB): qcow2-Disks und Snapshot-RAM-Abbilder liegen auf `local`, dazu ISOs, und `logall` hat das Wazuh-Archiv wachsen lassen | Mit `df -h /` und `du -xh` gesucht, ISOs ausgeworfen (`qm set … --ide2 none,media=cdrom`) und gelöscht, VMs mit `qm resume` fortgesetzt, `logall` auf `no` |  |

### Eigene Decoder und Regeln

| Problem | Ursache | Lösung | Mehr dazu |
|---|---|---|---|
| pfSense-Logs kommen an, aber keine Alerts | BSD-Format ohne Hostname, RFC 5424 wird nicht vorab dekodiert | Mit wazuh-logtest analysiert, eigener Decoder + eigene Regeln | [05](05-pfsense-logs-an-wazuh.md#fehlersuche-logs-kommen-an-aber-keine-alerts) |
| `wazuh-analysisd -t` meldet „action is static“ | `action` ist ein statisches Feld | `<action>` statt `<field name="action">` | [05](05-pfsense-logs-an-wazuh.md) |
| `wazuh-logtest -t` unbekannt | `-t` gab es nur beim alten `ossec-logtest` | Syntaxprüfung mit `wazuh-analysisd -t` | [04](04-grundlagen-decoder-und-regeln.md) |
| `wazuh-analysisd -t`: Invalid element 'disable' | Tippfehler im Tag | `<disabled>` | [07](07-fim-virustotal-active-response.md) |

### Suricata

| Problem | Ursache | Lösung | Mehr dazu |
|---|---|---|---|
| Suricata-Warnung zu Hardware-Offloading | Netzwerkkarte verändert Pakete, bevor Suricata sie sieht | Drei Offloading-Optionen abgeschaltet, pfSense neu gestartet | [06](06-suricata.md) |
| Testseite testmynids.org liefert nur eine Parkseite | Domain existiert nicht mehr | Test stattdessen mit nmap-Scan von Kali auf ein Opfer | [06](06-suricata.md) |
| Erster Scan erzeugt keine Suricata-Alerts | Scan lief, während Suricata noch Regeln lud, und HOME_NET enthielt auch das Angreifer-Netz | Auf `Engine started` warten, HOME_NET auf Management + Opfer begrenzt | [06](06-suricata.md) |
| 113 Suricata-Regeln fehlgeschlagen | Regeln für ältere Versionen/Snort (JA3, PostgreSQL, alte Syntax) | Normal, bei über 64.000 Regeln vernachlässigbar | [06](06-suricata.md) |
| Suricata-JSON in Syslog-Zeile verpackt | Eingebauter JSON-Decoder kommt mit dem Vorspann nicht klar | Eigener Decoder mit JSON_Decoder ab `after_parent` | [06](06-suricata.md) |
| Eingebaute Wazuh-Regeln für Suricata greifen nicht | Sie erwarten Events vom Standard-JSON-Decoder (Agent liest `eve.json`), meine kommen per Syslog über `suricata-custom` | Eigene Regeln 100200 bis 100203 | [06](06-suricata.md) |
| Jeder Suricata-Alarm wäre doppelt gezählt worden | pfSense schickt pro Alarm eine Kurzform- und eine JSON-Zeile | Regel 100201 filtert auf `event_type` = `alert`, das hat nur die JSON-Zeile | [06](06-suricata.md) |
| Regel 100201 hing ins Leere | Basisregel 100200 fehlte in `local_rules.xml` | 100200 ergänzt, Suricata-Regeln in eigenen `<group>`-Block | [06](06-suricata.md) |

### Active Response

| Problem | Ursache | Lösung | Mehr dazu |
|---|---|---|---|
| Active Response mit `host-deny` | `host-deny` sperrt IPs über `/etc/hosts.deny` (liest das aktuelle SSH nicht mehr), löscht aber keine Dateien | Eigenes Skript `remove-threat.sh`, Auslöser `rules_id 87105` statt `level` | [07](07-fim-virustotal-active-response.md) |
| Active Response löst nicht aus | Skript lag auf der Wazuh-VM statt auf dem Agent | Skript auf linux-opfer angelegt | [07](07-fim-virustotal-active-response.md) |
| Agent-Log: „Active response command not present: remove-threat.sh“ | Agent prüft beim Start, welche Skripte vorhanden sind, das Skript kam aber erst danach | `systemctl restart wazuh-agent` | [07](07-fim-virustotal-active-response.md) |
| Eigene Frequenz-Regel für SSH-Bruteforce feuert nicht | Wazuhs eingebaute Regel 5763 zählt die Fehlversuche schon selbst | Eigene Regel 100400 direkt an 5763 gehängt | [08](08-szenario-1-ssh-bruteforce.md#automatische-reaktion-firewall-drop) |

---

Zurück: [09 Szenario 2: Persistenz](09-szenario-2-persistenz.md) · [Inhaltsverzeichnis](README.md)
