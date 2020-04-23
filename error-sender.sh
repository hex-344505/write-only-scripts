#Script that should be run every minute
#It get messages from logfile and send it to workplace chat but only 50 last messages in a minute
# Put it in crontab with * * * * * and have fun

#!/bin/bash
ACCESS_TOKEN="workplace access key here"
CHAT_ID="workplace chat ID"
LOG='/var/log/nginx/error.log'
TMP='/tmp/nginx-errors-tmp'
TIME_STAMP="`date +'%Y/%m/%d %R' --date='1 minute ago'`"

tail -n 50 $LOG | grep "$TIME_STAMP" | sed -e /\"/s//\*/g > $TMP

send_message()
{
    curl -X POST \
         -H 'Content-Type: application/json' \
         -d '{ "recipient": { "thread_key": "'"$1"'" }, "message": { "text": "'"$2"'" } }' \
         https://graph.facebook.com/v2.10/me/messages?access_token="$3"
}

cat $TMP | while read line 
do
  send_message "$CHAT_ID" "$line" "$ACCESS_TOKEN"
done

rm $TMP
