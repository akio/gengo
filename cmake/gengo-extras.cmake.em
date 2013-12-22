# vim: set ft=cmake :
@[if DEVELSPACE]@
# location of scripts in develspace
set(GENGO_BIN_DIR "@(CMAKE_CURRENT_SOURCE_DIR)/scripts")
@[else]@
# location of scripts in installspace
set(GENGO_BIN_DIR "${gengo_DIR}/../../../@(CATKIN_PACKAGE_BIN_DESTINATION)")
@[end if]@

set(gengo_INSTALL_DIR go/src)
set(GENMSG_GO_BIN ${GENGO_BIN_DIR}/gen_go.py)
set(GENSRV_GO_BIN ${GENGO_BIN_DIR}/gen_go.py)

# Generate .msg -> .go
# The generated .go files should be added ALL_GEN_OUTPUT_FILES_go
macro(_generate_msg_go ARG_PKG ARG_MSG ARG_IFLAGS ARG_MSG_DEPS ARG_GEN_OUTPUT_DIR)

  #Append msg to output dir
  set(GEN_OUTPUT_DIR "${ARG_GEN_OUTPUT_DIR}")
  file(MAKE_DIRECTORY ${GEN_OUTPUT_DIR})
  #Create input and output filenames
  get_filename_component(MSG_SHORT_NAME ${ARG_MSG} NAME_WE)

  set(MSG_GENERATED_NAME ${MSG_SHORT_NAME}.go)
  set(GEN_OUTPUT_FILE ${GEN_OUTPUT_DIR}/${MSG_GENERATED_NAME})

  add_custom_command(OUTPUT ${GEN_OUTPUT_FILE}
    DEPENDS ${GENMSG_GO_BIN} ${ARG_MSG} ${ARG_MSG_DEPS}
    COMMAND ${CATKIN_ENV} ${GENMSG_GO_BIN} ${ARG_MSG}
    ${ARG_IFLAGS}
    -p ${ARG_PKG}
    -o ${GEN_OUTPUT_DIR}
    COMMENT "Generating Go code from MSG ${ARG_PKG}/${MSG_SHORT_NAME}"
    )

  list(APPEND ALL_GEN_OUTPUT_FILES_go ${GEN_OUTPUT_FILE})

endmacro()

#todo, these macros are practically equal. Check for input file extension instead
macro(_generate_srv_go ARG_PKG ARG_SRV ARG_IFLAGS ARG_MSG_DEPS ARG_GEN_OUTPUT_DIR)

  #Append msg to output dir
  set(GEN_OUTPUT_DIR "${ARG_GEN_OUTPUT_DIR}")
  file(MAKE_DIRECTORY ${GEN_OUTPUT_DIR})

  #Create input and output filenames
  get_filename_component(SRV_SHORT_NAME ${ARG_SRV} NAME_WE)

  set(SRV_GENERATED_NAME ${SRV_SHORT_NAME}.go)
  set(GEN_OUTPUT_FILE ${GEN_OUTPUT_DIR}/${SRV_GENERATED_NAME})

  add_custom_command(OUTPUT ${GEN_OUTPUT_FILE}
    DEPENDS ${GENSRV_GO_BIN} ${ARG_SRV} ${ARG_MSG_DEPS}
    COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENSRV_GO_BIN} ${ARG_SRV}
    ${ARG_IFLAGS}
    -p ${ARG_PKG}
    -o ${GEN_OUTPUT_DIR}
    COMMENT "Generating Go code from SRV ${ARG_PKG}/${SRV_SHORT_NAME}"
    )

  list(APPEND ALL_GEN_OUTPUT_FILES_go ${GEN_OUTPUT_FILE})
endmacro()

macro(_generate_module_go ARG_PKG ARG_GEN_OUTPUT_DIR ARG_GENERATED_FILES)
  # Nothing to do
endmacro()


#macro(rosgo_generate_messages)
#    execute_process(COMMAND ${CATKIN_ENV} rosmsg packages
#                    OUTPUT_VARIABLE rosmsg_output
#                    OUTPUT_STRIP_TRAILING_WHITESPACE)
#    string(REPLACE "\n" ";" msg_pkg_list ${rosmsg_output})
#    set(iflags "")
#    foreach(msg_pkg ${msg_pkg_list})
#        execute_process(COMMAND ${CATKIN_ENV} rospack find ${msg_pkg}
#                        OUTPUT_VARIABLE msg_pkg_path
#                        OUTPUT_STRIP_TRAILING_WHITESPACE)
#        set(iflags "${iflags} -I${msg_pkg}:${msg_pkg_path}/msg")
#    endforeach()
#    message(STATUS iflags=${iflags})
#    foreach(pkg ${ARGV})
#        execute_process(COMMAND ${CATKIN_ENV} rospack find ${pkg}
#                        OUTPUT_VARIABLE pkg_path
#                        OUTPUT_STRIP_TRAILING_WHITESPACE)
#        message(STATUS pkg_path=${pkg_path})
#        set(msg_dir ${pkg_path}/msg)
#        message(STATUS msg_dir=${msg_dir})
#        file(GLOB msg_files "${msg_dir}/*.msg")
#        message(STATUS msg_files=${msg_files})
#    
#        set(output_files "")
#        foreach(msg ${msg_files})
#            file(MAKE_DIRECTORY ${gengo_INSTALL_DIR}/${pkg})
#            get_filename_component(msg_name ${msg} NAME_WE)
#            set(output_file ${gengo_INSTALL_DIR}/${pkg}/${msg_name}.go)
#            message(STATUS "${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_GO_BIN} ${msg} ${iflags} -p ${pkg} -o ${gengo_INSTALL_DIR}/${pkg}")
#            add_custom_command(OUTPUT ${output_file}
#                COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_GO_BIN}
#                ${msg} ${iflags}
#                -p ${pkg}
#                -o ${gengo_INSTALL_DIR}/${pkg})
#            list(APPEND output_files ${output_file})
#        endforeach()
#
#        set(srv_dir ${pkg_path}/srv)
#        message(STATUS srv_dir=${srv_dir})
#        file(GLOB srv_files "${srv_dir}/*.srv")
#        message(STATUS srv_files=${srv_files})
#
#        add_custom_target(rosgo_genmsg_for_${pkg} ALL DEPENDS ${output_files})
#    endforeach()
#endmacro()
