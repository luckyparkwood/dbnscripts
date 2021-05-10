#!/bin/bash

cp /etc/dbntool/dbntool /usr/bin/dbntool
echo "Pushed update to /usr/bin/"
cp /etc/dbntool/dbntool-completion.bash /usr/share/bash-completion/completions/dbntool
source /usr/share/bash-completion/completions/dbntool
echo "Pushed dbntool to /usr/share/bash-completions/completion and sourced"
