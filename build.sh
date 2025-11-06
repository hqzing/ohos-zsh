#!/bin/sh
set -e

# 准备 ohos-sdk
# OpenHarmony 发布页（https://gitcode.com/openharmony/docs/blob/master/zh-cn/release-notes/OpenHarmony-v6.0-release.md）里面的 6.0 release 版本 ohos-sdk 并未包含代码签名工具
# 为了使用代码签名工具，这里只能从 OpenHarmony 官方社区的每日构建流水线（https://ci.openharmony.cn/workbench/cicd/dailybuild/dailylist）下载主干版本的 ohos-sdk
sdk_download_url="https://cidownload.openharmony.cn/version/Daily_Version/OpenHarmony_6.0.0.56/20251027_150702/version-Daily_Version-OpenHarmony_6.0.0.56-20251027_150702-ohos-sdk-public.tar.gz"
curl $sdk_download_url -o ohos-sdk-public.tar.gz
mkdir -p /opt/ohos-sdk
tar -zxf ohos-sdk-public.tar.gz -C /opt/ohos-sdk
cd /opt/ohos-sdk/linux
unzip -q native-*.zip
unzip -q toolchains-*.zip
cd - >/dev/null

# 设置交叉编译所需的环境变量
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
export CFLAGS="-D__MUSL__=1"
export CXXFLAGS="-D__MUSL__=1"

# 编译 ncurses
curl -L -O https://mirrors.ustc.edu.cn/gnu/ncurses/ncurses-6.5.tar.gz
tar -zxf ncurses-6.5.tar.gz
cd ncurses-6.5
./configure \
    --host=aarch64-linux \
    --prefix=/opt/ncurses-6.5-ohos-arm64 \
    --without-shared \
    --without-debug \
    --with-strip-program=$STRIP \
    --enable-termcap \
    --with-fallbacks=xterm,xterm-256color,xterm-color,screen,screen-256color,tmux,tmux-256color,linux,vt100,vt102,ansi
make -j$(nproc) hashsize=1024
make install
cd ..

# 编译 zsh
curl -L -O https://sourceforge.net/projects/zsh/files/zsh/5.9/zsh-5.9.tar.xz
tar -xf zsh-5.9.tar.xz
cd zsh-5.9
./configure \
    --host=aarch64-linux-musl \
    --prefix=/opt/zsh-5.9-ohos-arm64 \
    --disable-dynamic \
    --with-ncurses=/opt/ncurses-6.5-ohos-arm64 \
    CPPFLAGS="-I/opt/ncurses-6.5-ohos-arm64/include" \
    LDFLAGS="-L/opt/ncurses-6.5-ohos-arm64/lib"
make -j$(nproc)
make install
cd ..

# 履行开源义务，把使用的开源软件的 license 全部聚合起来放到制品中
zsh_license=$(cat zsh-5.9/LICENCE; echo)
ncurses_license=$(cat ncurses-6.5/COPYING; echo)
ncurses_authors=$(cat ncurses-6.5/AUTHORS; echo)
printf '%s' "$(cat <<EOF
This document describes the licenses of all software distributed with the
bundled application.
==========================================================================

zsh
=============
$zsh_license

ncurses
=============
==license==
$ncurses_license
==authors==
$ncurses_authors
EOF
)" > /opt/zsh-5.9-ohos-arm64/licenses.txt

# 代码签名。做这一步是为了现在或以后能让它运行在 OpenHarmony 的商业发行版——HarmonyOS 上。
/opt/ohos-sdk/linux/toolchains/lib/binary-sign-tool sign -inFile /opt/zsh-5.9-ohos-arm64/bin/zsh -outFile /opt/zsh-5.9-ohos-arm64/bin/zsh -selfSign 1

# 打包最终产物
cd /opt
tar -zcf zsh-5.9-ohos-arm64.tar.gz zsh-5.9-ohos-arm64
