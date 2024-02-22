#!/bin/bash
apiname="GPS DATA Services"
API_URL="http://172.11.11.12:6001/api/gpsdataservice/health"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq first."
    exit 1
fi

# LINE Notify API
API_ENDPOINT="https://notify-api.line.me/api/notify"
# line token
# line Token : h9yS2M1DopD6qYGmVsbFMSuqvSpVidGvQU72jKApjtz /// testing
# line Token : nehUfnZrzHkYwr9foDnaiXXuSHRWNqqB2wvi2SG7yTa /// product
token="nehUfnZrzHkYwr9foDnaiXXuSHRWNqqB2wvi2SG7yTa"

#################################################################
# time
current_time="$(date +'%s')"
starttime="$(date -d '09:00' +'%s')"
endtime="$(date -d '09:05' +'%s')"

stampcheckS="$(date +'%s')"
stampcheckE="$(date +'%s')"

################################################################
## response api
response_code=$(curl -s -o /dev/null -w "%{http_code}" $API_URL)
echo "$response_code"
if [[ $response_code -eq 200 ]]; then

    echo "Request successful"
    echo "start service"

    #result="$(curl $API_URL)"
    json_data="$(curl $API_URL)"

else
    #echo "Request failed with response code $response_code"
    responsebody="[$apiname] Error: API Request failed with response code $response_code = $API_URL"
    curl -X POST -H "Authorization: Bearer $token" -F "message=$responsebody" $API_ENDPOINT
   # rm -rf status.json
   exit 1
fi

################################################################

# Read the JSON file into a variable
#json_data=$(cat "$json_file")
json_data="$(curl $API_URL)"
# Extract specific information using jq
all_status_check=$(echo "$json_data" | jq -r '.status')
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

last_status_check="last_status_check.txt"
timestampfile=$(grep -oE '[0-9]+' "$last_status_check" | tr -d '\n')
timestamp=$((stampcheckE-timestampfile))
#echo "$timestamp"

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

body1="$apiname"'
    All Stats : '"$all_status"'
    Database Status : '"$database_status"'
    Description : '"$database_description"'
    Down Time: '"$timestamp"' seconds'

body2="$apiname"'
    All Stats : '"$all_status"'
    Last GPS Status :'"$last_gps_staus"'
    Description : '"$last_gps_description"'
    Down Time: '"$timestamp"' seconds'

body3="$apiname"'
    All Stats : '"$all_status"'
    RabbitMQ Status :'"$rabbitmq_status"'
    Description : '"$rabbitmq_description"'
    Down Time: '"$timestamp"' seconds'

body4="$apiname"'
    All Stats : '"$all_status"'
    Redis Status :'"$redis_status"'
    Description : '"$redis_description"'
    Down Time: '"$timestamp"' seconds'


if [ ! -f "$last_status_check" ]; then

    echo "File $last_status_check not found. Cann't check last status!! || EXIT ERROR!!"
    echo "status : '$all_status_check' | time : '$stampcheckS' " > last_status_check.txt
    exit 1

else

    if grep -q "Unhealthy" "$last_status_check" ; then

        echo "Unhealthy"
        echo "status : '$all_status_check' | time[munit] : '$stampcheckS' " > last_status_check.txt
        exit 1

    elif grep -q "Healthy" "$last_status_check" ; then

        echo "healthy"
        echo "status : '$all_status_check' | time[munit] : '$stampcheckS' " > last_status_check.txt

      # เวลาตอนี้      >= 17:00 และ เวลาตอนี้ <= 18:00
        if [ "$current_time" -ge "$starttime" -a "$current_time" -lt "$endtime" ]; then

            curl -X POST -H "Authorization: Bearer $token" -F "message=$body" $API_ENDPOINT


        elif [ "$all_success" = "$check_status" ] ; then

            if [ "$database_success" = "$check_status" ] && [ "$last_gps_success" = "$check_status" ] && [ "$rabbitMQ_success" = "$check_status" ] && [ "$redis_success" = "$check_status" ] ;then

                curl -X POST -H "Authorization: Bearer $token" -F "message=$body" $API_ENDPOINT

            elif [ "$database_success" = "$check_status" ] ; then

                curl -X POST -H "Authorization: Bearer $token" -F "message=$body1" $API_ENDPOINT

            elif [ "$last_gps_success" = "$check_status" ] ; then

                curl -X POST -H "Authorization: Bearer $token" -F "message=$body2" $API_ENDPOINT

            elif [ "$rabbitMQ_success" = "$check_status" ] ; then

                curl -X POST -H "Authorization: Bearer $token" -F "message=$body3" $API_ENDPOINT

            elif [ "$redis_success" = "$check_status" ] ; then

                curl -X POST -H "Authorization: Bearer $token" -F "message=$body4" $API_ENDPOINT

            else

                # Send the notification using curl
                curl -X POST -H "Authorization: Bearer $token" -F "message=$body" $API_ENDPOINT

            fi

        else

            echo "Status OK"

        fi
    fi

fi
#rm -rf status.json