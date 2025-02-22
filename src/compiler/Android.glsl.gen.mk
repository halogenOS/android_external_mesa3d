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

# included by glsl Android.mk for source generation

ifeq ($(LOCAL_MODULE_CLASS),)
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
endif

intermediates := $(call local-generated-sources-dir)
prebuilt_intermediates := $(MESA_TOP)/prebuilt-intermediates

LOCAL_SRC_FILES := $(LOCAL_SRC_FILES)

LOCAL_C_INCLUDES += \
	$(intermediates)/glsl \
	$(intermediates)/glsl/glcpp \
	$(LOCAL_PATH)/glsl \
	$(LOCAL_PATH)/glsl/glcpp

LOCAL_GENERATED_SOURCES += $(addprefix $(intermediates)/, \
	$(LIBGLCPP_GENERATED_FILES) \
	$(LIBGLSL_GENERATED_FILES))

LOCAL_EXPORT_C_INCLUDE_DIRS += \
	$(intermediates)/glsl

# Modules using libmesa_nir must set LOCAL_GENERATED_SOURCES to this
MESA_GEN_GLSL_H := $(addprefix $(call local-generated-sources-dir)/, \
	glsl/ir_expression_operation.h \
	glsl/ir_expression_operation_constant.h \
	glsl/ir_expression_operation_strings.h)

define local-l-or-ll-to-c-or-cpp
	@mkdir -p $(dir $@)
	@echo "Mesa Lex: $(PRIVATE_MODULE) <= $<"
	$(hide) M4=$(M4) $(LEX) --nounistd -o$@ $<
endef

$(intermediates)/glsl/glsl_lexer.cpp: $(LOCAL_PATH)/glsl/glsl_lexer.ll $(LEX) $(M4)
	$(call local-l-or-ll-to-c-or-cpp)

$(intermediates)/glsl/glsl_parser.cpp: PRIVATE_YACCFLAGS := -p "_mesa_glsl_"
$(intermediates)/glsl/glsl_parser.cpp: .KATI_IMPLICIT_OUTPUTS := $(intermediates)/glsl/glsl_parser.h
$(intermediates)/glsl/glsl_parser.cpp: $(LOCAL_PATH)/glsl/glsl_parser.yy $(BISON) $(BISON_DATA) $(M4)
	$(transform-y-to-c-or-cpp)

$(intermediates)/glsl/glcpp/glcpp-lex.c: $(LOCAL_PATH)/glsl/glcpp/glcpp-lex.l $(LEX) $(M4)
	$(call local-l-or-ll-to-c-or-cpp)

$(intermediates)/glsl/glcpp/glcpp-parse.c: PRIVATE_YACCFLAGS := -p "glcpp_parser_"
$(intermediates)/glsl/glcpp/glcpp-parse.c: .KATI_IMPLICIT_OUTPUTS := $(intermediates)/glsl/glcpp/glcpp-parse.h
$(intermediates)/glsl/glcpp/glcpp-parse.c: $(LOCAL_PATH)/glsl/glcpp/glcpp-parse.y $(BISON) $(BISON_DATA) $(M4)
	$(transform-y-to-c-or-cpp)

$(intermediates)/glsl/ir_expression_operation.h: $(prebuilt_intermediates)/glsl/ir_expression_operation.h
	cp -a $< $@

$(intermediates)/glsl/ir_expression_operation_constant.h: $(prebuilt_intermediates)/glsl/ir_expression_operation_constant.h
	cp -a $< $@

$(intermediates)/glsl/ir_expression_operation_strings.h: $(prebuilt_intermediates)/glsl/ir_expression_operation_strings.h
	cp -a $< $@

$(intermediates)/glsl/float64_glsl.h: $(MESA_TOP)/src/util/xxd.py
	@mkdir -p $(dir $@)
	$(hide) $(MESA_PYTHON3) $< $(MESA_TOP)/src/compiler/glsl/float64.glsl $@ -n float64_source > $@
