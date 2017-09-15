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
printf "############################## Get ###################################\n"
printf "######################################################################\n"

FAKE_ID="a262ad95-c093-4814-8c0d-bc6d475bb845"
FORMATS=(occi_json json plain)
LOCATIONS=(compute network storage ipreservation securitygroup)
LOCATIONS+=(networkinterface storagelink securitygrouplink)

for LOCATION in ${LOCATIONS[@]} ; do
  INSTANCES_PATH="/$LOCATION/"
  OUTPUT=$(get_json "$INSTANCES_PATH")

  RETVAL=$?
  if [ $RETVAL -ne 0 ] ; then
    FAILS=$((FAILS+1))
  fi

  display "$INSTANCES_PATH (json)" "$OUTPUT" "$RETVAL"
done

for FORMAT in ${FORMATS[@]} ; do
  for LOCATION in ${LOCATIONS[@]} ; do
    INSTANCE_PATH="/${LOCATION}/$FAKE_ID"
    OUTPUT=$(get_$FORMAT "$INSTANCE_PATH")

    RETVAL=$?
    if [ $RETVAL -ne 0 ] ; then
      FAILS=$((FAILS+1))
    fi

    display "$INSTANCE_PATH ($FORMAT)" "$OUTPUT" "$RETVAL"
  done
done

printf "\n"

printf "######################################################################\n"
printf "############################# Create #################################\n"
printf "######################################################################\n"

FORMATS=(occi_json json plain)
LOCATIONS=(compute network storage ipreservation securitygroup)
LOCATIONS+=(networkinterface storagelink securitygrouplink)
DATA_DIR="${TESTS_DIR}/data/dummy/"

for FORMAT in ${FORMATS[@]} ; do
  for LOCATION in ${LOCATIONS[@]} ; do
    INSTANCES_PATH="/${LOCATION}/"
    OUTPUT=$(post_$FORMAT "$INSTANCES_PATH" "${DATA_DIR}/${LOCATION}.${FORMAT#occi_}")

    RETVAL=$?
    if [ $RETVAL -ne 0 ] ; then
      FAILS=$((FAILS+1))
    fi

    display "$INSTANCES_PATH ($FORMAT)" "$OUTPUT" "$RETVAL"
  done
done

printf "\n"

printf "######################################################################\n"
printf "############################# Delete #################################\n"
printf "######################################################################\n"

FAKE_ID="a262ad95-c093-4814-8c0d-bc6d475bb845"
LOCATIONS=(compute network storage ipreservation securitygroup)
LOCATIONS+=(networkinterface storagelink securitygrouplink)

for LOCATION in ${LOCATIONS[@]} ; do
  INSTANCE_PATH="/${LOCATION}/$FAKE_ID"
  OUTPUT=$(delete "$INSTANCE_PATH")

  RETVAL=$?
  if [ $RETVAL -ne 0 ] ; then
    FAILS=$((FAILS+1))
  fi

  display "$INSTANCE_PATH" "$OUTPUT" "$RETVAL"
done

for LOCATION in ${LOCATIONS[@]} ; do
  INSTANCES_PATH="/${LOCATION}/"
  OUTPUT=$(delete "$INSTANCES_PATH")

  RETVAL=$?
  if [ $RETVAL -ne 0 ] ; then
    FAILS=$((FAILS+1))
  fi

  display "$INSTANCES_PATH" "$OUTPUT" "$RETVAL"
done

printf "\n"

exit $FAILS
