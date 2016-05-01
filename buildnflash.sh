#!/bin/bash

pushd scripts
./imaginize.sh
./ubootscr.sh
./flash.sh
popd
