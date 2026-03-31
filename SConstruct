#!/usr/bin/env python
import os

# 1. 引入官方 C++ 库的环境配置
env = SConscript("godot-cpp/SConstruct")

# 2. 告诉编译器我们的头文件在哪
env.Append(CPPPATH=["src/"])

# 3. 抓取 src 目录下的所有 cpp 源码
sources = Glob("src/*.cpp")

# 4. 【关键修复】使用引擎自带的变量拼接后缀
# env["suffix"] 会变成 ".windows.template_debug.x86_64"
# env["SHLIBSUFFIX"] 会在 Windows 下自动变成 ".dll"
lib_name = "libredraw" + env["suffix"] + env["SHLIBSUFFIX"]
lib_path = "bin/" + lib_name

# 5. 编译动态链接库
library = env.SharedLibrary(target=lib_path, source=sources)

Default(library)