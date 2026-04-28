#!/bin/bash
#

# Modify default IP
# sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# 修改默认主题为 argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 先禁用 MBIM / QMI / ModemManager 用户态拨号相关包，避免 glib2 拆包依赖错误
for p in \
  libmbim \
  mbim-utils \
  libqmi \
  qmi-utils \
  libqrtr-glib \
  modemmanager \
  modemmanager-rpcd \
  luci-proto-mbim \
  luci-proto-qmi \
  luci-proto-modemmanager \
  luci-app-modemmanager
do
  sed -i "/^CONFIG_PACKAGE_${p}=/d" .config
  sed -i "/^# CONFIG_PACKAGE_${p} is not set/d" .config
  echo "# CONFIG_PACKAGE_${p} is not set" >> .config
done

echo "===== Disabled modem userspace packages ====="
grep -E "CONFIG_PACKAGE_(libmbim|mbim-utils|libqmi|qmi-utils|libqrtr-glib|modemmanager|luci-proto-mbim|luci-proto-qmi|luci-proto-modemmanager|luci-app-modemmanager)" .config || true