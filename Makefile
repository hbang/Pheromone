include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Pheromone
Pheromone_FILES = $(wildcard *.xm) $(wildcard *.m)
Pheromone_FRAMEWORKS = CoreGraphics UIKit
Pheromone_CFLAGS = -include Global.h
Pheromone_LIBRARIES = cephei

Global.xm_CFLAGS = -DPHEROMONE_GLOBAL_XM
BOZPongRefreshControl.m_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-Pheromone-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support/Pheromone.bundle
	cp -r Resources/ $(THEOS_STAGING_DIR)/Library/Application\ Support/Pheromone.bundle

after-install::
	install.exec "killall Cydia; sleep 0.2; sblaunch com.saurik.Cydia"
