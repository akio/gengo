cmake_minimum_required(VERSION 2.8.3)
project(gengo)

find_package(catkin REQUIRED COMPONENTS genmsg rosgo_build_tools)

catkin_package(
  CATKIN_DEPENDS genmsg
  CFG_EXTRAS gengo-extras.cmake
)

add_subdirectory(scripts)

file(WRITE ${CATKIN_DEVEL_PREFIX}/${GENMSG_LANGS_DESTINATION}/gengo "Go")
install(
    FILES ${CATKIN_DEVEL_PREFIX}/${GENMSG_LANGS_DESTINATION}/gengo
    DESTINATION ${GENMSG_LANGS_DESTINATION})

catkin_python_setup()
