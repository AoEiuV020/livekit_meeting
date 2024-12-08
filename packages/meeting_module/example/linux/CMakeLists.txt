cmake_minimum_required(VERSION 3.10)
project(gtk_window_test)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
find_package(X11 REQUIRED)

include_directories(${GTK3_INCLUDE_DIRS} ${X11_INCLUDE_DIR})
link_directories(${GTK3_LIBRARY_DIRS} ${X11_LIBRARY_DIRS})

add_executable(main_window src/main.c)
add_executable(child_window src/child.c)

target_link_libraries(main_window ${GTK3_LIBRARIES} ${X11_LIBRARIES})
target_link_libraries(child_window ${GTK3_LIBRARIES} ${X11_LIBRARIES})

# 添加编译定义以启用 X11 支持
add_definitions(-DGTK_DISABLE_DEPRECATION_WARNINGS)