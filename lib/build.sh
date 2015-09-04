#! /bin/sh
set -x

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

build_rpm() {
  OVS_NAME=$1

  mkdir -p ~/rpmbuild/SOURCES
  cd ~/rpmbuild/SOURCES/
  wget http://openvswitch.org/releases/${OVS_NAME}.tar.gz
  tar xfz ${OVS_NAME}.tar.gz

  wget https://raw.githubusercontent.com/mao172/ovs-installer/master/patch/${OVS_NAME}.patch

  cd ${OVS_NAME} || return $?

  if ge ${platform_version} 7 ; then
    sed -i.org -e 's/openvswitch-kmod, //g' rhel/openvswitch.spec
  fi

  if [ -f ../${OVS_NAME}.patch ]; then
    patch -p1 < ../${OVS_NAME}.patch
  fi

  rpmbuild -bb --without check rhel/openvswitch.spec || return $?

  if ge ${platform_version} 6 && lt ${platform_version} 7;  then
    cp rhel/openvswitch-kmod.files ../
    rpmbuild -bb rhel/openvswitch-kmod-rhel6.spec || return $?
  fi
}

VERSION=2.3.2

while getopts v: OPT
do
  case $OPT in
    "v" ) VERSION="$OPTARG";;
  esac
done

check_platform

if [ ${platform_family} == "rhel" ]; then
  build_rpm "openvswitch-${VERSION}"
fi
