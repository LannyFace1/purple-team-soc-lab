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

| Datei                                       | Inhalt                                                                         |
| ------------------------------------------- | ------------------------------------------------------------------------------ |
| `/var/ossec/etc/decoders/local_decoder.xml` | eigene Decoder                                                                 |
| `/var/ossec/etc/rules/local_rules.xml`      | eigene Regeln (eigener `<group>`-Block pro Thema, nach dem letzten `</group>`) |

**[local_decoder.xml](../wazuh/local_decoder.xml)**

**[local_rules.xml](../wazuh/local_rules.xml)**

> [!NOTE]
> Inhalt folgt.

---

Zurück: [03 Sysmon auf Windows](03-sysmon-auf-windows.md) · [Inhaltsverzeichnis](README.md) · Weiter: [05 pfSense-Logs an Wazuh](05-pfsense-logs-an-wazuh.md)
