
#函数:my-dir
#参数:
#功能:获取当前makefile的路径
my-dir=$(shell dirname $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))