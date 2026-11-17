# Purple Team SOC Lab

**Wazuh, pfSense und Suricata auf Proxmox, mit Decodern, eigenen Regeln, Angriffen von Kali und automatischer Reaktion.**

Ein selbst gebautes Security Operations Center (SOC) im Homelab. Ich greife meine eigenen Opfer-VMs von einem Kali-Rechner aus an, erkenne die Angriffe im SIEM und lasse Wazuh automatisch reagieren.

**Warum ich das Projekt gemacht habe:** Das ist mein erstes Projekt dieser Art. Das Ziel des Projektes war es mich mit SIEMs, Firewalls und IDS vertraut zu machen und im praktischen rahmen den kompletten Weg selbst zu gehen, vom Netzwerkdesign über das Sammeln von logs bis zur Erstellung von Regeln und Gegenmaßnahmen. Vieles davon habe ich mir während des Projektes selber beigebracht. Fehler die mir unterlaufen sind habe ich mit dokumentiert.  

> [!NOTE]
> Die ausführliche Anleitung liegt im Ordner [`docs/`](docs/README.md).

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

Die drei Lab-Netze sind in Proxmox Bridges ohne Verbindung nach außen unterteilt. Der gesamte Verkehr läuft über die pfSense.

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
| Persistenz per geplanter Aufgabe | Windows-Event 4698 → 60228 | noch keine (geplant: Aufgabe automatisch löschen) | T1053.005 |
| Credential Dumping (LSASS) | in Arbeit | | T1003.001 |

---

## Decoder und Regeln

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
│   ├── README.md                 Inhaltsverzeichnis
│   ├── 01-netzwerk-und-pfsense.md
│   ├── 02-wazuh-installation.md
│   ├── 03-sysmon-auf-windows.md
│   ├── 04-grundlagen-decoder-und-regeln.md
│   ├── 05-pfsense-logs-an-wazuh.md
│   ├── 06-suricata.md
│   ├── 07-fim-virustotal-active-response.md
│   ├── 08-szenario-1-ssh-bruteforce.md
│   ├── 09-szenario-2-persistenz.md
│   └── 10-geloeste-probleme.md
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

- **Alert Fatigue vermeiden.** Einzelne Firewall-Blocks sind kein Anzeichen eines Angriffes. erst ab mehreren nach einander oder gleichzeitig ausgelösten Blocks von der selben IP in kurzer zeit kann man davon ausgehen das es ein angriff sein kann. 
- **Eingebaute Regeln Prüfen.** Nicht immer ist es nötig eigene regeln zu bauen da die meisten SIEM tools schon mit den wichtigsten regeln komen und man muss nur gucken wie man diese verwenden kann.
- **Erkennung ist nicht gleich Abwehr.** Nur weil ich ein Event sehe und aufzeichne heizt das nicht das ich aktiv was dagegen tue. Erkennen ist der erste schritt die richtige Abwehr dagegen zu finden und zu implementieren ist der nächste. Zum Beispiel mit Active Response
- **Logs ankommen heißt nicht, dass sie erkannt werden.** Die pfSense-Logs kamen laut `tcpdump` an, trotzdem gab es keinen einzigen Alarm. Mit `wazuh-logtest` habe ich herausgefunden, dass keiner der mitgelieferten Decoder zum Format passt und habe mit Hilfe von KI einen eigenen geschrieben.
- **Blue Team und Red Team.** Aufgefallen ist mir bei dem Projekt, dass Blue Team und Red Team viele Parallelen haben. Beide Teams wollen Schwachstellen finden, zwar aus verschiedenen Gründen, aber mit demselben Ziel. Das Blue Team, um die Lücke zu schließen. Das Red Team, um zu zeigen, dass man sie ausnutzen kann.
- **Nicht jeder Alert ist ein Angriff.** Außerdem hat mir das Projekt gezeigt, dass nicht jeder Alert der reinkommt auch schlimm sein muss. Viele Alerts sind Fehlalarme (False Positives). Dazu kommen viele Meldungen die zwar stimmen aber von legitimen Quellen kommen, zum Beispiel von Windows selbst oder von mir als Admin. Deshalb gehört zu einem SIEM nicht nur das Erkennen, sondern auch das Aussortieren: Alerts prüfen, unwichtige Regeln stumm schalten und wichtige hochstufen.

## Fazit

Abschließend hat mir das Projekt viel Spaß gemacht, da ich praktisch viel lernen konnte und Probleme die aufgetreten sind selbst lösen konnte. Ich bin zwar noch kein Experte trotzdem fühle ich mich jetzt sicherer im Umgang mit SIEMs, Firewalls und IDS.

---

## Ausblick

- [ ] Szenario 3: LSASS-Zugriff erkennen, mit eigener Regel
- [ ] Windows-Domain mit eigenem Domain Controller und Angriffsszenarien darauf
- [ ] Suricata-Korrelation: viele Alarme vom selben Angreifer in kurzer Zeit
- [ ] Defender-Regeln tunen (Rauschen stumm schalten, Entfernung höher bewerten)

---

## Lizenz

[MIT](LICENSE)
