#/bin/bash

# Author: Yevgeniy Goncharov aka xck, http://sys-admin.kz
# Forum thread http://forum.sys-admin.kz/index.php?topic=4458.0
#
# Problem - Local (kz) registrant restrict show info from domains in KZ zones and allow show info only local hoster companies.
# This script parse local KZ hoster page and show KZ domain info
#
# Usage: ./script.sh domain.kz
# None: Your also can use txt list file

# Variables
# --------------------------------------------------
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# Determine script location
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

list=`cat $SCRIPT_PATH/list.txt`

_hosterLink="https://www.ps.kz/domains/whois?domain="
_domain=$1

# Checking process
# --------------------------------------------------
function checkName(){

	status=$(curl -s --head -w %{http_code} $_hosterLink -o /dev/null)

	if [[ $status -eq 200 ]]; then
		# Get expiration status
		# check=`curl -s $_hosterLink$1 | grep note-danger | sed 's/<\/\?[^>]\+>//g' | sed -r 's/&nbsp;/ /g' | awk '{$2=$2};1'` &>/dev/null

		check=`curl -H 'Cache-Control: no-cache' -s $_hosterLink$1 | grep "занят"` &>/dev/null

	# Check empty string -z or not -n
	if [[ -z $check ]]; then

		echo "$1 - Домен свободен"

	else

			# curl -s $_hosterLink$1 | sed -n '/<table/,/<\/table>/p' | sed 's/<\/\?[^>]\+>//g' | sed -r 's/&nbsp;/ /g; s/ \+//g; /^\s*$/d; ' | awk '{$2=$2};1' > t.log
			if [[ $1 == *".kz" ]]; then

				left=`curl -H 'Cache-Control: no-cache' -s $_hosterLink$1 | grep text-danger | sed 's/<\/\?[^>]\+>//g' | sed -r 's/&nbsp;/ /g' | awk '{$2=$2};1'` &>/dev/null
				echo $left

			else

				echo "$1 - Домен занят"

			fi
	fi

else

	echo "Сайт хостера $_hosterLink недоступен!"

fi

}

# Check run arguments
# ---------------------------------------------------\
#if [ $# -ne 1 ]; then

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Необходимо указать имя домена, пример: ./domain-kz-check.sh domain.local"
	exit 1
else
	if [[ $_domain == *".txt"* ]]; then

		for i in $list; do

			# echo $i
			checkName $i

		done

	else

		checkName $_domain

	fi
fi


# обе команды делаюь одно и то же - убираем теги b, убираем все остальные теги, убираем пустые строки, убираем двойные пробелы
# cat test.html | sed 's|</b>|-|g' | sed 's|<[^>]*>||g' | awk 'NF' | awk '{$2=$2};1'
# cat test.html | sed 's|</b>|-|g; s|<[^>]*>||g; /^\s*$/d; s/ \+//g'
