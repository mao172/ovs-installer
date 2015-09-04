#! /bin/sh -x

script_root=$(cd $(dirname $0) && pwd)

VERSION=2.4.0

while getopts v: OPT
do
  case $OPT in
    "v" ) VERSION="$OPTARG";;
  esac
done

OVS_NAME="openvswitch-${VERSION}"

yum install gcc make automake rpm-build redhat-rpm-config python-devel openssl-devel kernel-devel kernel-debug-devel -y
yum install kernel-abi-whitelists -y
yum install wget -y

adduser ovswitch

if [ -f ${script_root}/lib/build.sh ]; then
  cat  ${script_root}/lib/build.sh | su - ovswitch -c "bash -s -- -v ${VERSION}"
else
  su - ovswitch -c  "curl -L https://raw.githubusercontent.com/mao172/ovs-installer/master/lib/build.sh | bash -s -- -v ${VERSION}"
fi

# yum install /home/ovswitch/rpmbuild/RPMS/x86_64/${OVS_NAME}-1.x86_64.rpm -y
# systemctl start openvswitch
# ovs-vsctl show
