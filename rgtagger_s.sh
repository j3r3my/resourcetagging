#!/bin/bash

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
