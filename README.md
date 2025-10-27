# ohos-zsh
本项目为 OpenHarmony 平台编译了 zsh，并发布预构建包。

这个 zsh 静态链接了 libc 以外的库，并集成了 terminfo 数据库，因此单独一个 zsh 二进制可执行文件就能运行。

## 获取预构建包
前往 [release 页面](https://github.com/Harmonybrew/ohos-zsh/releases) 获取。

## 从源码构建
需要用一台 Linux x64 服务器来运行项目里的 build.sh，以实现 zsh 的交叉编译。

这里以 Ubuntu 24.04 x64 作为示例：
```sh
sudo apt update && sudo apt install -y build-essential unzip jq
./build.sh
```

## 注意事项
如果这个 zsh 在你的设备上不能正常运行，可以尝试先设置 TERM 这个环境变量，再启动它。

```sh
export TERM=xterm
./zsh-5.9-ohos-arm64/bin/zsh
```
