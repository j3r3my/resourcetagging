#!/bin/bash
###
# Script runs through an Azure subscription and puts all of the resource groups (rg) in an array
# It then looks at the tags on each rg and in a nested loop, applies any missing tags on resources
#
# Running multiple times will not create duplicate tags
# This script (with jq and filtering commands) will handle `tags\ with\ spaces`
# More information on jq: https://stedolan.github.io/jq/tutorial/

# Usage: ./rgtagger.sh
# Debug: sh -x rgtagger.sh
###

az login # force this so we're looking at the right tenant!

for rg in $(az group list --query [].name --output tsv)
do
    rgTags=$(az group show -n $rg --query tags --output json)
    for resId in $(az resource list -g $rg --query [].id --output tsv)
    do
        resTags=$(az resource show -g $rg --id $resId --query tags --output json)
        tags=$(echo "[$rgTags,$resTags]" | jq '.[0] * .[1]' | tr -d "{}," | tr '\n' ' ' | sed 's/": "/=/g')
        echo "$resId:"
        eval az resource tag --id $resId --tags $tags --query tags --output jsonc
    done
done
