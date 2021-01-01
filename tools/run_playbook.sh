#!/usr/bin/env bash

if [[ $# -gt 0 ]]; then
	POSITIONAL=()
	while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
		-b|--bootstrap)
		BOOTSTRAP="YES"
		shift # past argument
		;;
		--install-requirements)
		REQUIREMENTS=YES
		shift # past argument
		;;
		-l|--limit)
		LIMITER="$2"
		shift # past argument
		shift # past value
		;;
		-p|--playbook)
		PLAYBOOK="$2"
		shift # past argument
		shift # past value
		;;
		-s|--skip-tags)
		SKIP_TAGS_ARG="$2"
		shift # past argument
		shift # past value
		;;
		-t|--tags)
		TAGS_ARG="$2"
		shift # past argument
		shift # past value
		;;
		-v|--verbose)
		VERBOSE="-v"
		shift # past argument
		;;
		-vv)
		VERBOSE="-vv"
		shift # past argument
		;;
		-vvv)
		VERBOSE="-vvv"
		shift # past argument
		;;
		-vvvv)
		VERBOSE="-vvvv"
		shift # past argument
		;;
		-vvvvv)
		VERBOSE="-vvvvv"
		shift # past argument
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
	echo "  $0 <-p path/to/playbook> [-l <limit>] [-b] [--install-requirements]"
	echo ""
	echo "	-b,	--bootstrap"
	echo "			Bootstrap Server. This is for Server where the base role was never executed on."
	echo "		--install-requirements"
	echo "			Install ansible-galaxy requirements"
	echo "	-l,	--limit"
	echo "			Limit playboot to specific hosts or groups"
	echo "			e.g.: \"-l host0,host1,group0,group1\""
	echo "	-p,	--playbook"
	echo "			Path to playbook directory, relative to repo root"
	echo "	-s,	--skip-tags"
	echo "			Skip specific tags during playbook execution"
	echo "			e.g.: \"-s tag0,tag1,tagN\""
	echo "	-t,	--tags"
	echo "			Limit playbook execution to specific tags"
	echo "			e.g.: \"-t tag0,tag1,tagN\""
	echo "	-v,	--verbose"
	echo "			Verbose outputs for ansible playbooks add more \"v\"\'s to increase the verbosity"
	echo "			e.g.: \"-v\""
	exit
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Check if required option are set
if [[ -z $PLAYBOOK ]]; then
	echo "Error:  \"-p\" option is required!"
	exit
fi

# Install requirements for the limiter (if there are any)
if [[ -f "${SCRIPTPATH}/../requirements.yml" ]] && [[ "${REQUIREMENTS}" == "YES" ]]; then
	echo -e "#\n# Install requirements from Ansible Galaxy"
	ansible-galaxy role install --force -r "${SCRIPTPATH}/../requirements.yml"
	ansible-galaxy collection install --force -r "${SCRIPTPATH}/../requirements.yml"
fi

# Run limiter
if [[ ${BOOTSTRAP} == "YES" ]]; then
	echo -e "#\n# Bootstrap Server"
	PLAY="bootstrap.yml"
elif [[ -z ${BOOTSTRAP} ]]; then
	echo -e "#\n# Run Playbook"
	PLAY="upgrade.yml"
fi

inventory="${SCRIPTPATH}/../playbooks/${PLAYBOOK}/inventory.yml"
playbook_path="${SCRIPTPATH}/../playbooks/${PLAYBOOK}"

if [[ -n ${LIMITER} ]]; then
	LIMIT="--limit ${LIMITER}"
fi

if [[ -n ${SKIP_TAGS_ARG} ]]; then
	SKIP_TAGS="--skip-tags ${SKIP_TAGS_ARG}"
fi

if [[ -n ${TAGS_ARG} ]]; then
	TAGS="--tags ${TAGS_ARG}"
fi

# Run playbook
env ANSIBLE_NOCOWS=1 ANSIBLE_LIBRARY=./library ansible-playbook --vault-id @prompt -i ${inventory} ${LIMIT} ${SKIP_TAGS} ${TAGS} ${VERBOSE} ${playbook_path}/${PLAY}