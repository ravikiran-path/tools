#############################################################
#
# acpid
#
#############################################################
ACPID_DIR=$(BUILD_DIR)/acpid-1.0.4
ACPID_SOURCE=acpid_1.0.4-1.tar.gz
ACPID_SITE=http://ftp.debian.org/debian/pool/main/a/acpid

$(DL_DIR)/$(ACPID_SOURCE):
	$(WGET) -P $(DL_DIR) $(ACPID_SITE)/$(ACPID_SOURCE)

$(ACPID_DIR)/Makefile: $(DL_DIR)/$(ACPID_SOURCE)
	zcat $(DL_DIR)/$(ACPID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	$(SED) "s:ACPI_SOCKETFILE.*:ACPI_SOCKETFILE \"/tmp/acpid.socket\":" $(ACPID_DIR)/acpid.h
	touch -c $(ACPID_DIR)/Makefile

$(ACPID_DIR)/acpid: $(ACPID_DIR)/Makefile
	$(MAKE) CC=$(TARGET_CC) -C $(ACPID_DIR)
	$(STRIP) -s $(ACPID_DIR)/acpid
	$(STRIP) -s $(ACPID_DIR)/acpi_listen
	touch -c $(ACPID_DIR)/acpid $(ACPID_DIR)/acpi_listen

$(TARGET_DIR)/usr/sbin/acpid: $(ACPID_DIR)/acpid
	cp -a $(ACPID_DIR)/acpid $(TARGET_DIR)/usr/sbin/acpid
	mkdir -p $(TARGET_DIR)/etc/acpi/events
	echo -e "event=button[ /]power\naction=/sbin/poweroff" > $(TARGET_DIR)/etc/acpi/events/powerbtn
	touch -c $(TARGET_DIR)/usr/sbin/acpid

acpid: $(TARGET_DIR)/usr/sbin/acpid

acpid-source: $(DL_DIR)/$(ACPID_SOURCE)

acpid-clean:
	-make -C $(ACPID_DIR) clean

acpid-dirclean:
	rm -rf $(ACPID_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_ACPID)),y)
TARGETS+=acpid
endif
