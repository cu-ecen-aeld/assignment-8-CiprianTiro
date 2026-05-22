##############################################################
#
# LDD
#
##############################################################
LDD_VERSION = 279724da1ad1bf57c8d544283899fce806ba61fe
LDD_SITE = git@github.com:cu-ecen-aeld/assignment-7-CiprianTiro.git
LDD_SITE_METHOD = git
LDD_MODULE_SUBDIRS = scull misc-modules

# Buildroot must be explicitly told to compile the kernel before trying to compile this package,
# or parallel make will cause a race condition and crash.
LDD_DEPENDENCIES = linux

define LDD_INSTALL_TARGET_CMDS
	# Create usr/bin directory if it doesn't exist
	$(INSTALL) -d 0755 $(TARGET_DIR)/usr/bin

	# Install scull_load, scull_unload, module_load, and module_unload to usr/bin
	$(INSTALL) -m 0755 $(@D)/scull/scull_load $(TARGET_DIR)/usr/bin/scull_load
	$(INSTALL) -m 0755 $(@D)/scull/scull_unload $(TARGET_DIR)/usr/bin/scull_unload
	$(INSTALL) -m 0755 $(@D)/misc-modules/module_load $(TARGET_DIR)/usr/bin/module_load
	$(INSTALL) -m 0755 $(@D)/misc-modules/module_unload $(TARGET_DIR)/usr/bin/module_unload
endef

$(eval $(kernel-module))
$(eval $(generic-package))