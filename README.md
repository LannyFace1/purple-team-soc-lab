# Purple Team SOC Lab
Dieses Projekt wurde gemacht um sich im Bereich der Cybersecurity weiter zu bilden und den Umgang mit SIEMs und Firewalls näher zu führen dieses Projekt ist mein erstes dieser Art.

**Wazuh, pfSense und Suricata auf Proxmox, mit eigenen Decodern, eigenen Regeln, Angriffen von Kali und automatischer Reaktion.**

Ein selbst gebautes Security Operations Center im Homelab. Ich greife meine eigenen Opfer-VMs von einem Kali-Rechner aus an, erkenne die Angriffe im SIEM und lasse Wazuh automatisch reagieren. Ziel war, den kompletten Weg einmal selbst zu gehen: vom Netzwerkdesign über das Einsammeln der Logs bis zur fertigen Erkennungsregel mit Gegenmaßnahme.

> [!NOTE]
> Die ausführliche Schritt-für-Schritt-Anleitung liegt im Ordner [`docs/`](docs/).

---

## Architektur

<!-- Excalidraw-Diagramm als PNG nach diagrams/ exportieren und hier einbinden:
![Netzwerkarchitektur](diagrams/netzwerkarchitektur.png)
-->

```
                         Heimnetz
                            │
                     ┌──────┴──────┐
                     │   pfSense   │  Firewall, Router, Suricata (IDS)
                     └──┬───┬───┬──┘
          ┌─────────────┘   │   └─────────────┐
   Management            Opfer            Angreifer
   10.10.10.0/24      10.10.20.0/24      10.10.30.0/24
   ┌──────────┐    ┌──────────────┐     ┌──────────┐
   │  Wazuh   │    │ win11-opfer  │     │   Kali   │
   │ (SIEM)   │    │ linux-opfer  │     └──────────┘
   └──────────┘    └──────────────┘
```

Die drei Lab-Netze sind in Proxmox eigene Bridges ohne Verbindung nach außen. Der gesamte Verkehr läuft über die pfSense.

| Von → Nach | Erlaubt | Grund |
|---|---|---|
| Angreifer → Opfer | alles | Sinn des Labs |
| Opfer → Angreifer | alles | Reverse Shells |
| Opfer → Wazuh | nur 1514/1515 | Wazuh-Agents |
| Angreifer → Management | nein | Das SIEM soll nicht angreifbar sein |
| Lab → Heimnetz | nein | Verwundbare VMs dürfen nie an echte Geräte |
| Lab → Internet | ja | Updates und Downloads |

---

## Eingesetzte Tools

| Bereich | Tool |
|---|---|
| Virtualisierung | Proxmox VE |
| Firewall / Routing | pfSense CE 2.8.1 |
| IDS | Suricata (ETOpen, Snort GPLv2 Community, Feodo Tracker, ABUSE.ch SSL) |
| SIEM | Wazuh 4.14 (All-in-One) |
| Endpoint-Logs | Sysmon (SwiftOnSecurity-Config), Windows Security Log, Microsoft Defender |
| Threat Intelligence | VirusTotal API |
| Angreifer | Kali Linux (nmap, hydra) |

---

## Was das Lab erkennt und wie es reagiert

| Angriff | Erkennung | Reaktion | MITRE ATT&CK |
|---|---|---|---|
| Portscan aus dem Angreifer-Netz | pfSense-Logs → eigene Regel 100102, Suricata → 100201 bis 100203 | keine (IDS-Modus) | T1046 |
| Schadsoftware-Download auf Linux (EICAR) | FIM + VirusTotal → 87105 | Datei wird automatisch gelöscht (eigenes Skript), Ergebnis als 100300 / 100301 | T1203 |
| Schadsoftware-Download auf Windows (EICAR) | FIM + VirusTotal, Defender → 62123 / 62124 | Microsoft Defender entfernt die Datei | |
| SSH-Bruteforce mit hydra | 5760 / 5763 → eigene Regel 100400 | Angreifer-IP wird per firewall-drop für 5 Minuten gesperrt | T1110 |
| Persistenz per geplanter Aufgabe | Windows-Event 4698 → 60228 | <!-- TODO --> | T1053.005 |
| Credential Dumping (LSASS) | in Arbeit | | T1003.001 |

