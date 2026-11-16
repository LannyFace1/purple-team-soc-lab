#!/bin/bash
# Active Response: löscht eine Datei, die VirusTotal als schädlich gemeldet hat

LOG_FILE="/var/ossec/logs/active-responses.log"

read -r INPUT_JSON
COMMAND=$(echo "$INPUT_JSON" | jq -r '.command')
FILE=$(echo "$INPUT_JSON" | jq -r '.parameters.alert.data.virustotal.source.file')

if [ "$COMMAND" = "add" ]; then
  printf '{"version":1,"origin":{"name":"remove-threat","module":"active-response"},"command":"check_keys","parameters":{"keys":[]}}\n'
  read -r RESPONSE
  if [ "$(echo "$RESPONSE" | jq -r '.command')" != "continue" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') $0: $INPUT_JSON Remove threat aborted" >> "$LOG_FILE"
    exit 0
  fi
fi

if [ -z "$FILE" ] || [ "$FILE" = "null" ]; then
  exit 0
fi

if rm -f -- "$FILE"; then
  echo "$(date '+%Y/%m/%d %H:%M:%S') $0: $INPUT_JSON Successfully removed threat" >> "$LOG_FILE"
else
  echo "$(date '+%Y/%m/%d %H:%M:%S') $0: $INPUT_JSON Error removing threat" >> "$LOG_FILE"
fi

exit 0
