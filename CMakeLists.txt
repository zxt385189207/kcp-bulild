
cmake_minimum_required(VERSION 2.8.12)

# CMAKE_SYSTEM_NAME,不包含版本的系统名,比如 Linux
# 判断系统是win32 但不是 cygwin  也不是 WindowsStore
if ( WIN32 AND NOT CYGWIN AND NOT ( CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" ) )
	
	# set(<变量> <值>... CACHE <类型> <描述> [FORCE])
	# 设置给定的缓存。由于缓存项旨在提供用户可设置的值，因此默认情况下不会覆盖现有的缓存项。
	# CFLAGS   表示用于 C 编译器的选项
	# CXXFLAGS 表示用于 C++ 编译器的选项。
	
	# C语言编译器
	# Release编译选项 后续增加 /MT  编译选项
	# Debug编译选项   后续增加 /MTd 编译选项
	set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT" CACHE STRING "")
	set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd" CACHE STRING "")
	
	# C++语言编译器
	# Release编译选项 后续增加 /MT  编译选项
	# Debug编译选项   后续增加 /MTd 编译选项
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT" CACHE STRING "")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd" CACHE STRING "")
endif ()

# 项目名称
project(kcp)


if ( IOS )
				# IOS 编译选项
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fembed-bitcode")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fembed-bitcode")
endif ()


# 查找包含命名文件的目录。find_path（<VAR> NAMES [path1 path2 ...]）
# 此命令用于查找包含指定文件的目录。将创建一个名为<VAR>缓存变量来存储此命令的结果。如果找到目录中的文件，结果将存储在变量中
# NAMES ：为目录中的文件指定一个或多个可能的名称。 SConstruct
# PATHS ：指定要搜索的目录以及默认位置。 指定了${CMAKE_SOURCE_DIR}目录
# NO_DEFAULT_PATH：不会搜索其他路径

# scons构建方式
# 试图寻找SConstruct这个文件，scons由Sconstruct 作为入口，控制如何进行编译操作。
# Sconstruct 本身是一个python文件，把CPP编译成可执行文件
find_path(KCP_PROJECT_DIR NAMES SConstruct
    PATHS 
    ${CMAKE_SOURCE_DIR}
    NO_DEFAULT_PATH
    )

# 将缓存变量标记为高级,高级变量指的是那些在cmake GUI中，只有当“显示高级选项”被打开时才会被显示的变量。
MARK_AS_ADVANCED(KCP_PROJECT_DIR)

# 设置一个普通变量，指定要编译的c/cpp文件
set ( KCP_CORE
    jni/kcp.c
)


# 开始记录宏以供以后作为命令调用， 相当于设定一个方法
# macro( <方法名> [<参数1> ...])   
# 		<commands>
# endmacro()

# 根据目录分组？  目标目录，源文件
macro(source_group_by_dir proj_dir source_files)
    if(MSVC OR APPLE)
    		# 获取目标目录的绝对路径，存在sgbd_cur_dir变量里
        get_filename_component(sgbd_cur_dir ${proj_dir} ABSOLUTE) 
        
        # 遍历所有源文件，// 命名：sgbd(source_group_by_dir 按目录划分的源组）
        foreach(sgbd_file ${${source_files}})
        
        		# 获取这些源文件的绝对路径，存在sgbd_abs_file变量里
						get_filename_component(sgbd_abs_file ${sgbd_file} ABSOLUTE)
						
						# 文件操作命令, 
						# file(RELATIVE_PATH <variable> <directory> <file>) 
						# 从<目录sgbd_cur_dir>到<文件sgbd_abs_file>的相对路径，并将其存储在<变量sgbd_fpath>中
            file(RELATIVE_PATH sgbd_fpath ${sgbd_cur_dir} ${sgbd_abs_file})
            
            # 正则表达式
            # string(REGEX REPLACE <正则表达式> <替换匹配项的字符> <输出变量> <输入> )
            # 正则参数  \(.*\)/.*    替换参数 \\1  输出 sgbd_group_name  输入 文件的相对路径
            # 可以引用使用\1、\2、…、\9匹配的用括号分隔的子表达式。注意，在CMake代码中需要两个反斜杠(\\1)来通过参数解析获得反斜杠。
            MESSAGE("sgbd_fpath: " ${sgbd_fpath}) # jni/kcp.c
            string(REGEX REPLACE "\(.*\)/.*" \\1 sgbd_group_name ${sgbd_fpath})
            MESSAGE("sgbd_group_name: " ${sgbd_group_name})  # jni
            
            # string(COMPARE EQUAL <string1> <string2> <output_variable>) 0表示false
            # 两个字符串不相等
            string(COMPARE EQUAL ${sgbd_fpath} ${sgbd_group_name} sgbd_nogroup)
           
            
            # 替换反斜杠
            string(REPLACE "/" "\\" sgbd_group_name ${sgbd_group_name})
            MESSAGE("sgbd_group_name: " ${sgbd_group_name})
            
            if(sgbd_nogroup)
                set(sgbd_group_name "\\")
            endif(sgbd_nogroup)
            
            # source_group(<name> [FILES <src>...])
            # FILES 任何明确指定的源文件都将放在group中 <name>。相对路径相对于当前源目录进行解释。
            MESSAGE("sgbd_file: " ${sgbd_file}) # jni/kcp.c
            source_group(${sgbd_group_name} FILES ${sgbd_file})
            
        endforeach(sgbd_file)
    endif(MSVC OR APPLE)
endmacro(source_group_by_dir)



# 调用函数
MESSAGE("CMAKE_CURRENT_SOURCE_DIR: " ${CMAKE_CURRENT_SOURCE_DIR}) # /Users/zhangyinan/Project/kcp-bulild
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} KCP_CORE)

MESSAGE("Apple?: " ${APPLE}) # 1
if (APPLE)
    if (IOS)
        set(CMAKE_OSX_ARCHITECTURES "$(ARCHS_STANDARD)")
        add_library(kcp STATIC
           ${KCP_CORE}
        )
    else ()
    		MESSAGE("CMAKE_OSX_ARCHITECTURES: " ${CMAKE_OSX_ARCHITECTURES}) # 
        set(CMAKE_OSX_ARCHITECTURES "$(ARCHS_STANDARD)")
        add_library(kcp MODULE
            ${KCP_CORE}
        )
        MESSAGE("CMAKE_OSX_ARCHITECTURES: " ${CMAKE_OSX_ARCHITECTURES}) # ARCHS_STANDARD_32_64_BIT
        
        # 目标可以具有影响其构建方式的属性。set_target_properties(target1 PROPERTIES prop1 value1 )
        set_target_properties ( kcp PROPERTIES BUNDLE TRUE )
        #set_target_properties ( kcp PROPERTIES FRAMEWORK TRUE )
        #set_target_properties ( kcp PROPERTIES MACOSX_RPATH TRUE )
    endif ()
else ( )
		# 使用指定的源文件将库添加到项目中。
		# SHARED库动态链接并在运行时加载。 
    add_library(kcp SHARED
        ${KCP_CORE}
    )
endif ( )

if ( WIN32 AND NOT CYGWIN )
	# 指定预定义宏DLL_EXPORTS，这个宏只有在window平台编译dll动态库才需要，其它平台不需要
	target_compile_definitions (kcp PRIVATE DLL_EXPORTS)
endif ( )

