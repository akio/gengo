# vim: set ft=cmake :
@[if DEVELSPACE]@
# location of scripts in develspace
set(GENGO_BIN_DIR "@(CMAKE_CURRENT_SOURCE_DIR)/scripts"
    CACHE INTERNAL "gengo binary directory")
@[else]@
# location of scripts in installspace
set(GENGO_BIN_DIR "${gengo_DIR}/../../../@(CATKIN_PACKAGE_BIN_DESTINATION)"
    CACHE INTERNAL "gengo binary directory")
@[end if]@

set(GENMSG_GO_BIN ${GENGO_BIN_DIR}/gen_go.py CACHE INTERNAL "genmsg for go")
set(GENSRV_GO_BIN ${GENGO_BIN_DIR}/gen_go.py CACHE INTERNAL "genmsg for go")

execute_process(COMMAND go env GOARCH OUTPUT_VARIABLE ROSGO_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND go env GOOS OUTPUT_VARIABLE ROSGO_OS OUTPUT_STRIP_TRAILING_WHITESPACE)

set(gengo_INSTALL_DIR ${CATKIN_GLOBAL_LIB_DESTINATION}/go/src)

# Generate .msg -> .go
# The generated .go files should be added ALL_GEN_OUTPUT_FILES_go
macro(_generate_msg_go ARG_PKG ARG_MSG ARG_IFLAGS ARG_MSG_DEPS ARG_GEN_OUTPUT_DIR)
    # Create input and output filenames
    get_filename_component(MSG_SHORT_NAME ${ARG_MSG} NAME_WE)

    # Append msg to output dir
    set(GEN_OUTPUT_DIR "${ARG_GEN_OUTPUT_DIR}")
    file(MAKE_DIRECTORY ${GEN_OUTPUT_DIR})

    set(MSG_GENERATED_NAME ${MSG_SHORT_NAME}.go)
    set(GEN_OUTPUT_FILE ${GEN_OUTPUT_DIR}/${MSG_GENERATED_NAME})

    add_custom_command(
        OUTPUT ${GEN_OUTPUT_FILE}
        DEPENDS ${GENMSG_GO_BIN} ${ARG_MSG} ${ARG_MSG_DEPS}
        COMMAND ${CATKIN_ENV} ${GENMSG_GO_BIN} ${ARG_MSG}
        ${ARG_IFLAGS}
        -p ${ARG_PKG}
        -o ${GEN_OUTPUT_DIR}
        COMMENT "Generating Go code from MSG ${ARG_PKG}/${MSG_SHORT_NAME}"
    )

    list(APPEND ALL_GEN_OUTPUT_FILES_go ${GEN_OUTPUT_FILE})
endmacro()


macro(_generate_srv_go ARG_PKG ARG_SRV ARG_IFLAGS ARG_MSG_DEPS ARG_GEN_OUTPUT_DIR)
    # Create input and output filenames
    get_filename_component(SRV_SHORT_NAME ${ARG_SRV} NAME_WE)

    # Append msg to output dir
    set(GEN_OUTPUT_DIR "${ARG_GEN_OUTPUT_DIR}")
    file(MAKE_DIRECTORY ${GEN_OUTPUT_DIR})

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

# Generate messages from specified packages.  As a result the macro
# defines a custom target `${pkg}_generate_messages_go` for each package.
# Can be repeated and will only generate messages for each package once.
macro(rosgo_generate_messages)
    set(ROSGO_SRC_DIR ${CATKIN_DEVEL_PREFIX}/lib/go/src)
    execute_process(COMMAND ${CATKIN_ENV} rosmsg packages -s
                    OUTPUT_VARIABLE rosmsg_output
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REPLACE " " ";" msg_pkg_list ${rosmsg_output})
    set(iflags "")
    foreach(msg_pkg ${msg_pkg_list})
        execute_process(COMMAND ${CATKIN_ENV} rospack find ${msg_pkg}
                        OUTPUT_VARIABLE msg_pkg_path
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
        list(APPEND iflags "-I${msg_pkg}:${msg_pkg_path}/msg")
    endforeach()
    set(all_gen_output_files "")
    foreach(pkg ${ARGV})
        if(NOT TARGET ${pkg}_generate_messages_go)
            # Find msg directory
            execute_process(COMMAND ${CATKIN_ENV} rospack find ${pkg}
                            OUTPUT_VARIABLE pkg_path
                            OUTPUT_STRIP_TRAILING_WHITESPACE)
            set(gen_output_files "")

            set(msg_dir ${pkg_path}/msg)
            file(GLOB msg_files "${msg_dir}/*.msg")

            foreach(msg ${msg_files})
                file(MAKE_DIRECTORY ${ROSGO_SRC_DIR}/${pkg})
                get_filename_component(msg_name ${msg} NAME_WE)
                set(output_file ${ROSGO_SRC_DIR}/${pkg}/${msg_name}.go)
                add_custom_command(
                    OUTPUT ${output_file}
                    COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_GO_BIN}
                    ${msg} ${iflags} -p ${pkg} -o ${ROSGO_SRC_DIR}/${pkg}
                )
                list(APPEND gen_output_files ${output_file})
            endforeach()

            set(srv_dir ${pkg_path}/srv)
            file(GLOB srv_files "${srv_dir}/*.srv")
            foreach(srv ${srv_files})
                file(MAKE_DIRECTORY ${ROSGO_SRC_DIR}/${pkg})
                get_filename_component(srv_name ${srv} NAME_WE)
                set(output_files "")
                list(APPEND output_files ${ROSGO_SRC_DIR}/${pkg}/${srv_name}.go)
                list(APPEND output_files ${ROSGO_SRC_DIR}/${pkg}/${srv_name}Request.go)
                list(APPEND output_files ${ROSGO_SRC_DIR}/${pkg}/${srv_name}Response.go)
                add_custom_command(
                    OUTPUT ${output_files}
                    COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_GO_BIN}
                    ${srv} ${iflags} -p ${pkg} -o ${ROSGO_SRC_DIR}/${pkg}
                )
                list(APPEND gen_output_files ${output_files})
            endforeach()

            #add_custom_target(${pkg}_gengo ALL DEPENDS ${gen_output_files})
            add_custom_target(${pkg}_generate_messages_go ALL DEPENDS ${gen_output_files})
        endif()
    endforeach()
endmacro()

