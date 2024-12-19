#!/usr/bin/bash

# Function to log messages
log_message() {
    echo "$1" | tee -a ${LOG}
}

# Function to handle errors
handle_error() {
    local rc=$1
    if [ ${rc} -ne 0 ]; then
        rm -v /provco/stage/active_deployment_running | tee -a ${LOG}
        exit ${rc}
    fi
}

# Function to backup application.properties
backup_application_properties() {
    if [ -f /provco/ProvisionController/apps/config/application.properties ]; then
        log_message "Back Up application.properties"
        cp -pv /provco/ProvisionController/apps/config/application.properties /provco/temp/application.properties.D$(date +%Y%m%d_%H%M).PRE | tee -a ${LOG}
        handle_error ${PIPESTATUS[0]}
        find /provco/temp -name "application.properties.D*" -type f -user provco -mtime +180 -exec rm -v {} \; | tee -a ${LOG}
    fi
}

# Function to copy configuration
copy_configuration() {
    log_message "Configuration copy"
    cp -rpv ${PACKAGE_DIR}/Configuration/dist/ /provco/ProvisionController/apps/config/. | tee -a ${LOG}
    handle_error ${PIPESTATUS[0]}
}

# Function to backup application.properties to temp
backup_to_temp() {
    if [ -d /provco/temp ]; then
        cp -pv /provco/ProvisionController/apps/config/application.properties /provco/temp/application.properties.D$(date +%Y%m%d_%H%M).PST | tee -a ${LOG}
        handle_error ${PIPESTATUS[0]}
    fi
}

# Function to comment out MQ SSL Connection info
comment_mq_ssl() {
    if [[ "${KEEP_REGION}" == "AD" || "${KEEP_REGION}" == "AE" || "${KEEP_REGION}" == "AF" || "${KEEP_REGION}" == "AH" ]]; then
        log_message "Region is ${KEEP_REGION}, commenting out the MQ SSL Connection info from the application.properties"
        cp -v /provco/ProvisionController/apps/config/application.properties /provco/ProvisionController/apps/config/application.properties.orig.mq
        sed -i 's/MQ.SSL.CLIENT.CIPHER-/#MQ.SSL.CLIENT.CIPHER-/g; s/MQ.SSL.CLIENT.CHANNEL=/#MQ.SSL.CLIENT.CHANNEL-/g' /provco/ProvisionController/apps/config/application.properties
    fi
}

# Function to copy bind.configuration
copy_bind_configuration() {
    log_message "bind.configuration copy"
    cp -p ${APPVER_DIR}/bind.configuration /provco/deployments/. | tee -a ${LOG}
    handle_error ${PIPESTATUS[0]}
}

# Function to copy scripts
copy_scripts() {
    log_message "Scripts copy"
    cp -pv ${PACKAGE_DIR}/scripts/* /provco/deployments/scripts/. | tee -a ${LOG}
    handle_error ${PIPESTATUS[0]}
}

# Function to run LDAP and IASA scripts
run_ldap_iasa_scripts() {
    if [ "${BIND_REGION}" = "PD" ]; then
        log_message "Running the LDAP and IASA scripts ..."
        /provco/scripts/ldap_script.sh | tee -a ${LOG}
        handle_error ${PIPESTATUS[0]}
        /provco/scripts/IASA_DB_script.sh | tee -a ${LOG}
        handle_error ${PIPESTATUS[0]}
    fi
}

# Set variables
LOG=/provco/stage/logs/${app_name}.$(date +%Y%m%d_%H%M%S).log
PACKAGE_DIR="/path/to/package_dir"
APPVER_DIR="/path/to/appver_dir"
KEEP_REGION="AD"
BIND_REGION="PD"

# Execute functions
backup_application_properties
copy_configuration
backup_to_temp
comment_mq_ssl
copy_bind_configuration
copy_scripts
run_ldap_iasa_scripts
