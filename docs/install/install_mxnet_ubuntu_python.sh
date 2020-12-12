#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

######################################################################
# This script installs MXNet with required dependencies on a Ubuntu Machine.
# Tested on Ubuntu 16.04+ distro.
# Important Maintenance Instructions:
#    Align changes with CI in /ci/docker/install/ubuntu_core.sh
#    and ubuntu_python.sh
######################################################################

set -ex
apt-get update
apt-get install -y \
    apt-transport-https \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    libatlas-base-dev \
    libcurl4-openssl-dev \
    libjemalloc-dev \
    liblapack-dev \
    libopenblas-dev \
    libopencv-dev \
    libzmq3-dev \
    ninja-build \
    python-dev \
    python3-dev \
    software-properties-common \
    sudo \
    unzip \
    virtualenv \
    wget autoconf automake libtool nasm libturbojpeg
    
wget -nv https://bootstrap.pypa.io/get-pip.py
echo "Installing for Python 3..."
python3 get-pip.py
pip3 install --user -r requirements.txt
echo "Installing for Python 2..."
python2 get-pip.py
pip2 install --user -r requirements.txt

apt-get install autoconf automake libtool nasm
JPEG_TURBO_VERSION=1.5.2 && \
wget -q -O - https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${JPEG_TURBO_VERSION}.tar.gz | tar -xzf - && \
cd libjpeg-turbo-${JPEG_TURBO_VERSION} && \
autoreconf -fiv && \
./configure --enable-shared --prefix=/usr 2>&1 >/dev/null && \
make -j"$(nproc)" install 2>&1 >/dev/null && \
rm -rf libjpeg-turbo-${JPEG_TURBO_VERSION}

cd ..

cd ../../

echo "Building MXNet core. This can take few minutes..."
make -j $(nproc) 
