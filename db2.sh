#!/bin/bash

# This is needed because we must sync 64 bit packages to 32 bit ones
yum update -y

yum install -y wget nfs-utils libaio* ksh
yum install -y compat-libstdc++* libstdc++* numactl-2.0.7-8.el6.x86_64
yum install -y pam.i686

cd /tmp
wget -q https://iwm.dhe.ibm.com/sdfdl/v2/regs2/db2pmopn/db2_v105/expc/Xa.2/Xb.aA_60_-idZeM1Ka_ueEdfT9PbygBCH4Mq80EwDw4GA/Xc.db2_v105/expc/v10.5fp1_linuxx64_expc.tar.gz/Xd./Xf.LPr.D1vk/Xg.7563769/Xi.swg-db2expressc/XY.regsrvs/XZ.ncy2SWNMhJrLG4x1AhB9mFwYPDI/v10.5fp1_linuxx64_expc.tar.gz

tar -xvf v10.5fp1_linuxx64_expc.tar.gz

rm v10.5fp1_linuxx64_expc.tar.gz

# Launch the installer
/tmp/expc/db2_install -n -b /opt/ibm/db2/V10.5  -p expc

rm -r /tmp/expc/

# Groups
/usr/sbin/groupadd -g 510 db2grp1
/usr/sbin/groupadd -g 511 db2fgrp1
/usr/sbin/groupadd -g 999 db2iadm1
/usr/sbin/groupadd -g 998 db2fadm1
/usr/sbin/groupadd -g 997 dasadm1
/usr/sbin/groupadd -g 1000 db2dev


# Users
/usr/sbin/useradd -g db2grp1 -m -d /home/db2inst1 db2inst1 -p db2inst1
/usr/sbin/useradd -g db2fgrp1 -m -d /home/db2fenc1 db2fenc1 -p db2fenc1
/usr/sbin/useradd -g dasadm1 -m -d /home/dasusr1 dasusr1 -p dasusr1

# Instance
/opt/ibm/db2/V10.5/instance/db2icrt -a SERVER -p 50000 -u db2fenc1 db2inst1

# Das user
/opt/ibm/db2/V10.5/instance/dascrt -u dasusr1

# Remote administration
echo 'ibm-db2 523/tcp # IBM DB2 DAS' >> /etc/services
echo 'ibm-db2 523/udp # IBM DB2 DAS' >> /etc/services
echo 'db2c_db2inst1 50000/tcp # IBM DB2 instance - db2inst1' >> /etc/services

sudo -u db2inst1 /opt/ibm/db2/V10.5/bin/db2 update dbm cfg using SVCENAME db2c_db2inst1
sudo -u db2inst1 /home/db2inst1/sqllib/adm/db2set DB2COMM=tcpip
sudo -u db2inst1 /home/db2inst1/sqllib/adm/db2set DB2_EXTENDED_OPTIMIZATION=ON
sudo -u db2inst1 /home/db2inst1/sqllib/adm/db2set DB2_DISABLE_FLUSH_LOG=ON
sudo -u db2inst1 /home/db2inst1/sqllib/adm/db2set AUTOSTART=YES
sudo -u db2inst1 /home/db2inst1/sqllib/adm/db2set DB2_HASH_JOIN=Y
sudo -u db2inst1 /home/db2inst1/sqllib/adm/db2set DB2_PARALLEL_IO=*
sudo -u db2inst1 /home/db2inst1/sqllib/adm/db2set DB2CODEPAGE=1208
sudo -u db2inst1 /home/db2inst1/sqllib/adm/db2set DB2_COMPATIBILITY_VECTOR=3F
sudo -u db2inst1 /opt/ibm/db2/V10.5/bin/db2 update dbm cfg using INDEXREC ACCESS

# Start the instance
sudo -u db2inst1 /home/db2inst1/sqllib/adm/db2start

# Start the administration server
sudo -u dasusr1 /home/dasusr1/das/bin/db2admin stop
sudo -u dasusr1 /home/dasusr1/das/bin/db2admin start

# Autostart
su - db2inst1
/home/db2inst1/sqllib/bin/db2iauto -on db2inst1
exit

# Admin interface autostart
mkdir /home/dasusr1/script
touch /home/dasusr1/script/startadmin.sh
echo '#!/bin/sh' >> /home/dasusr1/script/startadmin.sh
echo '# The following three lines have been added by UDB DB2.' >> /home/dasusr1/script/startadmin.sh
echo 'if [ -f /home/dasusr1/das/dasprofile ]; then' >> /home/dasusr1/script/startadmin.sh
echo '. /home/dasusr1/das/dasprofile' >> /home/dasusr1/script/startadmin.sh
echo 'fi' >> /home/dasusr1/script/startadmin.sh
echo 'db2admin start' >> /home/dasusr1/script/startadmin.sh

chown dasusr1:dasadm1 -R /home/dasusr1/script
chmod 777 /home/dasusr1/script/startadmin.sh

# Finalizing
echo '# Something useful for DB2' >> /home/db2inst1/.bashrc
echo 'export PATH=/home/db2inst1/scripts:$PATH' >> /home/db2inst1/.bashrc
echo 'export DB2CODEPAGE=1208' >> /home/db2inst1/.bashrc

echo 'export DB2CODEPAGE=1208' >> /home/db2inst1/sqllib/db2profile

echo 'DB2INSTANCE=db2inst1' >> /etc/profile
echo 'export DB2INSTANCE' >> /etc/profile
echo 'INSTHOME=/home/db2inst1' >> /etc/profile
echo 'export DB2CODEPAGE=1208' >> /etc/profile