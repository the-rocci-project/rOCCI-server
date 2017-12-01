#!/bin/bash

source $(dirname $0)/configuration.sh

configure_rocci
bundle exec --keep-file-descriptors puma $@
