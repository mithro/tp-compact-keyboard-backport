# tp-compact-keyboard-backport

This repository contains a "backport" of the hid-lenovo module in 3.17.1 for
usage on Ubuntu 14.04 (Trusty).

[tp-compact-keyboard + hid-lenovo driver](https://github.com/lentinj) was
developed by [Jamie Lentin](https://github.com/lentinj).

# Where things came from

 * hid-lenovo.c - Retrieved from https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/plain/drivers/hid/hid-lenovo.c?id=refs/tags/v3.17.1
 * dkms.conf / Makefile / etc - Based on code from v4l2loopback-source/v4l2loopback-dmks packages version 0.8.0-1.
