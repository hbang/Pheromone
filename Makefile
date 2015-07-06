include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Pheromone
Pheromone_FILES = $(wildcard *.xm)
Pheromone_FRAMEWORKS = CoreGraphics UIKit
Pheromone_CFLAGS = -include Global.h

Global.xm_CFLAGS = -DPHEROMONE_GLOBAL_XM

include $(THEOS_MAKE_PATH)/tweak.mk

after-Pheromone-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support/Pheromone.bundle
	cp -r Resources/ $(THEOS_STAGING_DIR)/Library/Application\ Support/Pheromone.bundle

after-install::
	install.exec "killall Cydia; sleep 0.2; sblaunch com.saurik.Cydia"
