# 04 Grundlagen: Decoder und Regeln

Wie aus einer Logzeile ein Alarm wird und wie man eigene Decoder und Regeln testet.

### Vom Paket zum Alert
1. Paket kommt an (prüfbar mit `tcpdump`)
2. Ein **Decoder** liest die Zeile und zerlegt sie in Felder
3. Eine **Regel** bewertet das Ergebnis und vergibt ein Level
4. Nur ab Level 3 entsteht ein **Alert**, und nur Alerts landen im Dashboard

### ID-Bereiche für eigene Regeln
Eigene Regeln müssen zwischen 100000 und 120000 liegen. Die Beispielregel 100001 in der Datei ist schon belegt.

- **100100–100199** für pfSense
- **100200–100299** für Suricata
- **100300–100399** für die Windows-/Sysmon-Angriffsszenarien

### Dateien

| Datei                                       | Inhalt                                                                                                                             |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `/var/ossec/etc/decoders/local_decoder.xml` **[local_decoder.xml](../wazuh/local_decoder.xml)** | eigene Decoder                                                                 |
| `/var/ossec/etc/rules/local_rules.xml` **[local_rules.xml](../wazuh/local_rules.xml)**          | eigene Regeln (eigener `<group>`-Block pro Thema, nach dem letzten `</group>`) |





### Prüfen und aktivieren
Nach jeder Änderung erst die Syntax prüfen, dann neu starten:

```bash
/var/ossec/bin/wazuh-analysisd -t
systemctl restart wazuh-manager
```

> [!NOTE]
> Wazuh liest Regeln nur beim Start ein. Bei einem Fehler startet der Manager nicht, deshalb immer zuerst `-t`.

### Rohdaten mitschreiben und testen
Damit ich echte Zeilen testen kann, aktiviere ich das mitschreiben aller eingehenden Events. Dafür muss ich in der `/var/ossec/etc/ossec.conf` Datei im im `<global>`-Block die Änderung machen:

```xml
<logall>yes</logall>
```

Danach den Manager neu starten. Die Rohdaten landen in `/var/ossec/logs/archives/archives.log`. Jetzt kann ich eine Zeile durch einen logtest schicken:

> [!NOTE]
> Den Code habe ich mir von KI geben lassen

```bash
grep SUCHBEGRIFF /var/ossec/logs/archives/archives.log | tail -n 1 | sed 's/^[^>]*>[^ ]* //' | /var/ossec/bin/wazuh-logtest
```

Der `sed`-Teil schneidet den Wazuh-Vorspann ab, sodass nur die Originalzeile übrig bleibt. logtest zeigt dann in Phase 1 die Vorverarbeitung, in Phase 2 den Decoder mit allen Feldern und in Phase 3 die passende Regel.


> [!NOTE]
> **Wichtig:** Danach `logall` wieder auf `no` stellen, sonst schreibt Wazuh jedes Event dauerhaft mit und die Platte läuft voll.
---

Zurück: [03 Sysmon auf Windows](03-sysmon-auf-windows.md) · [Inhaltsverzeichnis](README.md) · Weiter: [05 pfSense-Logs an Wazuh](05-pfsense-logs-an-wazuh.md)
