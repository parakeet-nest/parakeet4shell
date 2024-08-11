#!/bin/bash
# ✋ This example is a wip 🚧
. "../lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

#MODEL="phi3"
#MODEL="tinyllama"
MODEL="qwen2:0.5b" 

read -r -d '' TOOLS_CONTENT <<- EOM
You have access to the following tools:
BEGIN LIST
Name: hello,
Description: When you want to say hello to a given person, give the name of this person,
Parameters: name

Name: addNumbers,
Description: Make an addition of the two given numbers,
Parameters: a, b
END LIST

If the question of the user matched the description of a tool, the tool will be called.
To call a tool, respond with a JSON object with the following structure: 
{
  \"tool\": <name of the called tool>,
  \"parameters\": <parameters for the tool matching the above parameters list>
}

search the name of the tool in the list of tools with the Name field
EOM

read -r -d '' SYSTEM_CONTENT <<- EOM
You are a helpful AI assistant. The user will enter a sentence.
If the sentence is near the description of a tool, the assistant will call the tool.
Output the results in JSON format and trim the spaces of the sentence.
EOM

read -r -d '' USER_CONTENT <<- EOM
add 5 and 40
EOM

#read -r -d '' USER_CONTENT <<- EOM
#say hello to bob
#EOM

# Try with: 
# say hello to bob
# add 5 and 40

TOOLS_CONTENT=$(Sanitize "${TOOLS_CONTENT}")
SYSTEM_CONTENT=$(Sanitize "${SYSTEM_CONTENT}")
USER_CONTENT=$(Sanitize "${USER_CONTENT}")

read -r -d '' DATA <<- EOM
{
  "model":"${MODEL}",
  "options": {
    "temperature": 0.0,
    "repeat_last_n": 2
  },
  "messages": [
    {"role":"system", "content": "${TOOLS_CONTENT}"},
    {"role":"system", "content": "${SYSTEM_CONTENT}"},
    {"role":"user", "content": "${USER_CONTENT}"}
  ],
  "stream": false,
  "format": "json"
}
EOM

jsonResult=$(Chat "${OLLAMA_URL}" "${DATA}")

messageContent=$(echo "${jsonResult}" | jq '.message.content')

echo "🤖 You should call this tool with these parameters:"
echo "$messageContent" | jq -r 'tostring' | jq -c '{ tool, parameters }'

toolName=$(echo "$messageContent" | jq -r 'tostring' | jq -r '.tool')
toolParameters=$(echo "$messageContent" | jq -r 'tostring' | jq -r '.parameters')

echo ""
function call_tool() {
    echo "🤖 Calling tool: ${1} with parameters: ${2}"
}

call_tool $toolName "$toolParameters"
