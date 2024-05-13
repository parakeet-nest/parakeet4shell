#!/bin/bash
# ✋ This example is a wip 🚧
. "../lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

MODEL="phi3"
#MODEL="tinydolphin"
#MODEL="gemma:2b"
#MODEL="qwen:0.5b" -> does not work
#MODEL="tinyllama" -> does not work
#MODEL="llama3" #-> does not work with chicken

read -r -d '' SYSTEM_CONTENT <<- EOM
You are a helpful AI assistant. The user will enter the name of an animal.
The assistant will then return the following information about the annimal:
- the scientific name of the animal (the name of json field is: scientific_name)
- the main species of the animal  (the name of json field is: main_species)
- the decimal average length of the animal (the name of json field is: average_length)
- the decimal average weight of the animal (the name of json field is: average_weight)
- the decimal average lifespan of the animal (the name of json field is: average_lifespan)
- the countries where the animal lives into json array of strings (the name of json field is: countries)
Output the results in JSON format and trim the spaces of the sentence.
EOM

read -r -d '' USER_CONTENT <<- EOM
chicken
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


#echo "$messageContent" | jq -r 'tostring'
#echo ""
echo "$messageContent" | jq -r 'tostring' | jq -c '{ scientific_name, main_species, average_length, average_weight, average_lifespan, countries }'

#echo $(Sanitize "${messageContent}")
#country=$(echo "${jsonResult}" | jq '.message.content.country')



