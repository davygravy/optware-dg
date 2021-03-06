###########################################################
#
# gnokii
#
###########################################################
#
# $Id: gnokii.mk 12104 2010-11-28 23:06:30Z reedy $
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
GNOKII_SITE=http://www.gnokii.org/download/gnokii
GNOKII_VERSION=0.6.28.1
GNOKII_SOURCE=gnokii-$(GNOKII_VERSION).tar.bz2
GNOKII_DIR=gnokii-0.6.28
GNOKII_UNZIP=bzcat
GNOKII_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
GNOKII_DESCRIPTION=a multisystem tool suite and modem driver for the mobile phones
GNOKII_SECTION=misc
GNOKII_PRIORITY=optional
GNOKII_DEPENDS=libusb, bluez-libs, readline, ncurses
GNOKII_SUGGESTS=
GNOKII_CONFLICTS=

GNOKII_SMSD_DESCRIPTION=A gnokii sms daemon
GNOKII_SMSD_SECTION=daemon
GNOKII_SMSD_DEPENDS=gnokii, glib
GNOKII_SMSD_SUGGESTS=
GNOKII_SMSD_CONFLICTS=

GNOKII_SMSD_MYSQL_DESCRIPTION=A gnokii sms daemon
GNOKII_SMSD_MYSQL_DEPENDS=gnokii-smsd, mysql
GNOKII_SMSD_MYSQL_SUGGESTS=
GNOKII_SMSD_MYSQL_CONFLICTS=
#
# GNOKII_IPK_VERSION should be incremented when the ipk changes.
#
GNOKII_IPK_VERSION=1

#
# GNOKII_CONFFILES should be a list of user-editable files
# GNOKII_CONFFILES=/opt/etc/gnokii.conf /opt/etc/init.d/SXXgnokii
# GNOKII_SMSD_CONFFILES=/opt/etc/gnokii.conf /opt/etc/init.d/SXXgnokii

#
# GNOKII_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# GNOKII_PATCHES=$(GNOKII_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GNOKII_CPPFLAGS=
GNOKII_LDFLAGS=

#
# GNOKII_BUILD_DIR is the directory in which the build is done.
# GNOKII_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GNOKII_IPK_DIR is the directory in which the ipk is built.
# GNOKII_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GNOKII_BUILD_DIR=$(BUILD_DIR)/gnokii
GNOKII_SOURCE_DIR=$(SOURCE_DIR)/gnokii
GNOKII_IPK_DIR=$(BUILD_DIR)/gnokii-$(GNOKII_VERSION)-ipk
GNOKII_IPK=$(BUILD_DIR)/gnokii_$(GNOKII_VERSION)-$(GNOKII_IPK_VERSION)_$(TARGET_ARCH).ipk

GNOKII_SMSD_IPK_DIR=$(BUILD_DIR)/gnokii-smsd-$(GNOKII_VERSION)-ipk
GNOKII_SMSD_IPK=$(BUILD_DIR)/gnokii-smsd_$(GNOKII_VERSION)-$(GNOKII_IPK_VERSION)_$(TARGET_ARCH).ipk

GNOKII_SMSD_MYSQL_IPK_DIR=$(BUILD_DIR)/gnokii-smsd-mysql-$(GNOKII_VERSION)-ipk
ifeq (, $(filter dns323, $(OPTWARE_TARGET)))
GNOKII_SMSD_MYSQL_IPK=$(BUILD_DIR)/gnokii-smsd-mysql_$(GNOKII_VERSION)-$(GNOKII_IPK_VERSION)_$(TARGET_ARCH).ipk
endif

ifeq (dns323, $(filter dns323, $(OPTWARE_TARGET)))
GNOKII_MYSQL_CONFIG=no
else
GNOKII_MYSQL_CONFIG=$(STAGING_PREFIX)/bin/mysql_config
endif

