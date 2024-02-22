#!/bin/bash

HANDLE_BIN="/opt/handle/bin"
HANDLE_SVR="/var/handle/svr"

# Build and configure the server
python3 /home/handle/build.py $HANDLE_BIN $HANDLE_SVR

# Download handle dspace plugin cfg if s3 url defined
if [[ -z "$S3_HANDLE_DSPACE_PLUGIN_CFG_URL" ]]; then
  echo "Skipping s3 download: no download url defined for handle dspace plugin cfg."
else
  URL=${S3_HANDLE_DSPACE_PLUGIN_CFG_URL}
  echo "Downloading handle dspace plugin cfg from s3: $URL"
  aws s3 cp $URL /home/handle/config/handle-dspace-plugin.cfg
fi

# https://wiki.lyrasis.org/display/DSDOC7x/Handle.Net+Registry+Support#Handle.NetRegistrySupport-ToinstallaHandleresolveronaseparatemachine
# set path to cfg for server startup
sed -i 's|net.handle.server.Main|-Ddspace.handle.plugin.configuration=/home/handle/config/handle-dspace-plugin.cfg net.handle.server.Main|' /opt/handle/bin/hdl

# sitebndl components
cp /home/handle/config/contactdata.dct /var/handle/svr/contactdata.dct
echo "300:0.NA/YOUR_PREFIX" > /var/handle/svr/repl_admin

# Start the handle server
exec "$HANDLE_BIN/hdl-server" $HANDLE_SVR 2>&1
