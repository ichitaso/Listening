ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET = iphone:16.5:15.0
else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
TARGET = iphone:16.5:15.0
else
export PREFIX=$(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
TARGET = iphone:14.5:11.0
endif

INSTALL_TARGET_PROCESSES = SpringBoard Preferences

THEOS_DEVICE_IP = 192.168.0.16

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Listening

Listening_FILES = Tweak.xm
Listening_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

SUBPROJECTS += ListeningPreferences ListeningCC

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
