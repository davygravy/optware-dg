###########################################################
#
# shairport
#
###########################################################

#
# SHAIRPORT_VERSION, SHAIRPORT_SITE and SHAIRPORT_SOURCE define
# the upstream location of the source code for the package.
# SHAIRPORT_DIR is the directory which is created when the source
# archive is unpacked.
# SHAIRPORT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
SHAIRPORT_SITE=https://github.com/albertz/shairport/tarball/master
SHAIRPORT_VERSION=0.05
SHAIRPORT_SOURCE=albertz-shairport.tar.gz
SHAIRPORT_DIR=shairport-$(SHAIRPORT_VERSION)
SHAIRPORT_UNZIP=zcat
SHAIRPORT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SHAIRPORT_DESCRIPTION=AirPlay server.
SHAIRPORT_SECTION=misc
SHAIRPORT_PRIORITY=optional
SHAIRPORT_DEPENDS=libao,openssl
SHAIRPORT_SUGGESTS=
SHAIRPORT_CONFLICTS=

#
# SHAIRPORT_IPK_VERSION should be incremented when the ipk changes.
#
SHAIRPORT_IPK_VERSION=1

#
# SHAIRPORT_CONFFILES should be a list of user-editable files
#SHAIRPORT_CONFFILES=/opt/etc/shairport.conf /opt/etc/init.d/SXXshairport

#
# SHAIRPORT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SHAIRPORT_PATCHES=$(SHAIRPORT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SHAIRPORT_CPPFLAGS=
SHAIRPORT_LDFLAGS=

#
# SHAIRPORT_BUILD_DIR is the directory in which the build is done.
# SHAIRPORT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SHAIRPORT_IPK_DIR is the directory in which the ipk is built.
# SHAIRPORT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SHAIRPORT_BUILD_DIR=$(BUILD_DIR)/shairport
SHAIRPORT_SOURCE_DIR=$(SOURCE_DIR)/shairport
SHAIRPORT_IPK_DIR=$(BUILD_DIR)/shairport-$(SHAIRPORT_VERSION)-ipk
SHAIRPORT_IPK=$(BUILD_DIR)/shairport_$(SHAIRPORT_VERSION)-$(SHAIRPORT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: shairport-source shairport-unpack shairport shairport-stage shairport-ipk shairport-clean shairport-dirclean shairport-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SHAIRPORT_SOURCE):
	$(WGET) -P $(@D) $(SHAIRPORT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
shairport-source: $(DL_DIR)/$(SHAIRPORT_SOURCE) $(SHAIRPORT_PATCHES)

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
$(SHAIRPORT_BUILD_DIR)/.configured: $(DL_DIR)/$(SHAIRPORT_SOURCE) $(SHAIRPORT_PATCHES) make/shairport.mk
	rm -rf $(BUILD_DIR)/$(SHAIRPORT_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(SHAIRPORT_DIR)
	$(SHAIRPORT_UNZIP) $(DL_DIR)/$(SHAIRPORT_SOURCE)  | tar -C $(BUILD_DIR)/$(SHAIRPORT_DIR) --strip-components 1 -xvf -
	if test -n "$(SHAIRPORT_PATCHES)" ; \
		then cat $(SHAIRPORT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SHAIRPORT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SHAIRPORT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SHAIRPORT_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(SHAIRPORT_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(SHAIRPORT_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
#		--disable-static \
#	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

shairport-unpack: $(SHAIRPORT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
# TODO: Make this not suck?
#
$(SHAIRPORT_BUILD_DIR)/.built: $(SHAIRPORT_BUILD_DIR)/.configured libao-stage openssl-stage
	rm -f $@
	PKG_CONFIG_PATH=$(STAGING_DIR)/opt/lib/pkgconfig $(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) CPPFLAGS="$(STATING_CPPFLAGS) $(SHAIRPORT_CPPFLAGS)"
	touch $@

#
# This is the build convenience target.
#
shairport: $(SHAIRPORT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SHAIRPORT_BUILD_DIR)/.staged: $(SHAIRPORT_BUILD_DIR)/.built
	rm -f $@
	touch $@

shairport-stage: $(SHAIRPORT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/shairport
#
$(SHAIRPORT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: shairport" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SHAIRPORT_PRIORITY)" >>$@
	@echo "Section: $(SHAIRPORT_SECTION)" >>$@
	@echo "Version: $(SHAIRPORT_VERSION)-$(SHAIRPORT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SHAIRPORT_MAINTAINER)" >>$@
	@echo "Source: $(SHAIRPORT_SITE)/$(SHAIRPORT_SOURCE)" >>$@
	@echo "Description: $(SHAIRPORT_DESCRIPTION)" >>$@
	@echo "Depends: $(SHAIRPORT_DEPENDS)" >>$@
	@echo "Suggests: $(SHAIRPORT_SUGGESTS)" >>$@
	@echo "Conflicts: $(SHAIRPORT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SHAIRPORT_IPK_DIR)/opt/sbin or $(SHAIRPORT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SHAIRPORT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SHAIRPORT_IPK_DIR)/opt/etc/shairport/...
# Documentation files should be installed in $(SHAIRPORT_IPK_DIR)/opt/doc/shairport/...
# Daemon startup scripts should be installed in $(SHAIRPORT_IPK_DIR)/opt/etc/init.d/S??shairport
#
# You may need to patch your application to make it use these locations.
#
$(SHAIRPORT_IPK): $(SHAIRPORT_BUILD_DIR)/.built
	rm -rf $(SHAIRPORT_IPK_DIR) $(BUILD_DIR)/shairport_*_$(TARGET_ARCH).ipk
	install -D -m 0755 $(SHAIRPORT_BUILD_DIR)/shairport $(SHAIRPORT_IPK_DIR)/opt/bin/shairport
	$(MAKE) $(SHAIRPORT_IPK_DIR)/CONTROL/control
	echo $(SHAIRPORT_CONFFILES) | sed -e 's/ /\n/g' > $(SHAIRPORT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SHAIRPORT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SHAIRPORT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
shairport-ipk: $(SHAIRPORT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
shairport-clean:
	rm -f $(SHAIRPORT_BUILD_DIR)/.built
	-$(MAKE) -C $(SHAIRPORT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
shairport-dirclean:
	rm -rf $(BUILD_DIR)/$(SHAIRPORT_DIR) $(SHAIRPORT_BUILD_DIR) $(SHAIRPORT_IPK_DIR) $(SHAIRPORT_IPK)
#
#
# Some sanity check for the package.
#
shairport-check: $(SHAIRPORT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

