#!/bin/sh
set -e

# Setup ohos-sdk
query_component() {
  component=$1
  curl -fsSL 'https://ci.openharmony.cn/api/daily_build/build/list/component' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Content-Type: application/json' \
    --data-raw '{"projectName":"openharmony","branch":"master","pageNum":1,"pageSize":10,"deviceLevel":"","component":"'${component}'","type":1,"startTime":"2025080100000000","endTime":"20990101235959","sortType":"","sortField":"","hardwareBoard":"","buildStatus":"success","buildFailReason":"","withDomain":1}'
}
sdk_download_url=$(query_component "ohos-sdk-public" | jq -r ".data.list.dataList[0].obsPath")
curl $sdk_download_url -o ohos-sdk-public.tar.gz
mkdir -p /opt/ohos-sdk
tar -zxf ohos-sdk-public.tar.gz -C /opt/ohos-sdk
cd /opt/ohos-sdk/linux
unzip -q native-*.zip
unzip -q toolchains-*.zip
cd - >/dev/null

# setup env
export OHOS_SDK=/opt/ohos-sdk/linux
export AS=${OHOS_SDK}/native/llvm/bin/llvm-as
export CC="${OHOS_SDK}/native/llvm/bin/clang --target=aarch64-linux-ohos"
export CXX="${OHOS_SDK}/native/llvm/bin/clang++ --target=aarch64-linux-ohos"
export LD=${OHOS_SDK}/native/llvm/bin/ld.lld
export STRIP=${OHOS_SDK}/native/llvm/bin/llvm-strip
export RANLIB=${OHOS_SDK}/native/llvm/bin/llvm-ranlib
export OBJDUMP=${OHOS_SDK}/native/llvm/bin/llvm-objdump
export OBJCOPY=${OHOS_SDK}/native/llvm/bin/llvm-objcopy
export NM=${OHOS_SDK}/native/llvm/bin/llvm-nm
export AR=${OHOS_SDK}/native/llvm/bin/llvm-ar
export CFLAGS="-fPIC -D__MUSL__=1"
export CXXFLAGS="-fPIC -D__MUSL__=1"

# Build ncurses
wget https://mirrors.ustc.edu.cn/gnu/ncurses/ncurses-6.5.tar.gz
tar -zxf ncurses-6.5.tar.gz
cd ncurses-6.5
./configure \
    --host=aarch64-linux \
    --prefix=/opt/ncurses-6.5-ohos-arm64 \
    --without-shared \
    --without-debug \
    --with-strip-program=$STRIP \
    --enable-termcap \
    --with-fallbacks=linux,xterm,xterm-256color,vt100
make -j$(nproc) hashsize=1024
make install
cd ..

# Build zsh
curl -L -O https://sourceforge.net/projects/zsh/files/zsh/5.9/zsh-5.9.tar.xz
tar -xf zsh-5.9.tar.xz
cd zsh-5.9
./configure \
    --host=aarch64-linux \
    --prefix=/opt/zsh-5.9-ohos-arm64 \
    --disable-dynamic \
    --with-ncurses=/opt/ncurses-6.5-ohos-arm64 \
    CPPFLAGS="-I/opt/ncurses-6.5-ohos-arm64/include" \
    LDFLAGS="-L/opt/ncurses-6.5-ohos-arm64/lib"
make -j$(nproc)
make install
cp LICENCE /opt/zsh-5.9-ohos-arm64
cd ..

# Codesign
/opt/ohos-sdk/linux/toolchains/lib/binary-sign-tool sign -inFile /opt/zsh-5.9-ohos-arm64/bin/zsh -outFile /opt/zsh-5.9-ohos-arm64/bin/zsh -selfSign 1

cd /opt
tar -zcf zsh-5.9-ohos-arm64.tar.gz zsh-5.9-ohos-arm64
