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

TESTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$TESTS_DIR/common.sh"

# Debugging helper
SHOW_RESPONSE=no

# Collect failures
FAILS=0

printf "######################################################################\n"
printf "############################## Model #################################\n"
printf "######################################################################\n"

FORMATS=(plain json occi_json)

for FORMAT in ${FORMATS[@]} ; do
  MODEL_PATH="/-/"
  OUTPUT=$(get_$FORMAT $MODEL_PATH)

  RETVAL=$?
  if [ $RETVAL -ne 0 ] ; then
    FAILS=$((FAILS+1))
  fi

  display "$MODEL_PATH ($FORMAT)" "$OUTPUT" "$RETVAL"
done

printf "\n"

printf "######################################################################\n"
printf "############################## List ##################################\n"
printf "######################################################################\n"

LOCATIONS=(entity resource link)
LOCATIONS+=(compute network storage ipreservation securitygroup)
LOCATIONS+=(networkinterface storagelink securitygrouplink)

for LOCATION in ${LOCATIONS[@]} ; do
  ENTITY_PATH="/${LOCATION}/"
  OUTPUT=$(get_locations "$ENTITY_PATH")

  RETVAL=$?
  if [ $RETVAL -ne 0 ] ; then
    FAILS=$((FAILS+1))
  fi

  display "$ENTITY_PATH (uri-list)" "$OUTPUT" "$RETVAL"
done

printf "\n"

printf "######################################################################\n"
printf "############################# Create #################################\n"
printf "######################################################################\n"

FORMATS=(occi_json json plain)
LOCATIONS=(compute network storage ipreservation securitygroup)
# LOCATIONS+=(networkinterface storagelink securitygrouplink)
DATA_DIR="${TESTS_DIR}/data/one/"
CLEANUPS=()

for FORMAT in ${FORMATS[@]} ; do
  for LOCATION in ${LOCATIONS[@]} ; do
    INSTANCES_PATH="/${LOCATION}/"
    ENTITY=$(mktemp "/tmp/rocci-server-integration-${LOCATION}-${FORMAT}.XXXXXXXXXXXX")
    cp "${DATA_DIR}/${LOCATION}.${FORMAT#occi_}" "$ENTITY"
    sed -i "s/a262ad95\-c093\-4814\-8c0d\-bc6d475bb845/${LOCATION}\-a262ad95\-c093\-4814\-8c0d\-bc6d475bb845\-$FORMAT/g" "$ENTITY"
    OUTPUT=$(post_$FORMAT "$INSTANCES_PATH" "$ENTITY")

    RETVAL=$?
    if [ $RETVAL -ne 0 ] ; then
      FAILS=$((FAILS+1))
    else
      URL=$(echo "$OUTPUT" | sed "s/X-OCCI-Location: //g" | sed 's/\["//g' | sed 's/"\]//g' | sed 's/https\:\/\/localhost\:3000//g')
      CLEANUPS+=("$URL")
    fi

    display "$INSTANCES_PATH ($FORMAT)" "$OUTPUT" "$RETVAL"
  done
done

printf "\n"

printf "######################################################################\n"
printf "############################## Get ###################################\n"
printf "######################################################################\n"

FORMATS=(occi_json json plain)

for FORMAT in ${FORMATS[@]} ; do
  for CLEANUP in ${CLEANUPS[@]} ; do
    OUTPUT=$(get_$FORMAT "$CLEANUP")

    RETVAL=$?
    if [ $RETVAL -ne 0 ] ; then
      FAILS=$((FAILS+1))
    fi

    display "$CLEANUP ($FORMAT)" "$OUTPUT" "$RETVAL"
  done
done

printf "\n"

printf "######################################################################\n"
printf "############################# Delete #################################\n"
printf "######################################################################\n"

for CLEANUP in ${CLEANUPS[@]} ; do
  OUTPUT=$(delete "$CLEANUP")

  RETVAL=$?
  if [ $RETVAL -ne 0 ] ; then
    FAILS=$((FAILS+1))
  fi

  display "$CLEANUP" "$OUTPUT" "$RETVAL"
done

printf "\n"

exit $FAILS
