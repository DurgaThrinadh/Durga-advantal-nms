#!/bin/bash
# =====================================================
# Advantal NMS - Zabbix Server Entrypoint
# Configures zabbix_server.conf from environment variables
# (mirrors official zabbix-docker entrypoint behavior)
# =====================================================

set -e

ZABBIX_CONF_DIR="/etc/zabbix"
ZABBIX_CONF_FILE="${ZABBIX_CONF_DIR}/zabbix_server.conf"
ZABBIX_USER_HOME_DIR="/var/lib/zabbix"

# Function to update config parameter
update_config_var() {
    local config_path=$1
    local var_name=$2
    local var_value=$3

    if [ -n "$var_value" ]; then
        # Remove existing entry and add new one
        sed -i "/^${var_name}=/d" "$config_path"
        echo "${var_name}=${var_value}" >> "$config_path"
    fi
}

# Wait for database to be ready
wait_for_db() {
    local max_retries=30
    local retry=0
    
    echo "** Waiting for database server ${DB_SERVER_HOST}:${DB_SERVER_PORT:-5432}..."
    
    while [ $retry -lt $max_retries ]; do
        if pg_isready -h "${DB_SERVER_HOST}" -p "${DB_SERVER_PORT:-5432}" -U "${POSTGRES_USER}" -q 2>/dev/null; then
            echo "** Database is ready"
            return 0
        fi
        retry=$((retry + 1))
        sleep 2
    done
    
    echo "** WARNING: Database may not be ready, proceeding anyway..."
    return 0
}

# Create database schema if needed
create_db_schema() {
    local schema_file="/usr/share/doc/zabbix-server-postgresql/create.sql.gz"
    
    if [ -f "$schema_file" ]; then
        # Check if schema already exists
        local table_count=$(psql -h "${DB_SERVER_HOST}" -p "${DB_SERVER_PORT:-5432}" \
            -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'" 2>/dev/null || echo "0")
        
        if [ "$table_count" -lt "5" ]; then
            echo "** Creating Zabbix database schema..."
            zcat "$schema_file" | psql -h "${DB_SERVER_HOST}" -p "${DB_SERVER_PORT:-5432}" \
                -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -q
            echo "** Database schema created successfully"
        else
            echo "** Database schema already exists (${table_count} tables found)"
        fi
    fi
}

# Configure server
echo "** Configuring Zabbix Server..."

# Database configuration
update_config_var "$ZABBIX_CONF_FILE" "DBHost" "${DB_SERVER_HOST:-localhost}"
update_config_var "$ZABBIX_CONF_FILE" "DBName" "${POSTGRES_DB:-zabbix}"
update_config_var "$ZABBIX_CONF_FILE" "DBUser" "${POSTGRES_USER:-zabbix}"
update_config_var "$ZABBIX_CONF_FILE" "DBPassword" "${POSTGRES_PASSWORD}"
update_config_var "$ZABBIX_CONF_FILE" "DBPort" "${DB_SERVER_PORT:-5432}"

# Paths
update_config_var "$ZABBIX_CONF_FILE" "LogFile" "/var/log/zabbix/zabbix_server.log"
update_config_var "$ZABBIX_CONF_FILE" "PidFile" "/var/run/zabbix/zabbix_server.pid"
update_config_var "$ZABBIX_CONF_FILE" "SocketDir" "/var/run/zabbix"
update_config_var "$ZABBIX_CONF_FILE" "AlertScriptsPath" "/usr/lib/zabbix/alertscripts"
update_config_var "$ZABBIX_CONF_FILE" "ExternalScripts" "/usr/lib/zabbix/externalscripts"
update_config_var "$ZABBIX_CONF_FILE" "FpingLocation" "/usr/bin/fping"
update_config_var "$ZABBIX_CONF_FILE" "SNMPTrapperFile" "${ZABBIX_USER_HOME_DIR}/snmptraps/snmptraps.log"
update_config_var "$ZABBIX_CONF_FILE" "SSLCertLocation" "${ZABBIX_USER_HOME_DIR}/ssl/certs"
update_config_var "$ZABBIX_CONF_FILE" "SSLKeyLocation" "${ZABBIX_USER_HOME_DIR}/ssl/keys"
update_config_var "$ZABBIX_CONF_FILE" "SSLCALocation" "${ZABBIX_USER_HOME_DIR}/ssl/ssl_ca"

# Optional env vars
[ -n "${ZBX_LISTENPORT}" ] && update_config_var "$ZABBIX_CONF_FILE" "ListenPort" "${ZBX_LISTENPORT}"
[ -n "${ZBX_STARTPOLLERS}" ] && update_config_var "$ZABBIX_CONF_FILE" "StartPollers" "${ZBX_STARTPOLLERS}"
[ -n "${ZBX_STARTPOLLERSUNREACHABLE}" ] && update_config_var "$ZABBIX_CONF_FILE" "StartPollersUnreachable" "${ZBX_STARTPOLLERSUNREACHABLE}"
[ -n "${ZBX_STARTTRAPPERS}" ] && update_config_var "$ZABBIX_CONF_FILE" "StartTrappers" "${ZBX_STARTTRAPPERS}"
[ -n "${ZBX_STARTPINGERS}" ] && update_config_var "$ZABBIX_CONF_FILE" "StartPingers" "${ZBX_STARTPINGERS}"
[ -n "${ZBX_STARTDISCOVERERS}" ] && update_config_var "$ZABBIX_CONF_FILE" "StartDiscoverers" "${ZBX_STARTDISCOVERERS}"
[ -n "${ZBX_CACHESIZE}" ] && update_config_var "$ZABBIX_CONF_FILE" "CacheSize" "${ZBX_CACHESIZE}"
[ -n "${ZBX_HISTORYCACHESIZE}" ] && update_config_var "$ZABBIX_CONF_FILE" "HistoryCacheSize" "${ZBX_HISTORYCACHESIZE}"
[ -n "${ZBX_TIMEOUT}" ] && update_config_var "$ZABBIX_CONF_FILE" "Timeout" "${ZBX_TIMEOUT}"
[ -n "${ZBX_LOGSLOWQUERIES}" ] && update_config_var "$ZABBIX_CONF_FILE" "LogSlowQueries" "${ZBX_LOGSLOWQUERIES}"

# Set PGPASSWORD for psql commands
export PGPASSWORD="${POSTGRES_PASSWORD}"

# Wait for DB and initialize schema
wait_for_db
create_db_schema

echo "** Starting Zabbix Server..."
echo "** Zabbix Server version: $(cat /usr/sbin/zabbix_server --version 2>/dev/null | head -1 || echo 'unknown')"

# Execute the main command
exec "$@"
