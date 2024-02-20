#!/bin/bash

apiname="GPS DATA Services"

# LINE Notify API endpoint
API_ENDPOINT="https://notify-api.line.me/api/notify"

# line token
token="token"

result="$(curl 'APIURL' -o status.json)"
#echo $result --> test.json

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq first."
    exit 1
fi

# Specify the JSON file
json_file="status.json"

# Check if the file exists
if [ ! -f "$json_file" ]; then
    echo "File $json_file not found."
    exit 1
fi

# Read the JSON file into a variable
json_data=$(cat "$json_file")

# Extract specific information using jq
all_status=$(echo "$json_data" | jq -r '.status')
database_status=$(echo "$json_data" | jq -r '.results.database.status')
database_description=$(echo "$json_data" | jq -r '.results.database.description')
last_gps_staus=$(echo "$json_data" | jq -r '.results.lastGPS.status')
last_gps_description=$(echo "$json_data" | jq -r '.results.lastGPS.description')
rabbitmq_status=$(echo "$json_data" | jq -r '.results.rabbitMQ.status')
rabbitmq_description=$(echo "$json_data" | jq -r '.results.rabbitMQ.description')
redis_status=$(echo "$json_data" | jq -r '.results.redis.status')
redis_description=$(echo "$json_data" | jq -r '.results.redis.description')

# for check if else Success true or false
checktrue="true"
checkfalse="false"
check_status="false"
all_success=$(echo "$json_data" | jq -r '.success')
database_success=$(echo "$json_data" | jq -r '.results.database.Success')
last_gps_success=$(echo "$json_data" | jq -r '.results.lastGPS.Success')
rabbitMQ_success=$(echo "$json_data" | jq -r '.results.rabbitMQ.Success')
redis_success=$(echo "$json_data" | jq -r '.results.redis.Success')

#test echo success
# echo "true : $checktrue"
# echo "false : $checkfalse"
# echo "All Status : $all_success"
# echo "Database Status: $database_success"
# echo "Last GPS Status: $last_gps_success"
# echo "RabbitMQ Status: $rabbitMQ_success"
# echo "Redis Status: $redis_success"
# if  A = B --> A  | eles B


# Print the extracted information
# echo "All Status : $all_status"
# echo "Database Status: $database_status"
# echo "Database Description: $database_description"
# echo "Last GPS Status: $last_gps_staus"
# echo "Last GPS Description: $last_gps_description"
# echo "RabbitMQ Status: $rabbitmq_status"
# echo "RabbitMQ Description: $rabbitmq_description"
# echo "Redis Status: $redis_status"
# echo "Redis Description: $redis_description"

# body line from json file

body="$apiname"'
    All Stats : '"$all_status"'
    Database Status : '"$database_status"'
    Description : '"$database_description"'
    Last GPS Status :'"$last_gps_staus"'
    Description : '"$last_gps_description"'
    RabbitMQ Status :'"$rabbitmq_status"'
    Description : '"$rabbitmq_description"'
    Redis Status :'"$redis_status"'
    Description : '"$redis_description"''

#echo "'$body'" # test

current_time="$(date +'%s')"
echo "Current time: $current_time"
starttime="$(date -d '09:00' +'%s')"
endtime="$(date -d '09:05' +'%s')"
echo "starttime: $starttime"
echo "endtime: $endtime"
# Send to line notify

      # เวลาตอนี้      >= 17:00 และ เวลาตอนี้ <= 18:00
if [ "$current_time" -ge "$starttime" -a "$current_time" -lt "$endtime" ]; then

curl -X POST -H "Authorization: Bearer $token" -F "message=$body" $API_ENDPOINT

elif [ "$all_success" = "$check_status" ] || [ "$database_success" = "$check_status" ] || [ "$last_gps_success" = "$check_status" ] || [ "$rabbitMQ_success" = "$check_status" ] || [ "$redis_success" = "$check_status" ] ;then

# Send the notification using curl
curl -X POST -H "Authorization: Bearer $token" -F "message=$body" $API_ENDPOINT

else
    echo "Status OK"
 fi