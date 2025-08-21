#!/bin/bash

if [[ ! -f .env]]; then 
  echo "Error: .env file not found!"
  exit 1
fi

while IFS='=' read -r key value; do
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)

  if [[ -n $key && $key != "\#"]]; then
    export "$key=$value"
    echo "Exported: $key=${value:+<value_hidden>}"
  fi
done < .env

echo "Evironment variables loaded successfully."