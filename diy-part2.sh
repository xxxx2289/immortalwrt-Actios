#!/bin/bash
set -e

# Modify default theme
sed -i 's/luci-theme-material/luci-theme-argon/g' feeds/luci/collections/luci/Makefile 2>/dev/null || true
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile 2>/dev/null || true

# Fix glib2 split dependency issue
# libmbim / libqrtr-glib / libqmi / modemmanager may be re-selected by make defconfig,
# so patch their Makefiles instead of only disabling them.
for f in \
  feeds/packages/libs/libmbim/Makefile \
  feeds/packages/libs/libqrtr-glib/Makefile \
  feeds/packages/libs/libqmi/Makefile \
  feeds/packages/net/modemmanager/Makefile
do
  if [ -f "$f" ]; then
    sed -i -E 's/\+glib2([[:space:]\\]|$)/+glib2-core +glib2-gobject +glib2-gio\1/g' "$f"
  fi
done

# Fix possible glib2 meta package typo
if [ -f feeds/packages/libs/glib2/Makefile ]; then
  sed -i 's/DEPENDS:+glib2-gthread/DEPENDS:=+glib2-gthread/g' feeds/packages/libs/glib2/Makefile
fi

# Force required split glib2 packages
for p in glib2-core glib2-gmodule glib2-gobject glib2-gio glib2-gthread; do
  sed -i "/^CONFIG_PACKAGE_${p}=/d" .config
  sed -i "/^# CONFIG_PACKAGE_${p} is not set/d" .config
  echo "CONFIG_PACKAGE_${p}=y" >> .config
done

# Still try to disable modem userspace packages, but Makefile patch above is the key
for p in \
  libmbim \
  mbim-utils \
  libqmi \
  qmi-utils \
  libqrtr-glib \
  libqrtr \
  modemmanager \
  modemmanager-rpcd \
  luci-proto-mbim \
  luci-proto-qmi \
  luci-proto-modemmanager \
  luci-app-modemmanager \
  qmi-modem-410-init \
  qrtr-ns
do
  sed -i "/^CONFIG_PACKAGE_${p}=/d" .config
  sed -i "/^# CONFIG_PACKAGE_${p} is not set/d" .config
  echo "# CONFIG_PACKAGE_${p} is not set" >> .config
done

echo "===== GLib dependency patch check ====="
grep -n "DEPENDS" feeds/packages/libs/libmbim/Makefile || true
grep -n "DEPENDS" feeds/packages/libs/libqrtr-glib/Makefile || true
grep -n "DEPENDS" feeds/packages/libs/libqmi/Makefile || true
grep -n "DEPENDS" feeds/packages/net/modemmanager/Makefile || true

echo "===== Disabled modem userspace packages ====="
grep -E "CONFIG_PACKAGE_(libmbim|mbim-utils|libqmi|qmi-utils|libqrtr-glib|libqrtr|modemmanager|modemmanager-rpcd|luci-proto-mbim|luci-proto-qmi|luci-proto-modemmanager|luci-app-modemmanager|qmi-modem-410-init|qrtr-ns)" .config || true