#!/bin/bash

set -e

echo "Initial dcos-cli setup:" > /dcos/dcos-cli-setup.log
if [[ ! -z ${DCOS_IP} ]]; then
    echo "Setting core.dcos_url to: ${DCOS_IP}" >> /dcos/dcos-cli-setup.log
    dcos config set core.dcos_url http://${DCOS_IP}
fi

if [[ "${SSL}" == "true" ]]; then
    echo "Setting https as protocol."
    dcos config set core.dcos_url https://${DCOS_IP}
fi

if [[ ! -z ${DCOS_ACS_TOKEN} ]]; then
    echo "Setting core.dcos_acs_token to: ${DCOS_ACS_TOKEN}" >> /dcos/dcos-cli-setup.log
    dcos config set core.dcos_acs_token ${DCOS_ACS_TOKEN}
fi

if [[ ! -z ${EMAIL} ]]; then
    echo "Setting core.email to: ${EMAIL}" >> /dcos/dcos-cli-setup.log
    dcos config set core.email ${EMAIL}
fi

if [[ ! -z ${MESOS_MASTER_URL} ]]; then
    echo "Setting core.mesos_master_url to: ${MESOS_MASTER_URL}" >> /dcos/dcos-cli-setup.log
    dcos config set core.mesos_master_url ${MESOS_MASTER_URL}
fi

if [[ ! -z ${TOKEN} ]]; then 
    echo "Setting core.token to: ${TOKEN}" >> /dcos/dcos-cli-setup.log
    dcos config set core.token ${TOKEN}
fi

echo "Setting core.reporting to: ${CORE_REPORTING:-true}" >> /dcos/dcos-cli-setup.log
dcos config set core.reporting ${CORE_REPORTING:-true}

echo "Setting core.ssl_verify to: ${SSL_VERIFY:-false}" >> /dcos/dcos-cli-setup.log
dcos config set core.ssl_verify ${SSL_VERIFY:-false}

echo "Setting core.timeout to: ${TIMEOUT:-5}" >> /dcos/dcos-cli-setup.log
dcos config set core.timeout ${TIMEOUT:-5}

source /usr/local/bin/env-setup

echo "source /usr/local/bin/env-setup" >> /root/.bashrc

if [[ "${SSH}" == "true" ]]; then
    echo "Setting up ssh..."
    /usr/sbin/sshd -e
fi

if [[ "${TOKEN_AUTHENTICATION}" == "true" ]]; then
	if [[ -z ${PEM_FILE_PATH} ]]; then
		if [[ -z ${BOOTSTRAP_USER} || -z ${REMOTE_PASSWORD} ]]; then
			echo "No user and/or password provided for DCOS cluster Manager system"
			exit
		fi
		system=$(echo ${DCOS_IP} | cut -d"/" -f3)
		dcos_secret=$(sshpass -p "${REMOTE_PASSWORD}" ssh -ttt -o StrictHostKeyChecking=no ${BOOTSTRAP_USER}@$system sudo cat /var/lib/dcos/dcos-oauth/auth-token-secret)
	else
		if [[ ! -f ${PEM_FILE_PATH} ]]; then
			echo "Pem file provided does not exist in system!!"
		    exit
		fi
		if [[ -z ${BOOTSTRAP_USER} ]]; then
            echo "No user provided for DCOS cluster Manager system"
            exit
		fi
		system=$(echo ${DCOS_IP} | cut -d"/" -f3)
        dcos_secret=$(ssh -ttt -o "StrictHostKeyChecking no" -i ${PEM_FILE_PATH} ${BOOTSTRAP_USER}@$system sudo cat /var/lib/dcos/dcos-oauth/auth-token-secret)
	fi
	for i in {1..5}
	    do
	        token=$(java -jar /dcos/dcosTokenGenerator.jar $dcos_secret ${DCOS_USER}) && break
	done
    dcos config set core.dcos_acs_token $token
fi

if [[ ! -z ${DCOS_IP} ]]; then
	echo "${DCOS_IP}	master.mesos" >> /etc/hosts
fi

tail -f /dcos/dcos-cli-setup.log