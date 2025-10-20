# ohos-zsh
This project will build Zsh for the OpenHarmony platform and release prebuilt packages.

This is a statically-linked Zsh. No runtime dependencies, no need to install terminfo—just copy the binary and use it.

## Get prebuilt packages
Go to the [release page](https://github.com/Harmonybrew/ohos-zsh/releases).

## Build from source
Run the build.sh script on a Linux x64 server to cross-compile Zsh for OpenHarmony (e.g., on Ubuntu 24.04 x64).
```sh
sudo apt update && sudo apt install -y build-essential unzip jq
./build.sh
```

## Notice
If this Zsh does not work properly on your device, try setting the TERM environment variable before starting it.

```sh
export TERM=xterm
./zsh-5.9-ohos-arm64/bin/zsh
```
