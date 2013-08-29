#!/bin/sh -vex

test -z $@ && exit 1


usage(){
  cat << EOF
  usage $0 options
  
  This script will download go sources from googlecode
  then it will create rpms of it

  OPTIONS:
    -h Show this message
    -v Version of the go lang to use
EOF
}

GO_VERSION=

while getopts "v:" OPTION; do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    v)
      GO_VERSION=$OPTARG
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done

test -z $GO_VERSION && { usage; exit 1; }

# get the lastest go sources
test -f go${GO_VERSION}.src.tar.gz && rm -rf go${GO_VERSION}.src.tar.gz

wget https://go.googlecode.com/files/go${GO_VERSION}.src.tar.gz

# build the src rpm
rpmbuild -bs --nodeps --define "_sourcedir ." --define "_srcrpmdir ." go.spec

# either mock or rpmbuild
build_dir="$(mktemp -d)"
mkdir -p $build_dir/{SOURCES,RPMS,SRPMS,BUILD,SPECS}
rpmbuild --rebuild --define "_topdir ${build_dir}" go-${GO_VERSION}-1.src.rpm

mv $build_dir/RPMS/*.rpm .
