# 06 Suricata (IDS)

Suricata auf der pfSense, Alarme an Wazuh und Bewertung nach Severity.

### Suricata (IDS)

**Warum Suricata:** Die Firewall sieht nur, wer mit wem auf welchem Port spricht. Suricata ist ein **IDS** (Intrusion Detection System) und schaut **in den Inhalt** der Pakete. Es vergleicht den Verkehr mit Zehntausenden Signaturen bekannter Angriffe. Das ist bei mir besonders wichtig, weil **Angreifer → Opfer** in der Firewall komplett erlaubt ist. Diese Angriffe würde die Firewall nie als Problem melden.

Ich betreibe Suricata im **IDS-Modus** (nur erkennen, nicht blocken). Blocken würde meine Angriffsszenarien verhindern.

### Vorbereitung

- Snapshot der pfSense-VM (114) in Proxmox
- RAM der pfSense: **4 GB** (Suricata braucht mit vielen Regeln 1 bis 2 GB, darunter kann es beim Laden abstürzen)
- mindestens **2 CPU-Kerne**, weil Suricata jedes Paket gegen die Regeln prüft

### Paket installieren

**System → Package Manager → Available Packages** → `suricata` → **Install**

![05 pfSense-Logs an Wazuh](05-pfsense-logs-an-wazuh.md)
















> [!NOTE]
> Inhalt folgt.

---

Zurück: [05 pfSense-Logs an Wazuh](05-pfsense-logs-an-wazuh.md) · [Inhaltsverzeichnis](README.md) · Weiter: [07 FIM, VirusTotal und Active Response](07-fim-virustotal-active-response.md)
