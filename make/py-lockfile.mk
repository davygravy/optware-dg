###########################################################
#
# py-lockfile
#
###########################################################

#
# PY-LOCKFILE_VERSION, PY-LOCKFILE_SITE and PY-LOCKFILE_SOURCE define
# the upstream location of the source code for the package.
# PY-LOCKFILE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-LOCKFILE_UNZIP is the command used to unzip the source.
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
# http://pylockfile.googlecode.com/files/lockfile-0.9.1.tar.gz
PY-LOCKFILE_VERSION=0.9.1
PY-LOCKFILE_SITE= http://pylockfile.googlecode.com/files
PY-LOCKFILE_SOURCE=lockfile-$(PY-LOCKFILE_VERSION).tar.gz
PY-LOCKFILE_DIR=lockfile-$(PY-LOCKFILE_VERSION)
PY-LOCKFILE_UNZIP=zcat
PY-LOCKFILE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-LOCKFILE_DESCRIPTION=A platform-independent file locking module.
PY-LOCKFILE_SECTION=misc
PY-LOCKFILE_PRIORITY=optional
PY-LOCKFILE_DEPENDS=python26
PY-LOCKFILE_CONFLICTS=

#
# PY-LOCKFILE_IPK_VERSION should be incremented when the ipk changes.
#
PY-LOCKFILE_IPK_VERSION=1

#
# PY-LOCKFILE_CONFFILES should be a list of user-editable files
#PY-LOCKFILE_CONFFILES=/opt/etc/py-lockfile.conf /opt/etc/init.d/SXXpy-lockfile

#
# PY-LOCKFILE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-LOCKFILE_PATCHES=$(PY-LOCKFILE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-LOCKFILE_CPPFLAGS=
PY-LOCKFILE_LDFLAGS=

#
# PY-LOCKFILE_BUILD_DIR is the directory in which the build is done.
# PY-LOCKFILE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-LOCKFILE_IPK_DIR is the directory in which the ipk is built.
# PY-LOCKFILE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-LOCKFILE_BUILD_DIR=$(BUILD_DIR)/py-lockfile
PY-LOCKFILE_SOURCE_DIR=$(SOURCE_DIR)/py-lockfile
PY-LOCKFILE_IPK_DIR=$(BUILD_DIR)/py26-lockfile-$(PY-LOCKFILE_VERSION)-ipk
PY-LOCKFILE_IPK=$(BUILD_DIR)/py26-lockfile_$(PY-LOCKFILE_VERSION)-$(PY-LOCKFILE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-LOCKFILE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-LOCKFILE_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-lockfile-source: $(DL_DIR)/$(PY-LOCKFILE_SOURCE) $(PY-LOCKFILE_PATCHES)

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
$(PY-LOCKFILE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-LOCKFILE_SOURCE) $(PY-LOCKFILE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-LOCKFILE_DIR) $(@D)
	$(PY-LOCKFILE_UNZIP) $(DL_DIR)/$(PY-LOCKFILE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-LOCKFILE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-LOCKFILE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-LOCKFILE_DIR) $(@D)
	(cd $(@D); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
#	        echo "libraries=lockfile3"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) > setup.cfg; \
	)
	touch $@

py-lockfile-unpack: $(PY-LOCKFILE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-LOCKFILE_BUILD_DIR)/.built: $(PY-LOCKFILE_BUILD_DIR)/.configured
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
py-lockfile: $(PY-LOCKFILE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-LOCKFILE_BUILD_DIR)/.staged: $(PY-LOCKFILE_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-LOCKFILE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-lockfile-stage: $(PY-LOCKFILE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-lockfile
#
$(PY-LOCKFILE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-lockfile" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-LOCKFILE_PRIORITY)" >>$@
	@echo "Section: $(PY-LOCKFILE_SECTION)" >>$@
	@echo "Version: $(PY-LOCKFILE_VERSION)-$(PY-LOCKFILE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-LOCKFILE_MAINTAINER)" >>$@
	@echo "Source: $(PY-LOCKFILE_SITE)/$(PY-LOCKFILE_SOURCE)" >>$@
	@echo "Description: $(PY-LOCKFILE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-LOCKFILE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-LOCKFILE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-LOCKFILE_IPK_DIR)/opt/sbin or $(PY-LOCKFILE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-LOCKFILE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-LOCKFILE_IPK_DIR)/opt/etc/py-lockfile/...
# Documentation files should be installed in $(PY-LOCKFILE_IPK_DIR)/opt/doc/py-lockfile/...
# Daemon startup scripts should be installed in $(PY-LOCKFILE_IPK_DIR)/opt/etc/init.d/S??py-lockfile
#
# You may need to patch your application to make it use these locations.
#
$(PY-LOCKFILE_IPK): $(PY-LOCKFILE_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-lockfile_*_$(TARGET_ARCH).ipk
	rm -rf $(PY-LOCKFILE_IPK_DIR) $(BUILD_DIR)/py26-lockfile_*_$(TARGET_ARCH).ipk
	(cd $(PY-LOCKFILE_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY-LOCKFILE_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY-LOCKFILE_IPK_DIR)/opt/lib/python2.6/site-packages/lockfile.so
	$(MAKE) $(PY-LOCKFILE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-LOCKFILE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-lockfile-ipk: $(PY-LOCKFILE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-lockfile-clean:
	-$(MAKE) -C $(PY-LOCKFILE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-lockfile-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-LOCKFILE_DIR) $(PY-LOCKFILE_BUILD_DIR) $(PY-LOCKFILE_IPK_DIR) $(PY-LOCKFILE_IPK)

#
# Some sanity check for the package.
#
py-lockfile-check: $(PY-LOCKFILE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY-LOCKFILE_IPK)
