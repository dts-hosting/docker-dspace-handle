#!/usr/bin/env python3

""" This script takes the configuration templates and creates new ones for the
handle server based upon environment variables """

import sys
import os
import subprocess
import string
import base64

CONFIG_DIR = os.path.dirname(os.path.abspath(__file__)) + '/config/'
HANDLE_BIN = sys.argv[1]
OUT_DIR = sys.argv[2]

# Config options
config = {
    'HANDLE_HOST_IP': os.getenv('HANDLE_HOST_IP', '0.0.0.0'),
    'REPLICATION_ADMINS': ' '.join(['"%s"' % s for s in os.getenv('REPLICATION_ADMINS', "").split(" ")]),
    'SERVER_ADMINS': ' '.join(['"%s"' % s for s in os.getenv('SERVER_ADMINS', "").split(" ")]),
    'SERVER_PRIVATE_KEY_PEM': os.getenv('SERVER_PRIVATE_KEY_PEM', '').encode('ASCII'),  # Explict convert to byte string
    'SERVER_PUBLIC_KEY_PEM': os.getenv('SERVER_PUBLIC_KEY_PEM', '').encode('ASCII'),  # Explict convert to byte string
    'STORAGE_TYPE': os.getenv('STORAGE_TYPE', '')
}

# Create private / public keys based on config using hdl-convert-key tool
# The handle server works with DSA format, not PEM formats.
handle_convert_cmd = os.path.join(HANDLE_BIN, "hdl-convert-key")
with subprocess.Popen([handle_convert_cmd], stdin=subprocess.PIPE, stdout=subprocess.PIPE) as p:
    private_key_dsa = p.communicate(input=config['SERVER_PRIVATE_KEY_PEM'])[0]
    with open(os.path.join(OUT_DIR, "admpriv.bin"), 'wb') as f:
        f.write(private_key_dsa)
    with open(os.path.join(OUT_DIR, "privkey.bin"), 'wb') as f:
        f.write(private_key_dsa)

with subprocess.Popen([handle_convert_cmd], stdin=subprocess.PIPE, stdout=subprocess.PIPE) as p:
    public_key_dsa = p.communicate(input=config['SERVER_PUBLIC_KEY_PEM'])[0]
    with open(os.path.join(OUT_DIR, "admpub.bin"), 'wb') as f:
        f.write(public_key_dsa)
    with open(os.path.join(OUT_DIR, "pubkey.bin"), 'wb') as f:
        f.write(public_key_dsa)

# Build a base64 version of key for the siteinfo file
config['SERVER_PUBLIC_KEY_DSA_BASE64'] = base64.b64encode(public_key_dsa).decode('ASCII')


# Build the templates
def generate_template(template, out_file, cfg):
    """Generate an output file from a config"""
    with open(template, 'r') as file:
        template = string.Template(file.read())
        s = template.substitute(cfg)

        with open(out_file, 'w') as out:
            out.write(s)


generate_template(os.path.join(CONFIG_DIR, 'config.dct'), os.path.join(OUT_DIR, 'config.dct'), config)
generate_template(os.path.join(CONFIG_DIR, 'siteinfo.json'), os.path.join(OUT_DIR, 'siteinfo.json'), config)
