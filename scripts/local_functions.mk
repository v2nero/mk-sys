#函数:build_module
#参数:	$(1): 模块名
#功能:将本地模块名转换成编译依赖模块名
build_module=MODULE-$(LOCAL_MODULE)
build_module-prebuild=MODULE-prebuild-$(LOCAL_MODULE)
build_module-postbuild=MODULE-postbuild-$(LOCAL_MODULE)
build_module_binpath_varname=MODULE-$(LOCAL_MODULE)-binpath
build_module_dir_varname=MODULE-dir-$(LOCAL_MODULE)
build_module_depended_modules=$(LOCAL_DEPENDED_MODULES:%=MODULE-%)

#自动将LOCAL_C_INCLUDES，依赖的静态/动态库导出的C包含路径
build_cflags=$(CFLAGS) $(LOCAL_CFLAGS) $(addprefix -I,$(LOCAL_C_INCLUDES))
build_cxxflags=$(CXXFLAGS) $(LOCAL_CXXFLAGS) $(addprefix -I,$(LOCAL_CXX_INCLUDES))

build_ldflags=\
	$(if $(filter executable,$(LOCAL_MODULE_TYPE)),$(LDFLAGS) $(LOCAL_LDFLAGS) -Wl${COMMA}-Bstatic $(LOCAL_STATICLIBS:lib%=-l%) -Wl${COMMA}-Bdynamic $(LOCAL_DYNAMICLIBS:lib%=-l%),)\
	$(if $(filter staticlib,$(LOCAL_MODULE_TYPE)),$(LDFLAGS) $(LOCAL_LDFLAGS),)\
	$(if $(filter dynamiclib,$(LOCAL_MODULE_TYPE)),$(LDFLAGS) $(LOCAL_LDFLAGS) $(LOCAL_STATICLIBS:lib%=-l%),)

build_relativefiles=$(addprefix $(LOCAL_PATH)/,$(LOCAL_SRCS))
build_cfiles=$(filter %.c,$(call build_relativefiles))
build_cxxfiles=$(filter %.cxx,$(call build_relativefiles))
build_cppfiles=$(filter %.cpp,$(call build_relativefiles))
build_objs=$(addprefix $(OUT_DIR)/,$(patsubst %.c,%.o,$(call build_cfiles)) $(patsubst %.cxx,%.o,$(call build_cxxfiles)) $(patsubst %.cpp,%.o,$(call build_cppfiles)))
build_deps=$(addprefix $(OUT_DIR)/,$(patsubst %.c,%.d,$(call build_cfiles)) $(patsubst %.cxx,%.d,$(call build_cxxfiles)) $(patsubst %.cpp,%.d,$(call build_cppfiles)))
#build_out_module_path=\
	$(if $(filter executable,$(LOCAL_MODULE_TYPE)),$(OUT_DIR)/$(LOCAL_PATH)/$(LOCAL_MODULE),)\
	$(if $(filter staticlib,$(LOCAL_MODULE_TYPE)),$(OUT_DIR)/$(LOCAL_PATH)/$(LOCAL_MODULE).a,)\
	$(if $(filter dynamiclib,$(LOCAL_MODULE_TYPE)),$(OUT_DIR)/$(LOCAL_PATH)/$(LOCAL_MODULE).so,)
build_out_module_path=\
	$(if $(filter executable,$(LOCAL_MODULE_TYPE)),$(OUT_DIR)/$(LOCAL_MODULE),)\
	$(if $(filter staticlib,$(LOCAL_MODULE_TYPE)),$(OUT_DIR)/$(LOCAL_MODULE).a,)\
	$(if $(filter dynamiclib,$(LOCAL_MODULE_TYPE)),$(OUT_DIR)/$(LOCAL_MODULE).so,)

#$(OUT_DIR)/$(LOCAL_PATH)/$(LOCAL_MODULE)

#函数:_build_export_var
#参数:	
#功能:生成export变量
define	_build_export_var
$(call build_module_binpath_varname):=$(call build_out_module_path)
$(call build_module_dir_varname):=$(LOCAL_PATH)/$(LOCAL_MODULE)
endef

build_export_var=$(eval $(call _build_export_var))

#函数:_build_gen_deps_rule
#参数:	$(1): 目标文件集
#		$(2): 文件后缀
#		$(3): 编译参数
#		$(4): 重定向目录
#功能:生成某种后缀文件的依赖文件生成规则
#$(patsubst %.$(2),%.d,$(1)): %.d:%.$(2)
define _build_gen_deps_rule
$(addprefix $(4)/,$(1:.$(2)=.d)): $(4)/%.d:%.$(2)
	$$(Q)echo DD $$<
	$$(Q)mkdir -p $$$$(dirname $$@)
	$$(Q)$$(CC) -M $(3) $$< > $$@.$$$$$$$$;\
	sed 's,\($$(shell basename $$*)\)\.o[ :]*,$$(shell dirname $$@)/\1.o $$@:,g' < $$@.$$$$$$$$ > $$@;\
	rm -f $$@.$$$$$$$$
endef

#函数:build_gen_deps_rule
#参数:
#功能:生成源文件集所有c,cpp,cxx文件的依赖文件生成规则
build_gen_deps_rule=\
$(if $(call build_cfiles),\
	$(eval $(call _build_gen_deps_rule,$(call build_cfiles),c,$(call build_cflags),$(OUT_DIR)))\
	,)\
$(if $(call build_cxxfiles),\
	$(eval $(call _build_gen_deps_rule,$(call build_cxxfiles),cxx,$(call build_cxxflags),$(OUT_DIR)))\
	,)\
