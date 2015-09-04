#! /bin/sh -x

script_root=$(cd $(dirname $0) && pwd)

VERSION='2.3.2'
OVS_NAME="openvswitch-${VERSION}"

yum install gcc make automake rpm-build redhat-rpm-config python-devel openssl-devel kernel-devel kernel-debug-devel -y
yum install wget -y

adduser ovswitch

if [ -f ${script_root}/lib/build.sh ]; then
  bash ${script_root}/lib/build.sh -v ${VERSION}
else
  su - ovswitch -c  "curl -L https://raw.githubusercontent.com/mao172/ovs-installer/master/lib/build.sh | bash -s -- -v ${VERSION}"
fi

# yum install /home/ovswitch/rpmbuild/RPMS/x86_64/${OVS_NAME}-1.x86_64.rpm -y
# systemctl start openvswitch
# ovs-vsctl show
