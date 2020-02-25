#!/bin/sh


OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="test-fw.log"
export RESULT_FILE
# If no component param is passed to it test-fw.sh will run all known tests
TEST_SET=""
TEST_FW_PATH="/opt/tests"

usage() {
    echo "Usage: $0 [-t <test-fw test set to run, e.g: dlt-daemon>]" 1>&2
    exit 1
}

while getopts "t:h" o; do
  case "$o" in
    t)
      TEST_SET="${OPTARG}"
      LOG_FILE="test-fw_${TEST_SET}.log"
      ;;
    h|*)
      usage
      ;;
  esac
done

# Parse test-fw.sh output
parse_test_fw_output() {
    FAIL_COUNT=`cat ${OUTPUT}/${LOG_FILE} | grep -c FAILED`
    PASS_COUNT=`cat ${OUTPUT}/${LOG_FILE} | grep -c PASSED`
    # IF a FAILED occured
    if [ "x${FAIL_COUNT}" != "x0" ]; then
      echo "Found ${FAIL_COUNT} FAILED in output. Returning failure"
      exit 1
      # return failure
    elif [ "x${PASS_COUNT}" != "x0" ]; then
      echo "Found ${PASS_COUNT} PASSED in output. Returning success"
      exit 0
      # return success
    else
      echo "Found ${PASS_COUNT} PASSED and ${FAIL_COUNT} FAILED in output. Returning failure"
      exit 1
      # return failure as we had no failures or passes = general test failure
    fi
}

test_fw_run() {
    ${TEST_FW_PATH}/test-fw.sh ${TEST_SET} | tee "${OUTPUT}/${LOG_FILE}"
    parse_test_fw_output "${OUTPUT}/${LOG_FILE}"
}

# Move to path containing meta-ivi-test tests
#cd "${TEST_FW_PATH}"
# Create sub-directory for test log output
mkdir -m 777 -p "${OUTPUT}"

# Test run
test_fw_run
