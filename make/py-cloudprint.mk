###########################################################
#
# py-CLOUDPRINT
#
###########################################################

#
# PY-CLOUDPRINT_VERSION, PY-CLOUDPRINT_SITE and PY-CLOUDPRINT_SOURCE define
# the upstream location of the source code for the package.
# PY-CLOUDPRINT_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CLOUDPRINT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
# http://github.com/armooo/cloudprint/archive/master.zip
PY-CLOUDPRINT_VERSION=0.9
PY-CLOUDPRINT_SITE=http://github.com/davygravy/cloudprint/archive
PY-CLOUDPRINT_SOURCE=master.zip
PY-CLOUDPRINT_DIR=cloudprint-master
PY-CLOUDPRINT_UNZIP=unzip
PY-CLOUDPRINT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CLOUDPRINT_DESCRIPTION=A set of Python bindings for the libCLOUDPRINT library from the CLOUDPRINT project.
PY-CLOUDPRINT_SECTION=misc
PY-CLOUDPRINT_PRIORITY=optional
PY-CLOUDPRINT_DEPENDS=python26
PY-CLOUDPRINT_CONFLICTS=

#
# PY-CLOUDPRINT_IPK_VERSION should be incremented when the ipk changes.
#
PY-CLOUDPRINT_IPK_VERSION=4

#
# PY-CLOUDPRINT_CONFFILES should be a list of user-editable files
PY-CLOUDPRINT_CONFFILES=/opt/etc/init.d/S90cloudprint-daemon

#
# PY-CLOUDPRINT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CLOUDPRINT_PATCHES=$(PY-CLOUDPRINT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CLOUDPRINT_CPPFLAGS=
PY-CLOUDPRINT_LDFLAGS=

#
# PY-CLOUDPRINT_BUILD_DIR is the directory in which the build is done.
# PY-CLOUDPRINT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CLOUDPRINT_IPK_DIR is the directory in which the ipk is built.
# PY-CLOUDPRINT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CLOUDPRINT_BUILD_DIR=$(BUILD_DIR)/py-cloudprint
PY-CLOUDPRINT_SOURCE_DIR=$(SOURCE_DIR)/py-cloudprint
PY-CLOUDPRINT_IPK_DIR=$(BUILD_DIR)/py26-cloudprint-$(PY-CLOUDPRINT_VERSION)-ipk
PY-CLOUDPRINT_IPK=$(BUILD_DIR)/py26-cloudprint_$(PY-CLOUDPRINT_VERSION)-$(PY-CLOUDPRINT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CLOUDPRINT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CLOUDPRINT_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cloudprint-source: $(DL_DIR)/$(PY-CLOUDPRINT_SOURCE) $(PY-CLOUDPRINT_PATCHES)

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
$(PY-CLOUDPRINT_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CLOUDPRINT_SOURCE) $(PY-CLOUDPRINT_PATCHES)
	$(MAKE) py-setuptools-stage 
	rm -rf $(BUILD_DIR)/$(PY-CLOUDPRINT_DIR) $(@D)
	$(PY-CLOUDPRINT_UNZIP) $(DL_DIR)/$(PY-CLOUDPRINT_SOURCE) -d $(BUILD_DIR)/
#	cat $(PY-CLOUDPRINT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CLOUDPRINT_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CLOUDPRINT_DIR) $(@D)
	(cd $(@D); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
#	        echo "libraries=cloudprint3"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) > setup.cfg; \
	)
	touch $@

py-cloudprint-unpack: $(PY-CLOUDPRINT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CLOUDPRINT_BUILD_DIR)/.built: $(PY-CLOUDPRINT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-cloudprint: $(PY-CLOUDPRINT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CLOUDPRINT_BUILD_DIR)/.staged: $(PY-CLOUDPRINT_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-CLOUDPRINT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-cloudprint-stage: $(PY-CLOUDPRINT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cloudprint
#
$(PY-CLOUDPRINT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-cloudprint" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CLOUDPRINT_PRIORITY)" >>$@
	@echo "Section: $(PY-CLOUDPRINT_SECTION)" >>$@
	@echo "Version: $(PY-CLOUDPRINT_VERSION)-$(PY-CLOUDPRINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CLOUDPRINT_MAINTAINER)" >>$@
	@echo "Source: $(PY-CLOUDPRINT_SITE)/$(PY-CLOUDPRINT_SOURCE)" >>$@
	@echo "Description: $(PY-CLOUDPRINT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CLOUDPRINT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CLOUDPRINT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CLOUDPRINT_IPK_DIR)/opt/sbin or $(PY-CLOUDPRINT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CLOUDPRINT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CLOUDPRINT_IPK_DIR)/opt/etc/py-cloudprint/...
# Documentation files should be installed in $(PY-CLOUDPRINT_IPK_DIR)/opt/doc/py-cloudprint/...
# Daemon startup scripts should be installed in $(PY-CLOUDPRINT_IPK_DIR)/opt/etc/init.d/S??py-cloudprint
#
# You may need to patch your application to make it use these locations.
#
$(PY-CLOUDPRINT_IPK): $(PY-CLOUDPRINT_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-cloudprint_*_$(TARGET_ARCH).ipk
	rm -rf $(PY-CLOUDPRINT_IPK_DIR) $(BUILD_DIR)/py26-cloudprint_*_$(TARGET_ARCH).ipk
	(cd $(PY-CLOUDPRINT_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY-CLOUDPRINT_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY-CLOUDPRINT_IPK_DIR)/opt/lib/python2.6/site-packages/cloudprint.so
	install -d $(PY-CLOUDPRINT_IPK_DIR)/opt/etc/init.d
	install -m 755 $(PY-CLOUDPRINT_SOURCE_DIR)/S90cloudprint-daemon $(PY-CLOUDPRINT_IPK_DIR)/opt/etc/init.d/S90cloudprint-daemon
	$(MAKE) $(PY-CLOUDPRINT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CLOUDPRINT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cloudprint-ipk: $(PY-CLOUDPRINT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cloudprint-clean:
	-$(MAKE) -C $(PY-CLOUDPRINT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cloudprint-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CLOUDPRINT_DIR) $(PY-CLOUDPRINT_BUILD_DIR) $(PY-CLOUDPRINT_IPK_DIR) $(PY-CLOUDPRINT_IPK)

#
# Some sanity check for the package.
#
py-cloudprint-check: $(PY-CLOUDPRINT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY-CLOUDPRINT_IPK)
