#!/bin/bash

DEFAULT_CONTINENT=asia
DEFAULT_COUNTRY=iran

##ask users what they want
function measure_distance() {
        curl -s  "http://localhost:$port/route/v1/driving/$longitude_source,$latitude_source;$longitude_destination,$latitude_destination" | jq .routes[].distance
                 }

function measure_duration() {
        curl -s  "http://localhost:$port/route/v1/driving/$longitude_source,$latitude_source;$longitude_destination,$latitude_destination" | jq .routes[].duration
                 }
function get_geo_addrese(){
        read -p $'source longitude: ' longitude_source
        read -p $'source latitude: ' latitude_source
        read -p $'destination longitude: ' longitude_destination
        read -p $'destination latitude: ' latitude_destination
                }
function print_result(){
        distance=`measure_distance`
        echo "your trip is about $distance meters" |tee -a output.txt
        duration=`measure_duration`
        echo "your trip takes long about `seconds_to_hours $duration`" |tee -a output.txt
}

function seconds_to_hours() {

        round() {
                  printf "%.0f" "${1}"
        }

        secs=`round $1`

        let 'h=secs/3600'
        let 'm=(secs/60 ) % 60'
        let 's=secs%60'
        printf "%02d:%02d:%02d\n" $h $m $s
}


clear
rm output.txt 2>/dev/null
echo "Please Provide your Continent/Country (default: $DEFAULT_CONTINENT /$DEFAULT_COUNTRY )"

read -p $'Continent: ' CONTINENT
read -p $'Country: ' COUNTRY

if [[ -z $CONTINENT || -z $COUNTRY  ]]; then 
        COUNTRY=$DEFAULT_COUNTRY
        CONTINENT=$DEFAULT_CONTINENT
fi

export COUNTRY=$COUNTRY
export CONTINENT=$CONTINENT

echo Default Map Region : $CONTINENT/$COUNTRY

##build docker image and Run 
docker-compose -f `dirname $0`/docker-compose.yml up -d 


read -p $'how you want to trip? \na)car \nb)bicycle \nc)foot \n' profile

case "$profile" in
"a")

        get_geo_addrese
        port=5000
        print_result

    ;;
"b")
        get_geo_addrese
        port=5001
        print_result
    ;;
"c")
        get_geo_addrese
        port=5002
        print_result
    ;;
*)
    echo "Wrong Answer!!!"
    ;;
esac
