### Account Manager Command Line Tool
##### Provides CRUD function to help manage account

**Requirements:**

Install SQLite engine: https://www.sqlite.org/download.html

~~Install MySQL~~

**Note: The gem has not been completed, so run as gem won't get all the functions** 

**Please use the alias 'am'**

To create the alias 'am'
```
sh app/alias.sh
```

Show help information
```
am -h
```

**Note: All the arguments must be separated by comma (no space is allowed)**
Add new account
```
am -a label,username,password
```
Update username
```
am -u label,new_username
```
Update password
```
am -p label,new_password
```

Dependencies:

ap

colorize

sqlite3

~~mysql2~~


TODO: Create general password for showing real passwords

TODO: Abandon the alias mode since STDIN doesn't work with special character without escaping
