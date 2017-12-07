#!/bin/bash -e

if [ -n $CRONITOR_URL ]; then
  curl -s "${CRONITOR_URL}/run" > /dev/null
fi

if [ -z "$API_KEY" ]; then
  echo "[ERROR] Please provide an API_KEY"
  exit 1
fi

if [ -z "$DROPLETS" ]; then
  echo "[ERROR] Please provide a list of DROPLETS you want to snapshot"
  exit
fi

for droplet in $DROPLETS; do
  SNAPSHOT_NAME="snapshot-`date '+%Y-%m-%d_%H:%M:%S'`"

  echo "Snapshotting droplet ${droplet}"

  result=`curl -s -w '%{http_code}\n ' -o /dev/null \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d '{ "type": "snapshot", "name": "'$SNAPSHOT_NAME'" }' \
    "https://api.digitalocean.com/v2/droplets/${droplet}/actions"`

  if (( $result == 201 )); then
    echo "Successfully snapshotted droplet ${droplet}"
  elif (( $result == 401 )); then
    echo "Failed to snapshot droplet ${droplet}, API_KEY is invalid"
    exit 1
  elif (( $result == 404 )); then
    echo "Failed to snapshot droplet ${droplet}, droplet doesn't exist"
  else
    echo "Failed to snapshot droplet ${droplet}, error code: ${result}"
    exit 1
  fi
done

if [ -n $CRONITOR_URL ]; then
  curl -s "${CRONITOR_URL}/complete" > /dev/null
fi
