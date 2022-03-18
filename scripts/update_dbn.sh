#!/bin/bash

cp /etc/dbntool/dbntool /usr/bin/dbntool
echo "Pushed update to /usr/bin/"
cp /etc/dbntool/dbntool-completion.bash /usr/share/bash-completion/completions/dbntool
source /usr/share/bash-completion/completions/dbntool
cp /etc/dbntool/scripts/prod_auto-push-reload.sh /usr/bin/dbnpush
echo "Updated /usr/bin/dbnpush"
echo "Pushed dbntool to /usr/share/bash-completions/completion and sourced"
