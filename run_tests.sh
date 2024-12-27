#!/bin/bash

tests_dir=./tests
FILTER=$1
IS_ANY_ERROR=0

for test_file in $tests_dir/${FILTER}.lua; do
    lua $test_file

    if [[ $? -ne 0 ]]; then
        IS_ANY_ERROR=1
    fi
done

if [[ $IS_ANY_ERROR -ne 0 ]]; then
    exit -1
fi

