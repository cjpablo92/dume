#!/bin/bash
set -e
source ./libs/logger.sh
source ./libs/conf_manager.sh

export VERBOSE=true

me=`basename "$0"`

file="dume-v"$(date +%Y%m%d-%H%M%S)".tar.gz"
workspace=".workspace_temp"
project_folder="$workspace/dume"

log_info "Creating tar.gz to distribute ..."

# clear old workspace
rm -rf $workspace
mkdir -p "$project_folder"
rm -rf *.tar.gz

# copy project
ls . | grep -v $workspace | grep -v $me | xargs -n1 -L1 -I@ cp -r @ ./$project_folder/

# create tar 
tar czf $file -C ./$project_folder .

# remove temp workspace
rm -rf $workspace

log_info "Creating tar.gz to distribute ... DONE!"








exit 0

# TODO: Test this idea ...

# to base64
self_extract_script="dume.sh"
base64_file=$(cat $file | base64)
rm -f $self_extract_script

echo '#!/bin/bash' > $self_extract_script
echo 'set -e' >> $self_extract_script
echo 'TEMP_FILE=".temp.tar.gz"' >> $self_extract_script
echo 'cat '"'" $base64_file "'"' | base64 --decode > $TEMP_FILE' >> $self_extract_script
echo 'tar xfv $TEMP_FILE' >> $self_extract_script
chmod +x $self_extract_script

