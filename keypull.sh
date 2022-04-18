#!/bin/sh

read -p "Enter Github Username: " username
curl https://github.com/$username.keys > ~/.ssh/authorized_keys

#crontab -l > ./crontab.txt
#echo "### Crontask for Key Puller  ###" >> ./crontab.txt
#echo "*/30 * * * curl https://github.com/$username.keys > ~/.ssh/authorized_keys" >> ./crontab.txt
#crontab `pwd`/crontab.txt
#rm `pwd`/crontab.txt

