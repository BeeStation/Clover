#!/bin/bash
set -euo pipefail

source buildByond.conf

wget -O ./librust_g.so "https://github.com/BeeStation/rust-g/releases/download/$RUST_G_VERSION/full_librust_g.so"
chmod +x ./librust_g.so
ldd ./librust_g.so
