# Mesa 3-D graphics library
#
# Copyright (C) 2010-2011 Chia-I Wu <olvaffe@gmail.com>
# Copyright (C) 2010-2011 LunarG Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# Android.mk for glapi

LOCAL_PATH := $(call my-dir)

mapi_abi_headers :=

# ---------------------------------------
# Build libglapi
# ---------------------------------------

include $(CLEAR_VARS)

abi_header := shared-glapi/glapi_mapi_tmp.h

LOCAL_SRC_FILES := \
	entry.c \
	mapi_glapi.c \
	stub.c \
	table.c \
	u_current.c \
	u_execmem.c

LOCAL_CFLAGS := \
	-DMAPI_MODE_GLAPI \
	-DMAPI_ABI_HEADER=\"$(abi_header)\"

LOCAL_C_INCLUDES := \
	$(MESA_TOP)/src/mapi

LOCAL_EXPORT_C_INCLUDE_DIRS := \
	$(MESA_TOP)/src/mapi

LOCAL_MODULE := libglapi
LOCAL_LICENSE_KINDS := SPDX-license-identifier-Apache-2.0 SPDX-license-identifier-MIT
LOCAL_LICENSE_CONDITIONS := notice
LOCAL_NOTICE_FILE := $(LOCAL_PATH)/../../LICENSE

LOCAL_MODULE_CLASS := SHARED_LIBRARIES
intermediates := $(call local-generated-sources-dir)
abi_header := $(intermediates)/$(abi_header)
LOCAL_GENERATED_SOURCES := $(abi_header)

$(abi_header): PRIVATE_PRINTER := shared-glapi

mapi_abi_headers += $(abi_header)

include $(MESA_COMMON_MK)
include $(BUILD_SHARED_LIBRARY)


mapi_abi_deps := \
	$(wildcard $(LOCAL_PATH)/glapi/gen/*.py) \
	$(wildcard $(LOCAL_PATH)/glapi/gen/*.xml) \
	$(LOCAL_PATH)/mapi_abi.py

$(mapi_abi_headers): PRIVATE_SCRIPT := $(MESA_PYTHON3) $(LOCAL_PATH)/mapi_abi.py
$(mapi_abi_headers): PRIVATE_APIXML := $(LOCAL_PATH)/glapi/gen/gl_and_es_API.xml
$(mapi_abi_headers): $(mapi_abi_deps)
	@mkdir -p $(dir $@)
	@echo "target $(PRIVATE_PRINTER): $(PRIVATE_MODULE) <= $(PRIVATE_APIXML)"
	$(hide) $(PRIVATE_SCRIPT) --printer $(PRIVATE_PRINTER) $(PRIVATE_APIXML) > $@
