#!/bin/bash

# -------------------------------------------------------------------------- #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

VAGRANT_DIR=/vagrant
TEMPLATE_DIR=$VAGRANT_DIR/examples/opennebula/templates

# set-up user account
oneuser create johnny opennebula
oneuser update johnny $TEMPLATE_DIR/user.one --append

# make basic resources accessible
oneimage chgrp ttylinux users
oneimage chmod ttylinux 440
oneimage chown ttylinux johnny

onetemplate chgrp ttylinux users
onetemplate chmod ttylinux 640

onevnet chgrp cloud users
onevnet chmod cloud 440
onevnet chown cloud johnny

# add access to clusters (availability zones)
oneacl create '@1 CLUSTER/* USE *'   # listing availability zones
oneacl create '@1 CLUSTER/* ADMIN *' # creating IP reservations in availability zone
oneacl create '@1 NET/* CREATE *'    # creating private networks

# add necessary group attributes
onegroup update users $TEMPLATE_DIR/group.one --append

# add necessary network attributes
onevnet update cloud $TEMPLATE_DIR/vnet_public.one --append

# add necessary template attributes
onetemplate update ttylinux $TEMPLATE_DIR/template.one --append
