#!/bin/bash

# 需要 root 权限的部分
echo "正在初始化构建环境 (需要 root 权限)..."
sudo bash -c 'bash <(curl -s https://build-scripts.immortalwrt.org/init_build_environment.sh)' || {
    echo "初始化失败！请检查网络连接和权限";
    exit 1;
}

# 以下操作在普通用户权限下执行
echo "正在克隆代码仓库..."
git clone -b openwrt-24.10 --single-branch --filter=blob:none https://github.com/immortalwrt/immortalwrt || {
    echo "克隆仓库失败！";
    exit 1;
}

cd immortalwrt || {
    echo "进入项目目录失败！";
    exit 1;
}

# 永久添加自定义软件源
echo "正在写入自定义 feed 源..."
CUSTOM_FEEDS=$(cat <<-EOL
src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main
EOL
)

# 写入 feeds 配置文件
if [ ! -f feeds.conf ]; then
    # 如果不存在自定义配置则从默认文件创建
    cp feeds.conf.default feeds.conf
fi

echo "$CUSTOM_FEEDS" >> feeds.conf || {
    echo "写入 feed 源失败！请检查磁盘权限";
    exit 1;
}

echo "正在更新 feeds..."
./scripts/feeds update -a || {
    echo "Feeds 更新失败！";
    exit 1;
}

echo "正在安装 feeds..."
./scripts/feeds install -a || {
    echo "Feeds 安装失败！";
    exit 1;
}

echo "启动交互式配置界面..."
make menuconfig

# 检查是否生成了配置文件
if [ ! -f .config ]; then
    echo "错误：未检测到配置文件，请确保在 menuconfig 中保存配置！"
    exit 1
fi

echo "开始编译 (使用所有 CPU 核心)..."
make -j$(nproc) V=1 || {
    echo "编译失败！";
    exit 1;
}

echo "编译完成！固件位于 bin/targets/ 目录下"
