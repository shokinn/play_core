#!/usr/bin/env bash

if [[ $# -gt 0 ]]; then
	POSITIONAL=()
	while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
		-r|--role)
		ROLE="$2"
		shift # past argument
		shift # past value
		;;
		*)	# unknown option
		POSITIONAL+=("$1") # save it in an array for later
		shift # past argument
		;;
	esac
	done
	set -- "${POSITIONAL[@]}" # restore positional parameters
else
	echo "Usage:"
	echo "  $0 <-r role_name>"
	echo ""
	echo "	-r, --role	Name for the new role"
	exit
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Check if required option are set
if [[ -z ${ROLE} ]]; then
	echo "Error:  \"-r\" option is required!"
	exit
fi

cd ${SCRIPTPATH}/../roles
ansible-galaxy init ${ROLE}
