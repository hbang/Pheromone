include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Pheromone
Pheromone_FILES = $(wildcard *.xm)
Pheromone_FRAMEWORKS = CoreGraphics UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall Cydia; sleep 0.2; sblaunch com.saurik.Cydia"
