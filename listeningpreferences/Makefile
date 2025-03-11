ARCHS = arm64 arm64e

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET = iphone:16.5:15.0
else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
TARGET = iphone:16.5:15.0
else
export PREFIX=$(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
TARGET = iphone:14.5:11.0
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ListeningPreferences

$(BUNDLE_NAME)_FILES = LISRootListController.m
$(BUNDLE_NAME)_FRAMEWORKS = UIKit SafariServices
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -fvisibility=hidden -Wno-unguarded-availability-new -Wno-deprecated-declarations -Wno-unused-function

include $(THEOS_MAKE_PATH)/bundle.mk
