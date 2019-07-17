#检查模块是否已经存在

LOCAL_MODULE_TYPE :=staticlib

BUILD_MODULES += $(call build_module)
CLEAN_TGTS += $(call build_out_module_path) $(call build_objs)
CLEANALL_TGTS += $(call build_out_module_path) $(call build_objs) $(call build_deps)
PHONY += $(call build_module) $(call build_module-prebuild) $(call build_module-postbuild)

$(call build_gen_deps_rule)

$(call build_gen_obj_rule)

$(call build_gen_staticlib_rule)

$(call build_export_var)

include $(call build_deps)