#!/bin/bash
# ✋ This example is a wip 🚧
. "../lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

MODEL="qwen:0.5b"
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
Lieutenant Philippe Charrière, known as the **Silent Sentinel** of the USS Discovery, 
is the enigmatic programming genius whose codes safeguard the ship's secrets and operations. 
His swift problem-solving skills are as legendary as the mysterious aura that surrounds him. 
Charrière, a man of few words, speaks the language of machines with unrivaled fluency, 
making him the crew's unsung guardian in the cosmos. His best friend is Spiderman from the Marvel Cinematic Universe.
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


# -------------------------------------
# This is my question
# -------------------------------------
read -r -d '' DATA <<- EOM
{
  "model":"${EMBEDDINGS_MODEL}",
  "prompt": "Who is Jean Luc Picard?"
}
EOM

# "prompt": "Who is Philippe Charrière?"


# Get embedding from my question
embedding=$(CreateEmbedding "${OLLAMA_URL}" "${DATA}" "my_question")
#echo ${embedding} | jq -r '.embedding'
vector_from_question=$(echo ${embedding} | jq -r '.embedding' | jq -r 'tostring')

#vector_from_doc=$(echo ${VECTOR_STORE[001]} | jq -r '.embedding' | jq -r 'tostring')
#awk -v vector_1=${vector_from_question} -v vector_2=${vector_from_doc} -f ../lib/cosine.awk

# SearchMaxSimilarity: 
# finds the vector record in VECTOR_STORE with 
# the maximum cosine distance similarity to the provided vector record (from the question).

echo "🔎 Find the best similarity in the docs..."
max_distance=-1.0
selected_doc_key=""
for key in "${!VECTOR_STORE[@]}"; do
  vector_from_doc=$(echo ${VECTOR_STORE[$key]} | jq -r '.embedding' | jq -r 'tostring')
  distance=$(awk -v vector_1=${vector_from_question} -v vector_2=${vector_from_doc} -f ../lib/cosine.awk)
  echo "- 📐 distance: ${distance}"
  if (($(echo "$distance > $max_distance" |bc -l) )); then
    max_distance=$distance
    selected_doc_key=$key
  fi
done

echo "🔑 Selected doc key: ${selected_doc_key} with distance: ${max_distance}"
echo ""
echo "📝 Selected doc:"
echo "${DOCS[${selected_doc_key}]}"