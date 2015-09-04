#! /bin/sh
set -x

OVS_NAME="openvswitch-$2"

mkdir -p ~/rpmbuild/SOURCES
cd ~/rpmbuild/SOURCES/
wget http://openvswitch.org/releases/${OVS_NAME}.tar.gz
tar xfz ${OVS_NAME}.tar.gz 
cd ${OVS_NAME}
sed -i.org -e 's/openvswitch-kmod, //g' rhel/openvswitch.spec
rpmbuild -bb --without check rhel/openvswitch.spec