.PHONY: gnokii-source gnokii-unpack gnokii gnokii-stage gnokii-ipk gnokii-clean gnokii-dirclean gnokii-check gnokii-smsd-ipk gnokii-smsd-mysql-ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GNOKII_SOURCE):
	$(WGET) -P $(@D) $(GNOKII_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gnokii-source: $(DL_DIR)/$(GNOKII_SOURCE) $(GNOKII_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(GNOKII_BUILD_DIR)/.configured: $(DL_DIR)/$(GNOKII_SOURCE) $(GNOKII_PATCHES) make/gnokii.mk
	$(MAKE) libusb-stage bluez-libs-stage
	$(MAKE) glib-stage mysql-stage ncurses-stage readline-stage
	rm -rf $(BUILD_DIR)/$(GNOKII_DIR) $(@D)
	$(GNOKII_UNZIP) $(DL_DIR)/$(GNOKII_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GNOKII_PATCHES)" ; \
		then cat $(GNOKII_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GNOKII_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GNOKII_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GNOKII_DIR) $(@D) ; \
	fi
#	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GNOKII_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GNOKII_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_path_MYSQLCONFIG=$(GNOKII_MYSQL_CONFIG) \
		ac_cv_path_PGCONFIG=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--mandir=/opt/man \
		--without-x \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gnokii-unpack: $(GNOKII_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GNOKII_BUILD_DIR)/.built: $(GNOKII_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This builds the smsd
#
$(GNOKII_BUILD_DIR)/.smsd-built: $(GNOKII_BUILD_DIR)/.configured
	make gnokii-stage
	rm -f $@
	sed -i -e '/smsdConfig.dbMod/s/pq/file/' $(@D)/smsd/smsd.c
	$(MAKE) -C $(@D)/smsd
	touch $@

#
# This is the build convenience target.
#
gnokii: $(GNOKII_BUILD_DIR)/.built

gnokii-smsd: $(GNOKII_BUILD_DIR)/.smsd-built

#
# If you are building a library, then you need to stage it too.
#
$(GNOKII_BUILD_DIR)/.staged: $(GNOKII_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gnokii-stage: $(GNOKII_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gnokii
#
$(GNOKII_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnokii" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNOKII_PRIORITY)" >>$@
	@echo "Section: $(GNOKII_SECTION)" >>$@
	@echo "Version: $(GNOKII_VERSION)-$(GNOKII_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNOKII_MAINTAINER)" >>$@
	@echo "Source: $(GNOKII_SITE)/$(GNOKII_SOURCE)" >>$@
	@echo "Description: $(GNOKII_DESCRIPTION)" >>$@
	@echo "Depends: $(GNOKII_DEPENDS)" >>$@
	@echo "Suggests: $(GNOKII_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNOKII_CONFLICTS)" >>$@

$(GNOKII_SMSD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnokii-smsd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNOKII_PRIORITY)" >>$@
	@echo "Section: $(GNOKII_SMSD_SECTION)" >>$@
	@echo "Version: $(GNOKII_VERSION)-$(GNOKII_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNOKII_MAINTAINER)" >>$@
	@echo "Source: $(GNOKII_SITE)/$(GNOKII_SOURCE)" >>$@
	@echo "Description: $(GNOKII_SMSD_DESCRIPTION)" >>$@
	@echo "Depends: $(GNOKII_SMSD_DEPENDS)" >>$@
	@echo "Suggests: $(GNOKII_SMSD_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNOKII_SMSD_CONFLICTS)" >>$@

$(GNOKII_SMSD_MYSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnokii-smsd-mysql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNOKII_PRIORITY)" >>$@
	@echo "Section: $(GNOKII_SMSD_SECTION)" >>$@
	@echo "Version: $(GNOKII_VERSION)-$(GNOKII_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNOKII_MAINTAINER)" >>$@
	@echo "Source: $(GNOKII_SITE)/$(GNOKII_SOURCE)" >>$@
	@echo "Description: $(GNOKII_SMSD_MYSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(GNOKII_SMSD_MYSQL_DEPENDS)" >>$@
	@echo "Suggests: $(GNOKII_SMSD_MYSQL_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNOKII_SMSD_MYSQL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GNOKII_IPK_DIR)/opt/sbin or $(GNOKII_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GNOKII_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GNOKII_IPK_DIR)/opt/etc/gnokii/...
# Documentation files should be installed in $(GNOKII_IPK_DIR)/opt/doc/gnokii/...
# Daemon startup scripts should be installed in $(GNOKII_IPK_DIR)/opt/etc/init.d/S??gnokii
#
# You may need to patch your application to make it use these locations.
#
$(GNOKII_IPK): $(GNOKII_BUILD_DIR)/.built
	rm -rf $(GNOKII_IPK_DIR) $(BUILD_DIR)/gnokii_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNOKII_BUILD_DIR) install-strip \
		DESTDIR=$(GNOKII_IPK_DIR) am__append_3='' transform=''
#
# Remove documentation and development files
#
	rm $(GNOKII_IPK_DIR)/opt/lib/pkgconfig/*
	rmdir $(GNOKII_IPK_DIR)/opt/lib/pkgconfig
	rm -rf $(GNOKII_IPK_DIR)/opt/share/doc/gnokii 
	rmdir $(GNOKII_IPK_DIR)/opt/share/doc
	rm -rf $(GNOKII_IPK_DIR)/opt/include/gnokii*
	rmdir  $(GNOKII_IPK_DIR)/opt/include
	install -d $(GNOKII_IPK_DIR)/opt/etc/
#	install -m 644 $(GNOKII_SOURCE_DIR)/gnokii.conf $(GNOKII_IPK_DIR)/opt/etc/gnokii.conf
#	install -d $(GNOKII_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GNOKII_SOURCE_DIR)/rc.gnokii $(GNOKII_IPK_DIR)/opt/etc/init.d/SXXgnokii
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXgnokii
	$(MAKE) $(GNOKII_IPK_DIR)/CONTROL/control
#	install -m 755 $(GNOKII_SOURCE_DIR)/postinst $(GNOKII_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GNOKII_SOURCE_DIR)/prerm $(GNOKII_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(GNOKII_CONFFILES) | sed -e 's/ /\n/g' > $(GNOKII_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNOKII_IPK_DIR)

$(GNOKII_SMSD_IPK): $(GNOKII_BUILD_DIR)/.smsd-built
	rm -rf $(GNOKII_SMSD_IPK_DIR) $(BUILD_DIR)/gnokii-smsd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNOKII_BUILD_DIR)/smsd DESTDIR=$(GNOKII_SMSD_IPK_DIR) install-strip transform=''
	rm -f $(GNOKII_SMSD_IPK_DIR)/opt/lib/smsd/libsmsd_file.la
	rm -f $(GNOKII_SMSD_IPK_DIR)/opt/lib/smsd/libsmsd_mysql.*
	$(MAKE) $(GNOKII_SMSD_IPK_DIR)/CONTROL/control
#	install -m 755 $(GNOKII_SOURCE_DIR)/postinst $(GNOKII_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GNOKII_SOURCE_DIR)/prerm $(GNOKII_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(GNOKII_SMSD_CONFFILES) | sed -e 's/ /\n/g' > $(GNOKII_SMSD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNOKII_SMSD_IPK_DIR)

$(GNOKII_SMSD_MYSQL_IPK): $(GNOKII_BUILD_DIR)/.smsd-built
	rm -rf $(GNOKII_SMSD_MYSQL_IPK_DIR) $(BUILD_DIR)/gnokii-smsd-mysql_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNOKII_BUILD_DIR)/smsd DESTDIR=$(GNOKII_SMSD_MYSQL_IPK_DIR) install-strip transform=''
	rm -rf $(GNOKII_SMSD_MYSQL_IPK_DIR)/opt/*bin
	rm -rf $(GNOKII_SMSD_MYSQL_IPK_DIR)/opt/man
	rm $(GNOKII_SMSD_MYSQL_IPK_DIR)/opt/lib/smsd/libsmsd_file.*
	rm $(GNOKII_SMSD_MYSQL_IPK_DIR)/opt/lib/smsd/libsmsd_mysql.la
	mkdir -p $(GNOKII_SMSD_MYSQL_IPK_DIR)/opt/share/doc/gnokii-smsd
	cp $(GNOKII_BUILD_DIR)/smsd/sms.tables.mysql.sql $(GNOKII_SMSD_MYSQL_IPK_DIR)/opt/share/doc/gnokii-smsd
	$(MAKE) $(GNOKII_SMSD_MYSQL_IPK_DIR)/CONTROL/control
#	install -m 755 $(GNOKII_SOURCE_DIR)/postinst $(GNOKII_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GNOKII_SOURCE_DIR)/prerm $(GNOKII_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(GNOKII_SMSD_MYSQL_CONFFILES) | sed -e 's/ /\n/g' > $(GNOKII_SMSD_MYSQL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNOKII_SMSD_MYSQL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gnokii-ipk: $(GNOKII_IPK) $(GNOKII_SMSD_IPK) $(GNOKII_SMSD_MYSQL_IPK)
gnokii-smsd-ipk: $(GNOKII_SMSD_IPK)
gnokii-smsd-mysql-ipk: $(GNOKII_SMSD_MYSQL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gnokii-clean:
	rm -f $(GNOKII_BUILD_DIR)/.built
	-$(MAKE) -C $(GNOKII_BUILD_DIR) clean
	-$(MAKE) -C $(GNOKII_BUILD_DIR)/smsd clean
#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gnokii-dirclean:
	rm -rf $(BUILD_DIR)/$(GNOKII_DIR) $(GNOKII_BUILD_DIR)
	rm -rf $(GNOKII_IPK_DIR) $(GNOKII_IPK)
	rm -rf $(GNOKII_SMSD_IPK_DIR) $(GNOKII_SMSD_IPK)
	rm -rf $(GNOKII_SMSD_MYSQL_IPK_DIR) $(GNOKII_SMSD_MYSQL_IPK)
#
#
# Some sanity check for the package.
#
gnokii-check: $(GNOKII_IPK) $(GNOKII_SMSD_IPK) $(GNOKII_SMSD_MYSQL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
