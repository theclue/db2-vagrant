#!/bin/bash

# This is needed because we must sync 64 bit packages to 32 bit ones
yum update -y

yum install -y wget nfs-utils libaio* ksh compat-libstdc++* libstdc++* numactl.x86_64 pam.i686 yum install libstdc++.i686

cp /vagrant/v10.5fp1_linuxx64_expc.tar.gz /tmp
cd /tmp

tar -xvf v10.5fp1_linuxx64_expc.tar.gz

rm -f v10.5fp1_linuxx64_expc.tar.gz

# Launch the installer using the provided Response File
/tmp/expc/db2setup -r /vagrant/db2expc.rsp

rm -r -f /tmp/expc/