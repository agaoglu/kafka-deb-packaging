#!/bin/bash
set -e
set -u
name=kafka
version=0.8.0
description="Apache Kafka is a distributed publish-subscribe messaging system."
url="https://kafka.apache.org/"
arch="all"
section="misc"
license="Apache Software License 2.0"
package_version="-1"
src_package="kafka-${version}-src.tgz"
#download_url="http://mirrors.sonic.net/apache/incubator/kafka/kafka-${version}/${src_package}"
download_url="http://www.eu.apache.org/dist/kafka/0.8.0/kafka-0.8.0-src.tgz"
origdir="$(pwd)"

#_ MAIN _#
rm -rf ${name}*.deb
if [[ ! -f "${src_package}" ]]; then
  wget ${download_url}
fi
mkdir -p tmp && pushd tmp
rm -rf kafka
mkdir -p kafka
cd kafka
mkdir -p build/usr/lib/kafka
mkdir -p build/etc/default
mkdir -p build/etc/init
mkdir -p build/etc/kafka
mkdir -p build/var/log/kafka

cp ${origdir}/kafka-broker.default build/etc/default/kafka-broker
cp ${origdir}/kafka-broker.upstart.conf build/etc/init/kafka-broker.conf

tar zxf ${origdir}/${src_package}
cd kafka-${version}-src
./sbt update
./sbt "++2.10.3 release-tar"
mv config/log4j.properties config/server.properties ../build/etc/kafka
mv target/RELEASE/kafka_2.10.3-0.8.0/* ../build/usr/lib/kafka
cd ../build
chmod 755 usr/lib/kafka/bin/*.sh

fpm -t deb \
    -n ${name} \
    -v ${version}${package_version} \
    --description "${description}" \
    --url="{$url}" \
    -a ${arch} \
    --category ${section} \
    --vendor "" \
    --license "${license}" \
    -m "${USER}@localhost" \
    --prefix=/ \
    -s dir \
    -- .
mv kafka*.deb ${origdir}
popd
