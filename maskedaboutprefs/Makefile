include theos/makefiles/common.mk

BUNDLE_NAME = MaskedAboutPrefs
MaskedAboutPrefs_FILES = MaskedAboutPrefs.mm
MaskedAboutPrefs_INSTALL_PATH = /Library/PreferenceBundles
MaskedAboutPrefs_FRAMEWORKS = UIKit
MaskedAboutPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MaskedAboutPrefs.plist$(ECHO_END)
