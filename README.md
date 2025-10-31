# ohos-zsh
本项目为 OpenHarmony 平台编译了 zsh，并发布预构建包。

## 获取软件包
前往 [release 页面](https://github.com/Harmonybrew/ohos-zsh/releases) 获取。

## 基础用法
**1\. 在鸿蒙 PC 中使用**

鸿蒙 PC 上已经内置了 zsh，“终端”（HiShell）里面默认的 shell 就是 zsh，一般情况下我们不需要再自己另带一个进去用。

当然，如果你一定要带进去用的话，那也是可以的，只是操作比较复杂。

由于当前鸿蒙 PC 还不支持 在 HiShell 里面运行二进制，所以我们不能以“解压 + 配 PATH” 方式使用。你需要把它做成 hnp 包，然后才能在 HiShell 中调用。详情请参考 [Termony
](https://github.com/TermonyHQ/Termony) 的方案。

**2\. 在鸿蒙开发板中使用**

开发板默认都是 root 环境，因此只需要用 hdc 把它推到设备上，然后以“解压 + 配 PATH” 方式使用。

示例：
```sh
hdc file send zsh-5.9-ohos-arm64.tar.gz /data
hdc shell

cd /data
tar -zxf zsh-5.9-ohos-arm64.tar.gz
export PATH=/data/zsh-5.9-ohos-arm64/bin

# 现在你可以使用 zsh 命令了
```

**3\. 在 [鸿蒙容器](https://github.com/hqzing/docker-mini-openharmony) 中使用**

容器环境内置了 curl，所以我们可以直接在容器中下载这个软件包，然后以“解压 + 配 PATH” 方式使用。

示例：
```sh
docker run -itd --name=ohos ghcr.io/hqzing/docker-mini-openharmony:latest
docker exec -it ohos sh

cd ~
curl -L -O https://github.com/Harmonybrew/ohos-zsh/releases/download/5.9/zsh-5.9-ohos-arm64.tar.gz
tar -zxf zsh-5.9-ohos-arm64.tar.gz -C /opt
export PATH=/opt/zsh-5.9-ohos-arm64/bin

# 现在你可以使用 zsh 命令了
```

## 进阶用法
**1\. 单文件使用**

这个 zsh 静态链接了 libc 以外的库，并集成了 terminfo 数据库，因此单独一个 zsh 二进制可执行文件就能运行。

你可以只拷贝这个可执行文件到任意目录去使用，只要这个目录在 PATH 中即可，不需要整包拷贝。

**2\. 使用自定义的 TERM**

如果这个 zsh 在你的设备上不能正常运行（如键盘按键异常等），可以尝试先设置 TERM 这个环境变量，再启动它。

```sh
export TERM=xterm
zsh
```

这个 zsh 内置了一些常用的 terminfo：xterm,xterm-256color,xterm-color,screen,screen-256color,tmux,tmux-256color,linux,vt100,vt102,ansi

建议结合你自己所使用的终端环境情况，优先从这个列表里面选一个适合你的值作为你的 TERM 环境变量值。

如果这里的值也不能满足（极小概率，只有一些非常深度的使用场景可能遇到），你需要自己弄一套 terminfo 数据库到设备上，把 TERMINFO 环境变量值设置成你自己的 terminfo 数据库目录，再设一个自己想要的 TERM 环境变量值。

## 从源码构建
需要用一台 Linux x64 服务器来运行项目里的 build.sh，以实现 zsh 的交叉编译。

这里以 Ubuntu 24.04 x64 作为示例：
```sh
sudo apt update && sudo apt install -y build-essential unzip
./build.sh
```
