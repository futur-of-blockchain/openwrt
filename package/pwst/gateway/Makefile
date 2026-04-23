include $(TOPDIR)/rules.mk

PKG_NAME:=pwst-gateway
PKG_VERSION:=1.0
PKG_RELEASE:=1

GATEWAY_DIR:=blockchain-lora-wifi-gateway-20260112-094902
GATEWAY_INSTALL_PATH:=/usr/share/pwst/gateway/$(GATEWAY_DIR)

include $(INCLUDE_DIR)/package.mk

define Package/pwst-gateway
  SECTION:=opt
  CATEGORY:=Extra packages
  TITLE:=PWST Dockerized Gateway
  DEPENDS:=+make +docker +docker-compose \
           +kmod-usb-serial +kmod-usb-serial-cp210x \
           +kmod-usb-serial-ch341 +kmod-usb-acm \
           +kmod-usb-serial-ftdi +kmod-usb-serial-pl2303
endef

define Package/pwst-gateway/description
  Script that start the Dockerize Gateway.
  Includes hotplug script to reapply settings when USB Meshtastic devices are connected.
endef

define Package/pwst-gateway/conffiles
$(GATEWAY_INSTALL_PATH)/docker.env
endef

define Build/Compile
	# Nothing to compile, all is Dockerized
endef

define Package/pwst-gateway/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/install-subg-gateway.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./files/usr/bin/update-conf.sh $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/pwst-gateway $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_BIN) ./files/etc/hotplug.d/usb/20-meshtastic $(1)/etc/hotplug.d/usb/

	$(INSTALL_DIR) $(1)/usr/share/pwst/gateway
	$(INSTALL_DATA) ./files/usr/share/pwst/gateway/$(GATEWAY_DIR).tar.gz $(1)/usr/share/pwst/gateway/
endef

define Package/pwst-gateway/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	# Build Docker
	/usr/bin/install-subg-gateway.sh
	# Update configuration with current system settings
	/usr/bin/update-conf.sh || true
	# Create log directory and file
	mkdir -p /var/log
	touch /var/log/subghzgateway.log
	chmod 644 /var/log/subghzgateway.log

	# Enable and start service
	/etc/init.d/pwst-gateway enable
	/etc/init.d/pwst-gateway start
}
endef

define Package/pwst-gateway/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	if [ -x /etc/init.d/pwst-gateway ]; then
		/etc/init.d/pwst-gateway stop 2>/dev/null || true
		/etc/init.d/pwst-gateway disable 2>/dev/null || true
	fi
	# Tear down docker containers before files are removed
	cd /usr/share/pwst/gateway/$(GATEWAY_DIR) 2>/dev/null && /usr/bin/make down 2>/dev/null || true
}
endef

define Package/pwst-gateway/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	cd /usr/share/pwst/gateway/$(GATEWAY_DIR) 2>/dev/null && /usr/bin/make down || true
}
endef

$(eval $(call BuildPackage,pwst-gateway))