#!/bin/bash
alias doc-build_ctrl="tar -czh . | docker build -t affear/ctrl:ok -"
alias doc-build_cmp="tar -czh . | docker build -t affear/cmp:ok -"
alias doc-run_ctrl="docker run --privileged=true -ti -h controller --name=ctrl affear/ctrl:ok"
alias doc-run_cmp="docker run --privileged=true -ti affear/cmp:ok"
alias doc-attach_ctrl="docker attach ctrl"

function doc-reinstall_nova {
	if [ $# -eq 0 ]; then
		echo "Give container ID or name, please."
	else
		docker exec $1 ./reinstall_service.sh nova
	fi
}