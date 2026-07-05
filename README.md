# Platform Automation Scripts

A collection of shell, Python (Jython/WLST), and Ansible tooling for infrastructure and application
operations — data synchronization, service health monitoring with auto-remediation, and multi-region
application deployment.

> Hostnames, internal paths, artifact repository URLs, and contact details in these scripts have been
> replaced with generic placeholders (`*.example.internal`, `/opt/appstage/...`, `your-email@example.com`).
> Substitute your own environment values before use.

## Contents

| File | Purpose |
|---|---|
| `Rsync.sh`, `Rsync_shell.sh`, `New_shell_rsync.sh`, `notify_rynsc.sh`, `rynsc.yml`, `rysnc_time.yml` | Cross-host data sync via rsync, with exclusion rules, logging, and email notification on success/failure |
| `shell_service_restart.sh`, `Updated_with_log.sh`, `sample_infra.sh`, `testing_log.sh` | Log-pattern monitoring for known service failure signatures, with automatic restart and alerting |
| `Ansible-playbook.yml`, `modified_anisble_playbook.yml`, `ansible_vars.yml` | Multi-region application deployment playbook — package sync, config rollout, version tracking, and retention cleanup |
| `new_shell_deploy.sh`, `New_simplfied_shell_script.sh`, `simplified_deploy.sh` | Deployment shell scripts for the same application, in shell rather than Ansible |
| `Jms_clearing.py` | WLST (Jython) utility to walk WebLogic JMS servers and clear stuck queue messages |
| `SSLUtils.java`, `weblogic_test.sh`, `alerts.sh`, `example.txt` | Supporting utilities |

## Requirements

- Bash 4+
- `rsync`, `mailx` (or equivalent MTA) for notification scripts
- Ansible 2.9+ for the playbooks
- WebLogic Server with WLST for `Jms_clearing.py`
