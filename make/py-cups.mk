###########################################################
#
# py-cups
#
###########################################################

#
# PY-CUPS_VERSION, PY-CUPS_SITE and PY-CUPS_SOURCE define
# the upstream location of the source code for the package.
# PY-CUPS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CUPS_UNZIP is the command used to unzip the source.
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
#
PY-CUPS_VERSION=1.9.62
PY-CUPS_SITE=https://pypi.python.org/packages/source/p/pycups/
PY-CUPS_SOURCE=pycups-$(PY-CUPS_VERSION).tar.bz2
PY-CUPS_DIR=pycups-$(PY-CUPS_VERSION)
PY-CUPS_UNZIP=bzcat
PY-CUPS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CUPS_DESCRIPTION=A set of Python bindings for the libcups library from the CUPS project.
PY-CUPS_SECTION=misc
PY-CUPS_PRIORITY=optional
PY-CUPS_DEPENDS=python26, cups
PY-CUPS_CONFLICTS=

#
# PY-CUPS_IPK_VERSION should be incremented when the ipk changes.
#
PY-CUPS_IPK_VERSION=1

#
# PY-CUPS_CONFFILES should be a list of user-editable files
#PY-CUPS_CONFFILES=/opt/etc/py-cups.conf /opt/etc/init.d/SXXpy-cups

#
# PY-CUPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CUPS_PATCHES=$(PY-CUPS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CUPS_CPPFLAGS=
PY-CUPS_LDFLAGS=

#
# PY-CUPS_BUILD_DIR is the directory in which the build is done.
# PY-CUPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CUPS_IPK_DIR is the directory in which the ipk is built.
# PY-CUPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CUPS_BUILD_DIR=$(BUILD_DIR)/py-cups
PY-CUPS_SOURCE_DIR=$(SOURCE_DIR)/py-cups
PY-CUPS_IPK_DIR=$(BUILD_DIR)/py26-cups-$(PY-CUPS_VERSION)-ipk
PY-CUPS_IPK=$(BUILD_DIR)/py26-cups_$(PY-CUPS_VERSION)-$(PY-CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CUPS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CUPS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cups-source: $(DL_DIR)/$(PY-CUPS_SOURCE) $(PY-CUPS_PATCHES)

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
$(PY-CUPS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CUPS_SOURCE) $(PY-CUPS_PATCHES)
	$(MAKE) py-setuptools-stage cups-stage
	rm -rf $(BUILD_DIR)/$(PY-CUPS_DIR) $(@D)
	$(PY-CUPS_UNZIP) $(DL_DIR)/$(PY-CUPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CUPS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CUPS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CUPS_DIR) $(@D)
	(cd $(@D); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
#	        echo "libraries=cups3"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) > setup.cfg; \
	)
	touch $@

py-cups-unpack: $(PY-CUPS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CUPS_BUILD_DIR)/.built: $(PY-CUPS_BUILD_DIR)/.configured
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
py-cups: $(PY-CUPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CUPS_BUILD_DIR)/.staged: $(PY-CUPS_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-CUPS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-cups-stage: $(PY-CUPS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cups
#
$(PY-CUPS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-cups" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CUPS_PRIORITY)" >>$@
	@echo "Section: $(PY-CUPS_SECTION)" >>$@
	@echo "Version: $(PY-CUPS_VERSION)-$(PY-CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CUPS_MAINTAINER)" >>$@
	@echo "Source: $(PY-CUPS_SITE)/$(PY-CUPS_SOURCE)" >>$@
	@echo "Description: $(PY-CUPS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CUPS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CUPS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CUPS_IPK_DIR)/opt/sbin or $(PY-CUPS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CUPS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CUPS_IPK_DIR)/opt/etc/py-cups/...
# Documentation files should be installed in $(PY-CUPS_IPK_DIR)/opt/doc/py-cups/...
# Daemon startup scripts should be installed in $(PY-CUPS_IPK_DIR)/opt/etc/init.d/S??py-cups
#
# You may need to patch your application to make it use these locations.
#
$(PY-CUPS_IPK): $(PY-CUPS_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-cups_*_$(TARGET_ARCH).ipk
	rm -rf $(PY-CUPS_IPK_DIR) $(BUILD_DIR)/py26-cups_*_$(TARGET_ARCH).ipk
	(cd $(PY-CUPS_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY-CUPS_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY-CUPS_IPK_DIR)/opt/lib/python2.6/site-packages/cups.so
	$(MAKE) $(PY-CUPS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CUPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cups-ipk: $(PY-CUPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cups-clean:
	-$(MAKE) -C $(PY-CUPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cups-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CUPS_DIR) $(PY-CUPS_BUILD_DIR) $(PY-CUPS_IPK_DIR) $(PY-CUPS_IPK)

#
# Some sanity check for the package.
#
py-cups-check: $(PY-CUPS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY-CUPS_IPK)
