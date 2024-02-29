#!/bin/bash

send_line_notify() {

    curl -X POST -H "Authorization:Bearer $LINE_NOTIFY_TOKEN" -F "message=$body" -F "imageFile=@$IMAGE_PATH" $LINE_API
}

# Function to copy and backup file
copy_and_backup_file() {
    local path_dockercontainer="$1"
    local data_from_file1="$2"
    local path_backup="$3"
    local result="$4"
    local filenamelog="$5"
    local status_file="$6"  # File to store the status


    # Build the source and destination paths
    source_path="${path_dockercontainer}/${data_from_file1}/${data_from_file1}-json.log"
    destination_path="${path_backup}/${result}/${filenamelog}"

    # Copy and backup file
    cp "${source_path}" "${destination_path}"

    # Check if the copy was successful
    if [ $? -eq 0 ]; then
        status="success"
    else
        status="failed."
    fi

        # Output the status to the status file
    echo "${status}" > "${status_file}"
}


# Create file name.txt
ls /var/lib/docker/containers --> foldername.txt
docker ps -a --no-trunc  --format "{{.ID}} | {{.Names}}"  > filename.txt

#path_servicesname="/home/noppon/tool/tool/clear_log_backend/service name"
path_dockercontainer="/var/lib/docker/containers"
path_backup="/data/containers_logs"

servername=$(hostname)
echo "$servername"
netadaptor="ens160"
ipserver=$(ifconfig $netadaptor | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
echo "$ipserver"

# Line Notify token
#LINE_NOTIFY_TOKEN="4Y2RSxVi1uVtet6DV6pD9kKqnTXrs8SLDc8vLGuATqp" #test
LINE_NOTIFY_TOKEN="h9yS2M1DopD6qYGmVsbFMSuqvSpVidGvQU72jKApjtz" #product
LINE_API="https://notify-api.line.me/api/notify"
# # Function to send Line Notify message
IMAGE_PATH="output_image.png"

namefile=$(date +'%d-%m-%Y_%H%M%S')
filenamelog="$namefile.txt"

file=filename.txt
cutfile=cutname.txt
status_file=status.txt

Cut=$(cat $file | awk -F'.' '{print $1}')
echo "$Cut" > $cutfile



while IFS= read -r line; do
    # อ่านข้อมูลที่ตำแหน่งที่ 1 จากไฟล์ 1
    data_from_file1=$line

    # หากตำแหน่งนั้นมีข้อมูลในไฟล์ 2
    if grep -q "$data_from_file1" $cutfile; then

        # ดึงข้อมูลที่ตำแหน่งนั้นหลังจาก |
        result=$(grep "$data_from_file1" $cutfile | cut -d '|' -f2 | awk '{$1=$1;print}')
        # แสดงผลลัพธ์
        echo $result >> linenoti.txt
        echo $result

        #mkdir -p servicename/$result

        if [ -d "$path_backup/$result" ]; then
                
                #echo 'Have Diractory...|| Coppy file...'

                #cp $path_dockercontainer $data_from_file1-json.log  $path_backup $result/$filename

                copy_and_backup_file "${path_dockercontainer}" "${data_from_file1}" "${path_backup}" "${result}" "${filenamelog}" "${status_file}"

               # truncate -s 0 /var/lib/docker/containers/$data_from_file1/$data_from_file1-json.log 

        else

                #echo "$line"
                #echo 'Have not Diractory...|| Now ceater diractory...|| Coppy file...'

                mkdir -p "$path_backup/$result" && chmod 775 "$path_backup/$result"

                copy_and_backup_file "${path_dockercontainer}" "${data_from_file1}" "${path_backup}" "${result}" "${filenamelog}" "${status_file}"

                #truncate -s 0 /var/lib/docker/containers/$data_from_file1/$data_from_file1-json.log 

        fi


    else
        echo "No match found for $data_from_file1 in file2.txt"
    fi

done < foldername.txt

# Define file path
services_file="linenoti.txt"
output_file="output_table.txt"

# Read the status from the file and use it as needed
status=$(cat "${status_file}")
echo "Status : ${status}"

# Read services from the file into an array
services=()
while IFS= read -r line; do
    services+=("$line")
done < "$services_file"

# Calculate the maximum length of a service name
max_length=0
for service in "${services[@]}"; do
    length=${#service}
    if ((length > max_length)); then
        max_length=$length
    fi
done

# Create the table
printf "| %-${max_length}s | %-7s |\n" "Service" "Status" > "$output_file"
printf "| %-${max_length}s | %-7s |\n" "--------" "-------">> "$output_file"

# Add services to the table
for service in "${services[@]}"; do
    printf "| %-${max_length}s | %-7s |\n" "$service" "$status" >> "$output_file"
done
echo "Table written to $output_file"


input_file="output_table.txt"
output_image="output_image.png"

python3 Text_to_Image.py "$input_file" "$output_image"

echo "Image created: $output_image"

body="Backup Dataloger   
IP : "$ipserver"
Hostname : "$servername"
Status : "$status"
message : Services Docker Containners name
"

send_line_notify

rm linenoti.txt