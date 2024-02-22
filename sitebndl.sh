#!/bin/bash

cd /var/handle/svr || exit
zip sitebndl.zip admpub.bin contactdata.dct repl_admin siteinfo.json

if [[ -z "$S3_SITEBNDL_UPLOAD_URL" ]]; then
  echo "Skipping s3 upload: no upload destination defined for sitebndl."
else
  URL=${S3_SITEBNDL_UPLOAD_URL}
  echo "Uploading sitebndl to s3: $URL"
  aws s3 cp sitebndl.zip $URL
fi
