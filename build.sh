#!/bin/bash
#
# Description:
#    This script is intended to place project files appropriately
#    for the execution of usermgmt.sh and enablement of SSH access 
#    for members of the defined IAM group.
#    The IAM Group name must be provided with the -G parameter.
#    An instance role is assumed to already be attached to the AWS 
#    instance to allow execution of aws cli commands in usermgmt.sh 
#    from the instance.
#
#################################################################
__ScriptName="build.sh"

log()
{
    logger -i -t "${__ScriptName}" -s -- "$1" 2> /dev/console
    echo "$1"
}  # ----------  end of function log  ----------


die()
{
    [ -n "$1" ] && log "$1"
    log "${__ScriptName} script failed"'!'
    exit 1
}  # ----------  end of function die  ----------

usage()
{
    cat << EOT
  Usage:  ${__ScriptName} [options]

  Note:
  If 

  Options:
  -h  Display this message.
  -G  The IAM group name from which to generate local users.
EOT
}  # ----------  end of function usage  ----------

# Parse command-line parameters
while getopts :hG: opt
do
    case "${opt}" in
        h)
            usage
            exit 0
            ;;
        G)
            GROUP_NAME="${OPTARG}"
            ;;
        \?)
            usage
            echo "ERROR: unknown parameter \"$OPTARG\""
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# Validate parameters
if [ -z "${GROUP_NAME}" ]
then
    die "GROUP_NAME was not provided"
fi

# Begin main script

chmod 644 usermgmt
chown root usermgmt
chgrp root usermgmt
cp usermgmt /etc/cron.d/
log "cron file copied by ${__ScriptName}"
chmod 755 usermgmt.sh
chown root usermgmt.sh
chgrp root usermgmt.sh
cp usermgmt.sh /usr/local/bin/
log "usermgmt script copied by ${__ScriptName}"
chmod 755 authorized_keys_command.sh 
chown root authorized_keys_command.sh
chgrp root authorized_keys_command.sh
cp authorized_keys_command.sh /usr/local/bin/
log "authorized_keys_command script copied by ${__ScriptName}"
sed -i 's:#AuthorizedKeysCommand none:AuthorizedKeysCommand /usr/local/bin/authorized_keys_command.sh:g' /etc/ssh/sshd_config
sed -i 's:#AuthorizedKeysCommandUser nobody:AuthorizedKeysCommandUser nobody:g' /etc/ssh/sshd_config	
log "sshd_config modified by ${__ScriptName}"
echo "${GROUP_NAME}" > /usr/local/bin/groupname
log "groupname file created by ${__ScriptName} for cron use"

