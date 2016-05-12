#!/bin/sh

SCRIPT_LOC=$(readlink -f $0)

PIPE_DIR=$(dirname ${SCRIPT_LOC})

IDL=idl85

SSW_DIR=${PIPE_DIR}/ssw
GEN_DIR=${PIPE_DIR}/gen
LIB_DIR=${PIPE_DIR}/lib
COMP_SRC_DIR=${PIPE_DIR}/src
COMP_PATH=+${COMP_SRC_DIR}:${SSW_DIR}:${GEN_DIR}:+${LIB_DIR}:"<IDL_DEFAULT>"

#CONFIG_FILE=${PIPE_DIR}/config/comp.mgalloy.kaula.production.cfg
CONFIG=${PIPE_DIR}/config/comp.mgalloy.compdata.l2test.cfg

${IDL} -IDL_STARTUP "" -IDL_PATH ${COMP_PATH} -e "!quiet = 1 & comp_run_pipeline, config_filename='${CONFIG}'"