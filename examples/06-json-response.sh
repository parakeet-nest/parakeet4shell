#!/bin/bash
# ✋ This example is a wip 🚧
. "../lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

MODEL="tinydolphin"

read -r -d '' SYSTEM_CONTENT <<- EOM
You are a helpful AI assistant. The user will enter a country name.
The assistant will then return the capital of the country, 
the decimal latitude and the decimal longitude of the capital of the country.
Output the results in JSON format.
EOM

read -r -d '' USER_CONTENT <<- EOM
Suisse
EOM

SYSTEM_CONTENT=$(Sanitize "${SYSTEM_CONTENT}")
USER_CONTENT=$(Sanitize "${USER_CONTENT}")

echo ${USER_CONTENT}

read -r -d '' DATA <<- EOM
{
  "model":"${MODEL}",
  "options": {
    "temperature": 0.0,
    "repeat_last_n": 2
  },
  "messages": [
    {"role":"system", "content": "${SYSTEM_CONTENT}"},
    {"role":"user", "content": "${USER_CONTENT}"}
  ],
  "stream": false,
  "format": "json"
}
EOM

jsonResult=$(Chat "${OLLAMA_URL}" "${DATA}")

messageContent=$(echo "${jsonResult}" | jq '.message.content')

echo "$messageContent" | jq -r 'tostring'

#echo $(Sanitize "${messageContent}")
#country=$(echo "${jsonResult}" | jq '.message.content.country')



