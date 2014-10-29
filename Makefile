KERNELRELEASE	?= `uname -r`
KERNEL_DIR	?= /lib/modules/$(KERNELRELEASE)/build
PWD		:= $(shell pwd)
obj-m		:= hid-lenovo.o

PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin
MANDIR  = $(PREFIX)/share/man
MAN1DIR = $(MANDIR)/man1
INSTALL = install
INSTALL_PROGRAM = $(INSTALL) -p -m 755
INSTALL_DIR     = $(INSTALL) -p -m 755 -d
INSTALL_DATA    = $(INSTALL) -m 644

MODULE_OPTIONS =

##########################################
# note on build targets
#
# module-assistant makes some assumptions about targets, namely
#  <modulename>: must be present and build the module <modulename>
#                <modulename>.ko is not enough
# install: must be present (and should only install the module)
#
# we therefore make <modulename> a .PHONY alias to <modulename>.ko
# and remove utils-installation from 'install'
# call 'make install-all' if you want to install everything
##########################################


.PHONY: all install clean distclean
.PHONY: install-all install-blacklist install-rules install-utils install-man
.PHONY: modprobe hid-lenovo

# we don't control the .ko file dependencies, as it is done by kernel
# makefiles. therefore hid-lenovo.ko is a phony target actually
.PHONY: hid-lenovo.ko

all: hid-lenovo.ko
hid-lenovo: hid-lenovo.ko
hid-lenovo.ko:
	@echo "Building v4l2-loopback driver..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules

install-all: install install-blacklist install-rules install-utils install-man
install:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules_install
	depmod -a  $(KERNELRELEASE)

install-blacklist: blacklist-lenovo.conf
	$(INSTALL_DATA) $< "/etc/modprobe.d/blacklist-lenovo.conf"

install-rules: utils/tp-compact-keyboard.rules
	$(INSTALL_DATA) $< "/etc/udev/rules.d/99-tp-compact-keyboard.rules"
	udevadm control --reload-rules

install-utils: utils/tp-compact-keyboard
	$(INSTALL_DIR) "$(DESTDIR)$(BINDIR)"
	$(INSTALL_PROGRAM) $< "$(DESTDIR)$(BINDIR)"

install-man: man/tp-compact-keyboard.1
	$(INSTALL_DIR) "$(DESTDIR)$(MAN1DIR)"
	$(INSTALL_DATA) $< "$(DESTDIR)$(MAN1DIR)"

clean:
	rm -f *~
	rm -f Module.symvers Module.markers modules.order
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean

distclean: clean
	rm -f man/tp-compact-keyboard.1

modprobe: hid-lenovo.ko
	chmod a+r hid-lenovo.ko
	-sudo rmmod hid_lenovo
	-sudo rmmod hid_lenovo_tpkbd
	-sudo rmmod hid-generic
	sudo insmod ./hid-lenovo.ko $(MODULE_OPTIONS)
	-sudo modprobe hid-generic

man/tp-compact-keyboard.1: utils/tp-compact-keyboard
	mkdir -p man
	help2man -N --name "Thinkpad Compact Keyboad tool" $^ > $@
