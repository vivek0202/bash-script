#!/usr/bin/bash

# Function to log messages
log_message() {
    echo "$1" | tee -a ${LOG}
}

# Function to check for ebiz in application.properties
check_ebiz() {
    if [[ ${HOSTNAME} == ${pdsvr} ]]; then
        log_message "Checking for ebiz in ${PACKAGE_DIR}/Configuration/dist/application.properties"
        if grep -q "ebiz" ${PACKAGE_DIR}/Configuration/dist/application.properties | grep -vq "MQ.Local"; then
            log_message "ebiz found in ${PACKAGE_DIR}/Configuration/dist/application.properties failing !!!"
            rm -v /opt/appstage/stage/active_deployment_running | tee -a ${LOG}
            exit 99
        fi
    fi
}

# Function to copy files and log
copy_and_log() {
    local src=$1
    local dest=$2
    local log_file=$3

    log_message "Copying ${src} to ${dest}"
    cp -pv ${src} ${dest} | tee -a ${LOG}
    local rc=${PIPESTATUS[0]}
    if [ ${rc} -ne 0 ]; then
        rm -v /opt/appstage/stage/active_deployment_running | tee -a ${LOG}
        exit ${rc}
    fi

    log_message "${log_file} - $(date) ${app_version} Deploy to Region: ${DEPLOY_REGION}" >> ${log_file}
}

# Set variables
LOG=/opt/appstage/stage/logs/${app_name}.$(date +%Y%m%d_%H%M%S).log
PACKAGE_DIR="/path/to/package_dir"
HOSTNAME=$(hostname)
pdsvr="pdsvr_hostname"
app_version="1.0.0"
DEPLOY_REGION="region_name"

# Check for ebiz in application.properties
check_ebiz

# Copy files and log
copy_and_log "${PACKAGE_DIR}/HealthCheck.ear" "/opt/appstage/deployments/HealthCheck/" "/opt/appstage/deployments/HealthCheck/PC_Deployment.log"
copy_and_log "${PACKAGE_DIR}/Logging.ear" "/opt/appstage/deployments/Logging/" "/opt/appstage/deployments/Logging/PC_Deployment.log"
copy_and_log "${PACKAGE_DIR}/Management.ear" "/opt/appstage/deployments/Management/" "/opt/appstage/deployments/Management/PC_Deployment.log"
copy_and_log "${PACKAGE_DIR}/OaTSS.ear" "/opt/appstage/deployments/OaTSS/" "/opt/appstage/deployments/OaTSS/PC_Deployment.log"
copy_and_log "${PACKAGE_DIR}/NSS.ear" "/opt/appstage/deployments/NSS/" "/opt/appstage/deployments/NSS/PC_Deployment.log"
copy_and_log "${PACKAGE_DIR}/ProvCtlTimer.ear" "/opt/appstage/deployments/ProvCtlTimer/" "/opt/appstage/deployments/ProvCtlTimer/PC_Deployment.log"

# Remove active deployment file
rm -v /opt/appstage/stage/active_deployment_running | tee -a ${LOG}
