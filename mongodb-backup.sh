#!/usr/bin/env bash
# Amit Thakkar <vigildbest@gmail.com>

HOST="127.0.0.1"
PORT="27017"
USERNAME=""
PASSWORD=""
TODAY=`date "+%Y-%m-%d"`
FILE_NAME="DATE_${TODAY}"
BACKUP_PATH="."

# Auto detect unix bin paths, enter these manually if script fails to auto detect
MONGO_DUMP_BIN_PATH="$(which mongodump)"
TAR_BIN_PATH="$(which tar)"

# Create BACKUP_PATH directory if it does not exist
[ ! -d ${BACKUP_PATH} ] && mkdir -p ${BACKUP_PATH} || :

# Ensure directory exists before dumping to it
if [ -d "${BACKUP_PATH}" ]; then
	cd ${BACKUP_PATH}
	TMP_BACKUP_DIR="mongodb-${TODAY}"
	echo; echo "=> Backing up Mongo Server: ${HOST}:${PORT}"; echo -n '   ';
	if [ "$USERNAME" != "" -a "$PASSWORD" != "" ]; then
		${MONGO_DUMP_BIN_PATH} --host ${HOST}:${PORT} -u ${USERNAME} -p ${PASSWORD} --out ${TMP_BACKUP_DIR}
	else
		${MONGO_DUMP_BIN_PATH} --host ${HOST}:${PORT} --out ${TMP_BACKUP_DIR}
	fi

	if [ -d "${TMP_BACKUP_DIR}" ]; then
		${TAR_BIN_PATH} -czf ${FILE_NAME}.tar.gz ${TMP_BACKUP_DIR}
		if [ -f "${FILE_NAME}.tar.gz" ]; then
			echo "=> Success: `du -sh ${FILE_NAME}.tar.gz`"; echo;
			if [ -d "${BACKUP_PATH}/${TMP_BACKUP_DIR}" ]; then
				rm -rf "${BACKUP_PATH}/${TMP_BACKUP_DIR}"
			fi
		else
			 echo "!!!=> Failed to create backup file: ${BACKUP_PATH}/${FILE_NAME}.tar.gz"; echo;
		fi
	else
		echo; echo "!!!=> Failed to create ${TMP_BACKUP_DIR} directory"; echo;
	fi
else
	echo "!!!=> Failed to create backup path: ${BACKUP_PATH}"
fi