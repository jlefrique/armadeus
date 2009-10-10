#############################################################
#
# GSPCA Linux kernel webcams Driver.
#
#############################################################

GSPCA_VERSION=20071224
GSPCA_SOURCE:=gspcav1-$(GSPCA_VERSION).tar.gz
GSPCA_SITE:=http://mxhaard.free.fr/spca50x/Download/
GSPCA_BUILD_DIR=$(BUILD_DIR)/gspcav1-$(GSPCA_VERSION)
GSPCA_PKG_DIR=$(BASE_DIR)/package/gspca
GSPCA_CAT:=$(ZCAT)
GSPCA_MODULE=$(GSPCA_BUILD_DIR)/gspca.ko
GSPCA_TARGET_MODULE=$(TARGET_DIR)/lib/modules/2.6.29.6/extra/gspca.ko

GSPCA_CFLAGS := "-DGSPCA_ENABLE_COMPRESSION"
GSPCA_CFLAGS += "-DCONFIG_USB_GSPCA_MODULE=1"
GSPCA_CFLAGS += "-DVID_HARDWARE_GSPCA=0xFF"
GSPCA_CFLAGS += -DGSPCA_VERSION=\\\"01.00.20\\\"

$(DL_DIR)/$(GSPCA_SOURCE):
	$(WGET) -P $(DL_DIR) $(GSPCA_SITE)/$(GSPCA_SOURCE)

gspca-source: $(DL_DIR)/$(GSPCA_SOURCE)

$(GSPCA_BUILD_DIR)/.unpacked: $(DL_DIR)/$(GSPCA_SOURCE)
	$(GSPCA_CAT) $(DL_DIR)/$(GSPCA_SOURCE) | \
		tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $(GSPCA_BUILD_DIR)/.unpacked

$(GSPCA_MODULE): $(GSPCA_BUILD_DIR)/.unpacked
	$(MAKE) -C "$(LINUX_DIR)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(ARCH) \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) $(GSPCA_CFLAGS)" \
		SUBDIRS="$(GSPCA_BUILD_DIR)" \
		modules
	touch $@

$(GSPCA_TARGET_MODULE): $(GSPCA_MODULE)
	$(MAKE) -C "$(LINUX_DIR)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(ARCH) \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		SUBDIRS="$(GSPCA_BUILD_DIR)" \
		INSTALL_MOD_PATH="$(TARGET_DIR)" \
		modules_install

gspca: uclibc $(GSPCA_TARGET_MODULE)

gspca-clean:
	-$(MAKE) -C $(GSPCA_BUILD_DIR) clean

gspca-dirclean:
	rm -rf $(GSPCA_BUILD_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_GSPCA)),y)
TARGETS+=gspca
endif

