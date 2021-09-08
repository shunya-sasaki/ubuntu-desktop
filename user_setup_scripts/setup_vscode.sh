#!/bin/sh
mkdir -p ~/.lib
cp /usr/lib/x86_64-linux-gnu/libxcb.so.1 ~/.lib/
sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' ~/lib/libxcb.so.1
echo "export LD_LIBRARY_PATH=$HOME/.lib" >> ~/.bashrc