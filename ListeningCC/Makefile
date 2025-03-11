ARCHS = arm64 arm64e

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET = iphone:16.5:15.0
else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
TARGET = iphone:16.5:15.0
else
export PREFIX=$(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
TARGET = iphone:14.5:11.0
endif

BUNDLE_NAME = Listening
$(BUNDLE_NAME)_FILES = Switch.m
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -fvisibility=hidden -Wno-unguarded-availability-new -Wno-deprecated-declarations
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = ControlCenterUIKit
$(BUNDLE_NAME)_INSTALL_PATH = /Library/ControlCenter/Bundles

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
