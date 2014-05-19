# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Configuration parameters
ram = 4096                            # Ram in MB for each VM
secondaryStorage = 80                 # Size in GB for the secondary virtual HDD
privateNetworkIp = "10.10.10.50"      # IP for the private network between VMs
ibmUsername = "email"                 # email to use to login to ibm.com
ibmPassword = "password"              # password to use to login to ibm.com

# Do not edit below this line
# --------------------------------------------------------------
privateSubnet = privateNetworkIp.split(".")[0...3].join(".")
privateStartingIp = privateNetworkIp.split(".")[3].to_i


$ibm_download = <<SCRIPT
#!/bin/bash
yum install - y wget
cd /tmp

wget --save-cookies cookies.txt --keep-session-cookies --delete-after --post-data="userID=#{ibmUsername}&password=#{ibmPassword}&fromURL=/webapp/iwm/web/reg/pick.do?source=swg-db2expressc&amp;S_PKG=dllinux64&amp;S_TACT=100KG28W&amp;lang=en_US" O- "https://www14.software.ibm.com/webapp/iwm/web/reg/acceptLogin.do?source=swg-db2expressc&S_PKG=dllinux64&S_TACT=100KG28W&lang=en_US" &> /dev/null
wget -q --load-cookies cookies.txt https://iwm.dhe.ibm.com/sdfdl/v2/regs2/db2pmopn/db2_v105/expc/Xa.2/Xb.aA_60_-idZeM1Ka_ueEdfT9PbygBCH4Mq80EwDw4GA/Xc.db2_v105/expc/v10.5fp1_linuxx64_expc.tar.gz/Xd./Xf.LPr.D1vk/Xg.7563769/Xi.swg-db2expressc/XY.regsrvs/XZ.ncy2SWNMhJrLG4x1AhB9mFwYPDI/v10.5fp1_linuxx64_expc.tar.gz
rm cookies.txt

EOF
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos65-x86_64-20140116"
  config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.4.2/centos64-x86_64-20140116.box"
  config.vm.define "db2-express" do |master|
    master.vm.network :public_network, :bridge => 'eth0'
    master.vm.network :private_network, ip: "#{privateSubnet}.#{privateStartingIp}", :netmask => "255.255.255.0", virtualbox__intnet: "db2network"
    master.vm.hostname = "db2-express"

    master.vm.provider "vmware_fusion" do |v|
      v.vmx["memsize"]  = "#{ram}"
    end
    master.vm.provider :virtualbox do |v|
      v.name = master.vm.hostname.to_s
      v.customize ["modifyvm", :id, "--memory", "#{ram}"]
      file_to_disk = File.realpath( "." ).to_s + "/" + v.name + "_secondary_hdd.vdi"
      if ARGV[0] == "up" && ! File.exist?(file_to_disk)
        v.customize ['storagectl', :id, '--name', 'SATA', '--portcount', 2, '--hostiocache', 'on']
        v.customize ['createhd', '--filename', file_to_disk, '--format', 'VDI', '--size', "#{secondaryStorage * 1024}"]
        v.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      end
    end

    master.vm.provision :shell, :path => "provision_for_mount_disk.sh"
    master.vm.provision :shell, :path => "db2.sh", :args => "#{ibmUsername} #{ibmPassword}"
  end
end