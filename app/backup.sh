#!/usr/bin/env bash

shelldir=$(cd $(dirname $0) && pwd)

backup="$HOME/.acct"

[ ! -d $backup ] && mkdir $backup

today=$(date +%Y-%m-%d)

cp "$shelldir/data/am.db" "$backup/am-$today.db"
