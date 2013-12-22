#!/usr/bin/env python
import sys
import genmsg.template_tools

msg_template_map = {'msg.go.template': '@NAME@.go'}
srv_template_map = {'srv.go.template': '@NAME@.go'}

if __name__ == "__main__":
    genmsg.template_tools.generate_from_command_line_options(sys.argv,
                                                             msg_template_map,
                                                             srv_template_map)
