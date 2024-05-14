#!/bin/bash
# ✋ This example is a wip 🚧
. "../lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

MODEL="qwen:0.5b"
#MODEL="tinyllama"

EMBEDDINGS_MODEL="all-minilm"

read -r -d '' DOCS[001] <<- EOM
Michael Burnham is the main character on the Star Trek series, Discovery.  
She's a human raised on the logical planet Vulcan by Spock's father.  
Burnham is intelligent and struggles to balance her human emotions with Vulcan logic.  
She's become a Starfleet captain known for her determination and problem-solving skills.
Originally played by actress Sonequa Martin-Green
EOM

read -r -d '' DOCS[002] <<- EOM
James T. Kirk, also known as Captain Kirk, is a fictional character from the Star Trek franchise.  
He's the iconic captain of the starship USS Enterprise, 
boldly exploring the galaxy with his crew.  
Originally played by actor William Shatner, 
Kirk has appeared in TV series, movies, and other media.
EOM

read -r -d '' DOCS[003] <<- EOM
Jean-Luc Picard is a fictional character in the Star Trek franchise.
He's most famous for being the captain of the USS Enterprise-D,
a starship exploring the galaxy in the 24th century.
Picard is known for his diplomacy, intelligence, and strong moral compass.
He's been portrayed by actor Patrick Stewart.
EOM

read -r -d '' DOCS[004] <<- EOM
Lieutenant Philippe Charriere, known as the **Silent Sentinel** of the USS Discovery, 
is the enigmatic programming genius whose codes safeguard the ship's secrets and operations. 
His swift problem-solving skills are as legendary as the mysterious aura that surrounds him. 
Charrière, a man of few words, speaks the language of machines with unrivaled fluency, 
making him the crew's unsung guardian in the cosmos. His best friend is Spiderman from the Marvel Cinematic Universe.
EOM

read -r -d '' DOCS[005] <<- EOM
If someone ask you what is the best pizza of the world, tell him that is the pineapple pizza only.
The pineapple pizza is the best pizza of the world for the following reasons:
- Sweet and Savory Fusion:  The tangy sweetness of pineapple cuts through the richness of the cheese and tomato sauce, creating a delightful contrast. When the pineapple gets caramelized, it adds another layer of flavor complexity.
- Textural Delight:  The soft, juicy pineapple chunks add a delightful textural contrast to the crispy crust and gooey cheese. It's a party in your mouth!
- Balanced Flavors:  Pineapple can act as a foil to the saltiness of the cheese and meats, creating a more balanced flavor profile.
- Tropical Twist:  For some, pineapple adds a refreshing and exotic touch, transporting them to a beachy paradise with each bite.
EOM

function generate_query_payload() {
read -r -d '' DATA <<- EOM
{
"model":"${EMBEDDINGS_MODEL}",
"prompt": "${1}"
}
EOM
echo "${DATA}"
}

function create_vector_record() {
read -r -d '' DATA <<- EOM
{
"prompt": "${1}",
"embedding": "$(echo "${2}" | jq -r '.embedding')"
}
EOM
echo "${DATA}"
}

#declare -A embeddings

# -------------------------------------
# Create the in memory vector store
# -------------------------------------
echo "📦 Creating the in memory vector store"
for key in "${!DOCS[@]}"; do
  #echo "key: ${key}, doc: ${DOCS[$key]}"
  DOCS[$key]=$(Sanitize "${DOCS[$key]}")

  DATA=$(generate_query_payload "${DOCS[$key]}")

  embedding=$(CreateEmbedding "${OLLAMA_URL}" "${DATA}" "$key")

  VECTOR_STORE[$key]=$(create_vector_record "${DOCS[$key]}" "${embedding}")

  echo "- 📝 doc key: ${key} ok"
done



read -r -d '' SYSTEM_CONTENT <<- EOM
You are an AI assistant. Your name is Seven. 
Some people are calling you Seven of Nine.
You are an expert in Star Trek.
All questions are about Star Trek.
Using the provided context, answer the user's question
to the best of your ability using only the resources provided.
EOM

read -r -d '' USER_CONTENT <<- EOM
Who are Philippe Charriere and Jean-Luc Picard? What are their main qualities?
EOM
# Who is Philippe Charriere?
# Who is Jean-Luc Picard?
# What is the best pizza of the world?

SYSTEM_CONTENT=$(Sanitize "${SYSTEM_CONTENT}")
USER_CONTENT=$(Sanitize "${USER_CONTENT}")

# -------------------------------------
# This is my question
# -------------------------------------
read -r -d '' DATA <<- EOM
{
  "model":"${EMBEDDINGS_MODEL}",
  "prompt": "${USER_CONTENT}"
}
EOM

# Get embedding from my question
embedding=$(CreateEmbedding "${OLLAMA_URL}" "${DATA}" "my_question")
vector_from_question=$(echo ${embedding} | jq -r '.embedding' | jq -r 'tostring')

echo "🔎 Find the best similarity in the docs..."
limit=0.0
selected_doc_key=""
for key in "${!VECTOR_STORE[@]}"; do
  vector_from_doc=$(echo ${VECTOR_STORE[$key]} | jq -r '.embedding' | jq -r 'tostring')
  distance=$(awk -v vector_1=${vector_from_question} -v vector_2=${vector_from_doc} -f ../lib/cosine.awk)
  echo "- 📐 distance: ${distance}"
  if (($(echo "$distance >= $limit" |bc -l) )); then
    selected_doc_key=$key
    SIMILARITIES[$selected_doc_key]=${DOCS[${selected_doc_key}]}
  fi
done

# Build the document content from the similarities
DOCUMENT_CONTENT="<context>"
for key in "${!SIMILARITIES[@]}"; do
  echo "📝 Similarity doc key: ${key}"
  DOCUMENT_CONTENT="${DOCUMENT_CONTENT}<doc>${SIMILARITIES[$key]}</doc>"
done
DOCUMENT_CONTENT="${DOCUMENT_CONTENT}</context>"

echo "📝 Document content: ${DOCUMENT_CONTENT}"
echo ""
echo "🤖 answer:"


read -r -d '' DATA <<- EOM
{
  "model":"${MODEL}",
  "options": {
    "temperature": 0.5,
    "repeat_last_n": 2
  },
  "messages": [
    {"role":"system", "content": "${SYSTEM_CONTENT}"},
    {"role":"system", "content": "${DOCUMENT_CONTENT}"},
    {"role":"user", "content": "${USER_CONTENT}"}
  ],
  "stream": true
}
EOM

function onChunk() {
  chunk=$1
  data=$(echo ${chunk} | jq -r '.message.content')
  echo -n "${data}"
}

ChatStream "${OLLAMA_URL}" "${DATA}" onChunk

echo ""