---

## Eigene Decoder und Regeln

| ID / Name | Zweck |
|---|---|
| Decoder `pfsense-custom` | zerlegt pfSense-Firewall-Logs (RFC 5424), die Wazuh mit den mitgelieferten Decodern nicht erkennt |
| Decoder `suricata-custom` | holt das Suricata-EVE-JSON aus der Syslog-Zeile der pfSense |
| 100100 bis 100102 | pfSense: Basisregel, einzelner Block, Portscan-Korrelation |
| 100200 bis 100203 | Suricata: Basisregel, Alarm, Bewertung nach Severity |
| 100300 bis 100301 | Active Response: Bedrohung entfernt / nicht entfernt |
| 100400 | SSH-Bruteforce als Auslöser für firewall-drop |

Die Dateien liegen in [`wazuh/`](wazuh/).

> [!NOTE]
> Die beiden Decoder und das Skript `remove-threat.sh` habe ich mit KI-Unterstützung erstellt und selbst mit `wazuh-logtest` und live getestet. Die Regeln habe ich selbst geschrieben.

---

## Repo-Struktur

```
purple-team-soc-lab/
├── README.md
├── docs/                         ausführliche Anleitung pro Abschnitt
├── diagrams/                     Netzwerkarchitektur
├── screenshots/                  Belege aus Dashboard, pfSense und Kali
├── scripts/
│   └── remove-threat.sh          Active Response: Schadsoftware löschen
└── wazuh/
    ├── local_decoder.xml         eigene Decoder
    ├── local_rules.xml           eigene Regeln
    └── ossec-snippets/           Ausschnitte aus der ossec.conf (ohne API-Key)
        ├── manager-remote-syslog.xml
        ├── manager-virustotal.xml
        ├── manager-active-response.xml
        ├── agent-linux.xml
        └── agent-windows.xml
```

---

## Was ich gelernt habe

<!-- Entwurf, bitte in eigenen Worten anpassen -->

- **Logs ankommen heißt nicht, dass sie erkannt werden.** Die pfSense-Logs kamen laut `tcpdump` an, trotzdem gab es keinen einzigen Alarm. Mit `wazuh-logtest` habe ich gefunden, dass keiner der mitgelieferten Decoder zum Format passt, und einen eigenen geschrieben.
- **Alert Fatigue vermeiden.** Ein einzelner Firewall-Block ist kein Angriff. Erst viele Blocks von derselben IP in kurzer Zeit werden zum Portscan-Alarm, und danach ist zwei Minuten Ruhe.
- **Erst die eingebauten Regeln prüfen.** Meine eigene Bruteforce-Korrelation hat nicht ausgelöst. Ein Blick ins `alerts.log` hat gezeigt, dass Wazuhs Regel 5763 die Zählung schon übernimmt. Darauf aufzubauen war robuster.
- **Erkennung ist nicht gleich Abwehr.** Suricata im IDS-Modus meldet nur. Gesperrt wird erst durch Active Response, und auch die Sperre ist bewusst nur temporär.
- **Kontext ist wichtig.** Suricata hat das Angreifer-Netz zuerst als eigenes Netz betrachtet, deshalb haben viele Regeln nicht gegriffen. Erst mit sauber gesetztem HOME_NET kamen die Alarme.

---

## Ausblick

- [ ] Szenario 3: LSASS-Zugriff erkennen, mit eigener Regel
- [ ] Windows-Domain mit eigenem Domain Controller und Angriffsszenarien darauf
- [ ] Suricata-Korrelation: viele Alarme vom selben Angreifer in kurzer Zeit
- [ ] Defender-Regeln tunen (Rauschen stumm schalten, Entfernung höher bewerten)

---

## Lizenz

[MIT](LICENSE)
