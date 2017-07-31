#!/usr/bin/env bash

shelldir=$(dirname $0)
backup="$HOME/.acct"

[ ! -d $backup ] && mkdir $backup

today=$(date +%Y-%m-%d)

cp "$shelldir/data/am.db" "$backup/am-$today.db"
