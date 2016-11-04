#!/usr/bin/env bash

AM_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/acct_mg.rb"

echo "#!/usr/bin/env bash" > amt

echo "Detected current working directory: $AM_PATH"
echo "ruby $AM_PATH \$@" >> amt

mv amt /usr/local/bin/

chmod +x /usr/local/bin/amt
