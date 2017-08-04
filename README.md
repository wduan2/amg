**Requirements:**

Install SQLite engine: https://www.sqlite.org/download.html

```
gem build am.gemspec
```

```
gem install amg-1.0.0.gem
```

Show help information
```
amg -h
```

Add new account
```
amg -a label username password
```
Update username
```
amg -u label new_username
```
Update password
```
amg -p label new_password
```
List
```
amg -l
```
Find
```
amg -f label
```

Dependencies:

sqlite3
