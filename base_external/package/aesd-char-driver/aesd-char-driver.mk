##############################################################
#
# AESD Character Driver
#
##############################################################
AESD_CHAR_DRIVER_VERSION = 05146560e4515956597d9714e4658f756bb6a95d
AESD_CHAR_DRIVER_SITE = git@github.com:cu-ecen-aeld/assignments-3-and-later-CiprianTiro.git
AESD_CHAR_DRIVER_SITE_METHOD = git
AESD_CHAR_DRIVER_MODULE_SUBDIRS = aesd-char-driver

define AESD_CHAR_DRIVER_INSTALL_TARGET_CMDS
	# Create usr/bin directory if it doesn't exist
	$(INSTALL) -d 0755 $(TARGET_DIR)/usr/bin

	# Install aesdchar_load, aesdchar_unload to usr/bin
	$(INSTALL) -m 0755 $(@D)/aesd-char-driver/aesdchar_load $(TARGET_DIR)/usr/bin/aesdchar_load
	$(INSTALL) -m 0755 $(@D)/aesd-char-driver/aesdchar_unload $(TARGET_DIR)/usr/bin/aesdchar_unload

	# Install the driver binary (.ko) right next to them so the script finds it
	$(INSTALL) -m 0644 $(@D)/aesd-char-driver/aesdchar.ko $(TARGET_DIR)/usr/bin/aesdchar.ko
endef

$(eval $(kernel-module))
$(eval $(generic-package))