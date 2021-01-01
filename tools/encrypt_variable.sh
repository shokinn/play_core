#!/usr/bin/env bash

while [ -z ${variable_name} ]; do
	read -r -p "Variable name for encrypted: " variable_name
done

while ( [ -z ${secret} ] || [ -z ${secret_confirm} ] ) || [ "${secret}" != "${secret_confirm}" ]; do
	read -r -s -p "Secret to be encrypted: " secret; echo ""
	read -r -s -p "Confirm secret: " secret_confirm; echo ""
done

ansible-vault encrypt_string --vault-id @prompt "${secret}" --name "${variable_name}"
