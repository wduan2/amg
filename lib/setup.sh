#!/usr/bin/env bash

AM_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/amg.rb"

echo "#!/usr/bin/env bash" > am

echo "Detected current working directory: $AM_PATH"
echo "ruby $AM_PATH \$@" >> am

mv am /usr/local/bin/

chmod +x /usr/local/bin/am
