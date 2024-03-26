#!/bin/bash
currentpath=$(pwd)
errorlog=${currentpath}/error.log

input=${currentpath}/input.properties
SOURCE_USER=$(grep -e "SOURCE_USER" ${input} | awk -F = '{ print $2 }' | sed 's/ //')
SOURCE_HOST=$(grep -e "SOURCE_HOST" ${input} | awk -F = '{ print $2 }' | sed 's/ //')
SOURCE_FILE=$(grep -e "SOURCE_FILE" ${input} | awk -F = '{ print $2 }' | sed 's/ //')
DEST_USER=$(grep -e "DEST_USER" ${input} | awk -F = '{ print $2 }' | sed 's/ //')
DEST_HOST=$(grep -e "DEST_HOST" ${input} | awk -F = '{ print $2 }' | sed 's/ //')
DEST_DIR=$(grep -e "DEST_DIR" ${input} | awk -F = '{ print $2 }' | sed 's/ //')
DEST_PASSWORD=$(grep -e "DEST_PASSWORD" ${input} | awk -F = '{ print $2 }' | sed 's/ //')

install() {
if which apt &>/dev/null; then
    sudo apt-get update -y &>> ${errorlog}
    sudo apt-get install sshpass -y &>> ${errorlog}
elif which yum &>/dev/null; then
    sudo yum update -y &>> ${errorlog}
    sudo yum install sshpass -y &>> ${errorlog}
else
    echo "unsupported package manager.. install sshpass to proceed.."
    exit 1
fi
}
if ! command -v sshpass &> /dev/null; then
    echo "sshpass package not found. Installing sshpass..." &>> ${errorlog}
    install
fi

sshpass -p "${DEST_PASSWORD}" scp -o StrictHostKeyChecking=no ${SOURCE_FILE} ${DEST_USER}@${DEST_HOST}:${DEST_DIR} &>> ${errorlog}
if [ $? -eq 0 ]; then
	if [ "$(cat ${errorlog} | wc -l)" == "0" ]; then
		rm -rf ${errorlog}
	fi
    echo "File copied successfully."
else
    echo "Failed to copy the file."
fi

