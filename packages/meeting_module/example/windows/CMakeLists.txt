cmake_minimum_required(VERSION 3.15)

# 设置项目名称
project(simple_window)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 添加可执行文件
add_executable(${PROJECT_NAME} WIN32
    main.cpp
    second_window.cpp
    second_window.h
)

# 链接必要的Windows库
target_link_libraries(${PROJECT_NAME} PRIVATE
    user32  # Windows用户界面基本功能
    gdi32   # 图形设备接口
)
