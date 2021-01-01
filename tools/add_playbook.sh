#!/usr/bin/env bash

if [[ $# -gt 0 ]]; then
	POSITIONAL=()
	while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
		-p|--playbook)
		PLAYBOOK="$2"
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
	echo "  $0 <-p playbook_name>"
	echo ""
	echo "	-p,	--playbook"
	echo "			Name for the new playbook"
	exit
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Check if required option are set
if [[ -z ${PLAYBOOK} ]]; then
	echo "Error:  \"-p\" option is required!"
	exit
fi

mkdir -p ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/{group_vars,host_vars,lcl_vars,files,templates,handlers,tasks}/
if [[ ! -f ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/inventory.yml ]] || [[ ! -f ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/bootstrap.yml ]] || [[ ! -f ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/upgrade.yml, ]] || [[ ! -f ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/README.md ]] || [[ ! -f ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/inventory.yml ]] || [[ ! -f ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/playbook.yml ]]; then
	touch ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/{inventory.yml,bootstrap.yml,upgrade.yml,playbook.yml,README.md}
	cat << EOF > ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/inventory.yml
---
all:
  hosts:
  children:
    group_name_here:
      hosts:
EOF
	cat << EOF > ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/bootstrap.yml
---
- hosts: all
  roles:
    # Set this role to you needs.
    # (Meta) base roles can be found in the roles directory
    # - { role: shokinn.base_<meta base role>, tags: [ system, base ] }
  vars:
    ansible_user: "{{ bootstrap_user }}"
  #   ansible_ssh_pass: "{{ bootstrap_password }}"

- import_playbook: playbook.yml
EOF
	cat << EOF > ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/upgrade.yml
---
- hosts: all
  roles:
    # Set this role to you needs.
    # (Meta) base roles can be found in the roles directory
    # - { role: shokinn.base_<meta base role>, tags: [ system, base ] }

- import_playbook: playbook.yml
EOF
	cat << EOF > ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/group_vars/all.yml
---
ansible_python_interpreter: /usr/bin/env python3
ansible_user: ansible
bootstrap_user: root
# bootstrap_password:
EOF
	cat << EOF > ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/playbook.yml
---
- hosts:
  vars_files: []

  roles: []

  tasks: []

  handlers: []
EOF
	echo "# ${PLAYBOOK} playbook" > ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/README.md
fi

[[ ! -d ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/roles ]] && ln -s ../../roles ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/
[[ ! -d ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/vars ]] && ln -s ../../vars ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/
[[ ! -d ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/library ]] && ln -s ../../library ${SCRIPTPATH}/../playbooks/${PLAYBOOK}/
