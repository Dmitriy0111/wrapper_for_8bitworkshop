help:
	$(info make help           	- show this message)
	$(info make c_patch_8bit	- create patch file)
	$(info make a_patch_8bit	- apply patch file)
	$(info Open and read the Makefile for details)
	@true

PWD     := $(shell pwd)

# create patch file
c_patch_8bit:
	git diff --patch > .patch
# apply patch file
a_patch_8bit:
	git apply .patch
    