#逗号
COMMA :=,

#C语言编译器
CC := gcc

#C++编译器
CXX := g++

#静态库打包命令
AR := ar cr

#删除命令
RM := -rm -rf

#C语言文件编译参数
CFLAGS := -Wall -Werror -g

#C++语言文件编译参数
CXXFLAGS := -Wall -Werror -g

#库及链接参数(C/C++参数相同)
LDFLAGS :=

#编译所有目标
BUILD_MODULES :=
CLEAN_TGTS :=
CLEANALL_TGTS :=

OUT_DIR := ./build