install(
    PROGRAMS gen_go.py
    DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(
    FILES msg.go.template srv.go.template
    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
