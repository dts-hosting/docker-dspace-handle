#!/bin/sh

HANDLE_BIN="/opt/handle/bin"
HANDLE_SVR="/var/handle/svr"

# Build and configure the server
python3 /home/handle/build.py $HANDLE_BIN $HANDLE_SVR

# https://wiki.lyrasis.org/display/DSDOC7x/Handle.Net+Registry+Support#Handle.NetRegistrySupport-ToinstallaHandleresolveronaseparatemachine
sed -i 's|net.handle.server.Main|-Ddspace.handle.plugin.configuration=/home/handle/config/handle-dspace-plugin.cfg net.handle.server.Main|' /opt/handle/bin/hdl

# sitebndl components
cp /home/handle/config/contactdata.dct /var/handle/svr/contactdata.dct
echo "300:0.NA/YOUR_PREFIX" > /var/handle/svr/repl_admin

# Start the handle server
exec "$HANDLE_BIN/hdl-server" $HANDLE_SVR 2>&1
