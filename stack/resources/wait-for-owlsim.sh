#!/usr/bin/env bash
# wait-for-owlsim.sh

set -e

CURL="curl --silent --show-error --output /dev/null"
OWLSIM="http://owlsim:9031"
SCIGRAPH="http://scigraph-ontology:9000"

url="${OWLSIM}/getAttributeInformationProfile"

categories="${OWLSIM}/getAttributeInformationProfile?r=HP:0000924&r=HP:0000707&r=HP:0000152&r=HP:0001574&r=HP:0000478&r=HP:0001626&r=HP:0001939&r=HP:0000119&r=HP:0025031&r=HP:0002664&r=HP:0001871&r=HP:0002715&r=HP:0000818&r=HP:0003011&r=HP:0002086&r=HP:0000598&r=HP:0003549&r=HP:0001197&r=HP:0001507&r=HP:0000769"

until [ $(curl --write-out %{http_code} --silent --output /dev/null ${url}) -eq 200 ] ; do
  >&2 echo "owlsim loading"
  sleep 15
done

# At start up biolink runs the below queries and caches their output
# It's useful to run them prior 

echo "initializing owlsim category IC stats"
${CURL} ${categories}

hp_classes=(
    'HP:0025031'
    'HP:0000818'
    'HP:0000707'
    'HP:0001939'
    'HP:0001626'
    'HP:0000119'
    'HP:0000924'
    'HP:0001507'
    'HP:0002715'
    'HP:0000769'
    'HP:0000478'
    'HP:0000598'
    'HP:0003549'
    'HP:0001574'
    'HP:0002664'
    'HP:0001871'
    'HP:0002086'
    'HP:0000152'
    'HP:0003011'
    'HP:0001197'
)

echo "warm up scigraph queries"

for hp in "${hp_classes[@]}"
do
    ${CURL} "${SCIGRAPH}/scigraph/graph/neighbors.json?id=${hp}&direction=INCOMING&depth=40&relationshipType=subClassOf"
done

cmd="$@"
exec $cmd
