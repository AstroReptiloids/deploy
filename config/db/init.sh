#!/usr/bin/env bash
set -e

declare -a PGDBS=( $(printenv | sed -rn '/^PGDB_/s/=[^=]+//p' | sort) )
declare -a PGUSERS=( $(printenv | sed -rn '/^PGUSER_/s/=[^=]+//p' | sort) )
declare -a PGPASSWORDS=( $(printenv | sed -rn '/^PGPASSWORD_/s/=[^=]+//p' | sort) )

[ "${#PGDBS[@]}" != "${#PGUSER[@]}" ] && [ "${#PGDBS[@]}" != "${#PGPASSWORDS[@]}" ] && { 
    echo "Error in DB env variables count"
    exit 1
}

for ((i=0; i<${#PGDBS[@]}; ++i)); do
    _db=$(printenv "${PGDBS[$i]}")
    _user=$(printenv "${PGUSERS[$i]}")
    _password=$(printenv "${PGPASSWORDS[$i]}")
    
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER ${_user};
	ALTER USER ${_user} WITH PASSWORD '${_password}';
        CREATE DATABASE ${_db};
        GRANT ALL PRIVILEGES ON DATABASE ${_db} TO ${_user};
EOSQL

done
