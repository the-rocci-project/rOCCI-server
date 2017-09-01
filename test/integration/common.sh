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

# Global constants
CURL_BIN="/usr/bin/curl"
ENDPOINT="https://localhost:3000"
AUTH_TOKEN="am9obm55Om9wZW5uZWJ1bGEK"

# log_error 'Message to log to STDERR'
function log_error {
  printf "E, [%s] [ ERROR ] $1\n" "$(date)"
}

# log_info 'Message to log to STDOUT'
function log_info {
  printf "I, [%s] [ INFO  ] $1\n" "$(date)"
}

# display 'JSON Model' '{...}' "$?"
function display {
  if [ "x$3" = "x0" ]; then
    RESULT="✓"
  else
    RESULT="x"
  fi

  printf "[$RESULT] $1\n"

  if [ "x$SHOW_RESPONSE" = "xyes" ] || [ "$RESULT" = "x" ]; then
    echo "$2"
  fi
}

# curl_call 'GET' '/-/' 'application/occi+json'
# curl_call 'POST' '/compute/' 'application/occi+json' '/path/to/file.json' 'application/occi+json'
function curl_call {
  if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ; then
    log_error 'METHOD, PATH, and FORMAT are mandatory for curl calls'
    exit 1
  fi
  OPTS=(-X "$1" --insecure --silent --show-error --fail)
  HEADERS=(-H "X-Auth-Token: $AUTH_TOKEN" -H "Accept: $3")
  LOCATION="${ENDPOINT}${2}"

  if [ "x$1" = "xPOST" ] ; then
    if [ -z "$4" ] || [ -z "$5" ] ; then
      log_error 'DATA and Content-Type are mandatory for POST'
      exit 1
    fi

    DATA="--data-binary @$4"
    HEADERS+=(-H "Content-Type: $5")
  fi

  OUT=$( $CURL_BIN "${OPTS[@]}" "${HEADERS[@]}" $DATA $LOCATION 2>&1 )
  if [ "x$?" != "x0" ] ; then
    log_error "$OUT"
    exit 2
  fi

  echo $OUT
}

# get '/-/' 'application/occi+json'
function get {
  curl_call 'GET' $@
}

# post '/compute/' 'application/occi+json' '/path/to/file.json' 'application/occi+json'
function post {
  curl_call 'POST' $@
}

# delete '/compute/1'
function delete {
  curl_call 'DELETE' $1 'application/occi+json'
}

# get_json '/-/'
function get_json {
  get $1 'application/occi+json'
}

# get_plain '/-/'
function get_plain {
  get $1 'text/plain'
}

# get_locations '/compute/'
function get_locations {
  get $1 'text/uri-list'
}

# post_with_format '/compute/' '/path/to/file' 'application/occi+json'
function post_with_format {
  post $1 $3 $2 $3
}

# post_json '/compute/' '/path/to/file.json'
function post_json {
  post_with_format $1 $2 'application/occi+json'
}

# post_plain '/compute/' '/path/to/file.plain'
function post_plain {
  post_with_format $1 $2 'text/plain'
}
