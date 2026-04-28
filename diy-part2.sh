#!/bin/bash
#

# Modify default IP
# sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Fix glib2 meta package dependency typo if present
if [ -f feeds/packages/libs/glib2/Makefile ]; then
  sed -i 's/^DEPENDS:+glib2-gthread/DEPENDS:=+glib2-gthread/' feeds/packages/libs/glib2/Makefile
fi

# Fix libmbim dependency for split glib2 packages
if [ -f feeds/packages/libs/libmbim/Makefile ]; then
  sed -i '/define Package\/libmbim/,/endef/s/^[[:space:]]*DEPENDS:=.*/DEPENDS:=+glib2-core +glib2-gobject +glib2-gio/' feeds/packages/libs/libmbim/Makefile
fi

# Make sure required packages are selected
for p in glib2-core glib2-gmodule glib2-gobject glib2-gio glib2-gthread libmbim; do
  sed -i "/^CONFIG_PACKAGE_${p}=/d" .config
  sed -i "/^# CONFIG_PACKAGE_${p} is not set/d" .config
  echo "CONFIG_PACKAGE_${p}=y" >> .config
done

# Show patched dependency for debugging
echo "===== libmbim dependency after patch ====="
grep -A8 -n "define Package/libmbim" feeds/packages/libs/libmbim/Makefile || true
echo "===== glib2 package config after patch ====="
grep -E "CONFIG_PACKAGE_(glib2|glib2-core|glib2-gobject|glib2-gio|glib2-gthread|libmbim)" .config || true