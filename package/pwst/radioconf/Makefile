include $(TOPDIR)/rules.mk

PKG_NAME:=pwst-radioconf
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/pwst-radioconf
  SECTION:=opt
  CATEGORY:=Extra packages
  TITLE:=PWST Radio Conf
  DEPENDS:=morsecli
endef

define Package/pwst-radioconf/description
  Script that run on boot to check and configure MM610X-H06 for EU.
  Includes hotplug script to reapply settings when radio config changes.
endef

define Build/Compile
	# Nothing to compile for shell scripts
endef

define Package/pwst-radioconf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/healthchek-n-conf.sh $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/radioconf $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_BIN) ./files/etc/hotplug.d/net/99-pwst-radio-conf $(1)/etc/hotplug.d/net/99-pwst-radio-conf
endef

define Package/pwst-radioconf/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	# Create log directory and file
	mkdir -p /var/log
	touch /var/log/radioconf.log
	chmod 644 /var/log/radioconf.log

	# Enable and start service
	/etc/init.d/radioconf enable
	/etc/init.d/radioconf start
}
endef

define Package/pwst-radioconf/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	if [ -x /etc/init.d/radioconf ]; then
		/etc/init.d/radioconf stop 2>/dev/null || true
		/etc/init.d/radioconf disable 2>/dev/null || true
	fi
}
endef

$(eval $(call BuildPackage,pwst-radioconf))