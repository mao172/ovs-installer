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

check_platform() {
  platform_family="any"
  if [ -f /etc/redhat-release ]; then
    platform_family="rhel"
    platform=$(cat /etc/redhat-release | awk '{print $1}')
    platform_version=$(cat /etc/redhat-release | awk '{print $3}')
  fi

}

ge() {
  ret=$(echo $1 $2 | awk '{printf ("%d", $1>=$2)}')
  test ${ret} -eq 1
  return $?
}

lt() {
  ret=$(echo $1 $2 | awk '{printf ("%d", $1<$2)}')
  test ${ret} -eq 1
  return $?
}

yum install gcc make automake rpm-build redhat-rpm-config python-devel openssl-devel kernel-devel kernel-debug-devel -y
yum install kernel-abi-whitelists -y
yum install wget -y

adduser ovswitch

if [ -f ${script_root}/lib/build.sh ]; then
  cat  ${script_root}/lib/build.sh | su - ovswitch -c "bash -s -- -v ${VERSION}"
else
  su - ovswitch -c  "curl -L https://raw.githubusercontent.com/mao172/ovs-installer/master/lib/build.sh | bash -s -- -v ${VERSION}"
fi

check_platform

if ge ${platform_version} 6 && lt ${platform_version} 7;  then
  yum install /home/ovswitch/rpmbuild/RPMS/**/kmod-${OVS_NAME}*.rpm -y
fi
yum install /home/ovswitch/rpmbuild/RPMS/**/${OVS_NAME}*.rpm -y
# systemctl start openvswitch
# ovs-vsctl show
