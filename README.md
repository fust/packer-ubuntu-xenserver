# packer-ubuntu-1804-xenserver
Packer template to create a Ubuntu 18.04.3 template on XenServer

This template is largely based on [geerlingguy/packer-ubuntu-1804](https://github.com/geerlingguy/packer-ubuntu-1804) with some modifications to work on XenServer 7 and XCP-ng.


This template should be used with my fork of the [packer-builder-xenserver](https://github.com/fust/packer-builder-xenserver) plugin as it uses some custom options.

If not used with the custom fork you should remove the `convert: true` line from `ubuntu-18.04.json` as it is incompatible with the original.