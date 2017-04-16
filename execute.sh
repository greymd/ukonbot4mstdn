#!/bin/bash
MASTODON_HOST="" # Fill in your mastodon's host
ACCESS_TOKEN="" #Fill in your access_token
SEARCH_SOURCE="うこん"
SEARCH_SOURCE="う|こ|ん"
SEARCH_PATTERNS="うこん|うんこ"

bot_shuf(){
    perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);'
}

update(){
    curl -X POST -sS "https://${MASTODON_HOST}/api/v1/statuses" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -d "status=$1"
}

patterns() {
    while read line;
    do
        echo "$line" \
            | tr '|' '\n' \
            | grep -o . \
            | bot_shuf \
            | head -n 1
    done < <(yes "$SEARCH_SOURCE" | head -n 90) \
        | awk NF \
        | tr -d '\n'
}

match() {
    local _pat="$1"
    local _status="$2"
    echo $_status | grep -o "$_pat" | grep -c .
}

main () {
    generated="$(patterns)"
    results="$generated"
    while read pat;
    do
        results="${results}"$'\n'"${pat}は$(match "$pat" "$generated")個でてきました。"
    done < <(echo "$SEARCH_PATTERNS" | tr '|' '\n')
    echo "$results"
}

main "$@"