$(if $(call build_cppfiles),\
	$(eval $(call _build_gen_deps_rule,$(call build_cppfiles),cpp,$(call build_cxxflags),$(OUT_DIR)))\
	,)

#函数:_build_gen_c_obj_rule
#参数:	$(1): 目标文件集
#		$(2): 文件后缀
#		$(3): 编译参数
#		$(4): 重定向目录
#功能:生成C后缀文件的依赖文件生成规则
define _build_gen_c_obj_rule
$(addprefix $(4)/,$(1:.$(2)=.o)): $(4)/%.o:%.$(2)
	$$(Q)echo CC $$<
	$$(Q)mkdir -p $$$$(dirname $$@)
	$$(Q)$$(CC) -o $$@ -c $(3) $$<
endef

#函数:_build_gen_cxx_obj_rule
#参数:	$(1): 目标文件集
#		$(2): 文件后缀
#		$(3): 编译参数
#		$(4): 重定向目录
#功能:生成CXX后缀文件的依赖文件生成规则
define _build_gen_cxx_obj_rule
$(addprefix $(4)/,$(1:.$(2)=.o)): $(4)/%.o:%.$(2)
	$$(Q)echo CXX $$<
	$$(Q)mkdir -p $$$$(dirname $$@)
	$$(Q)$$(CXX) -o $$@ -c $(3) $$<
endef

#函数:build_gen_obj_rule
#参数:
#功能:生成源文件集所有c,cpp,cxx文件的依赖文件生成规则
build_gen_obj_rule=\
$(if $(call build_cfiles),\
	$(eval $(call _build_gen_c_obj_rule,$(call build_cfiles),c,$(call build_cflags),$(OUT_DIR)))\
	,)\
$(if $(call build_cxxfiles),\
	$(eval $(call _build_gen_cxx_obj_rule,$(call build_cxxfiles),cxx,$(call build_cxxflags),$(OUT_DIR)))\
	,)\
$(if $(call build_cppfiles),\
	$(eval $(call _build_gen_cxx_obj_rule,$(call build_cppfiles),cpp,$(call build_cxxflags),$(OUT_DIR)))\
	,)


#函数:_build_build_module_rule
#参数:	$(1): build_module name
#		$(2): local module name
#		$(3): prebuild target
#		$(4): postbuild target
#功能:生成CXX后缀文件的依赖文件生成规则
define _build_build_module_rule
$(1) : $(4)
$(4) : $(2)
$(2) : $(3)
endef

#函数:build_em
#参数:	$(1): build_module name
#		$(2): local module name
#		$(3): prebuild target
#		$(4): postbuild target
#功能:生成CXX后缀文件的依赖文件生成规则
define _build_build_module_rule
$(1) : $(4)
$(4) : $(2)
$(2) : $(3)
$(3) :
endef

#函数:_build_gen_executable_rule
#参数:	$(1): 目标
#		$(2): 依赖目标
#		$(3): 链接参数
#功能:生成CXX后缀文件的依赖文件生成规则
define _build_gen_executable_rule
$(1) : $(2) $(3)
	$$(Q)echo LINK $$@
	$$(Q)$$(CXX) $(2) $(4) -o $$@
endef

#函数:build_gen_executable_rule
#参数:	$(1): 目标
#		$(2): 依赖目标
#		$(3): 链接参数
#		$(4): 重定向目录
#功能:生成CXX后缀文件的依赖文件生成规则
build_gen_executable_rule= \
$(eval $(call _build_build_module_rule,$(call build_module),$(call build_out_module_path),$(call build_module-prebuild),$(call build_module-postbuild))) \
$(eval $(call _build_gen_executable_rule,$(call build_out_module_path),$(call build_objs),$(call build_module_depended_modules),$(call build_ldflags)))

#函数:_build_gen_staticlib_rule
#参数:	$(1): 目标
#		$(2): 依赖目标
#		$(3): 链接参数
#功能:生成CXX后缀文件的依赖文件生成规则
define _build_gen_staticlib_rule
$(1) : $(2)
	$$(Q)echo AR $$@
	$$(Q)$$(AR) -o $$@ $(3) $(2)
endef

#函数:build_gen_staticlib_rule
#参数:	$(1): 目标
#		$(2): 依赖目标
#		$(3): 链接参数
#		$(4): 重定向目录
#功能:生成CXX后缀文件的依赖文件生成规则
build_gen_staticlib_rule= \
$(eval $(call _build_build_module_rule,$(call build_module),$(call build_out_module_path),$(call build_module-prebuild),$(call build_module-postbuild))) \
$(eval $(call _build_gen_staticlib_rule,$(call build_out_module_path),$(call build_objs),$(call build_ldflags)))

#函数:_build_gen_dynamiclib_rule
#参数:	$(1): 目标
#		$(2): 依赖目标
#		$(3): 链接参数
#功能:生成CXX后缀文件的依赖文件生成规则
define _build_gen_dynamiclib_rule
$(1) : $(2)
	$$(Q)echo LINK $$@
	$$(Q)$$(CXX) $(2) $(3) -o $$@
endef

#函数:build_gen_dynamiclib_rule
#参数:	$(1): 目标
#		$(2): 依赖目标
#		$(3): 链接参数
#		$(4): 重定向目录
#功能:生成CXX后缀文件的依赖文件生成规则
build_gen_dynamiclib_rule= \
$(eval $(call _build_build_module_rule,$(call build_module),$(call build_out_module_path),$(call build_module-prebuild),$(call build_module-postbuild))) \
$(eval $(call _build_gen_dynamiclib_rule,$(call build_out_module_path),$(call build_objs),$(call build_ldflags)))