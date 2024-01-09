TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ListeningPreferences

ListeningPreferences_FILES = LISRootListController.m
ListeningPreferences_FRAMEWORKS = UIKit
ListeningPreferences_PRIVATE_FRAMEWORKS = Preferences
ListeningPreferences_INSTALL_PATH = /Library/PreferenceBundles
ListeningPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
