include theos/makefiles/common.mk

TWEAK_NAME = MaskedAbout
MaskedAbout_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences"
SUBPROJECTS += maskedaboutprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
