#!/bin/bash

cd /var/handle/svr
zip sitebndl.zip admpub.bin contactdata.dct repl_admin siteinfo.json

if [[ -z "$S3_SITEBNDL_UPLOAD_URL" ]]; then
  echo "Skipping s3 upload: no upload destination defined."
else
  aws s3 cp sitebndl.zip ${S3_SITEBNDL_UPLOAD_URL}/sitebndl.zip
fi
