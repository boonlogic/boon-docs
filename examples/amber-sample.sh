#!/usr/bin/env bash

# bash script to exercise Boon Logic Amber API

# adjust these as necessary
username='your-username'
password='your-password'

url=https://amber.boonlogic.com/v1

read -r -d '' authData <<EOF
{
  "username": ${username},
  "password": ${password}
}
EOF

#
# run the oauth2 authentication call and store the authToken
#
idToken=`curl --silent \
    --request POST \
    --url ${url}/oauth2 \
    --data "$authData" \
    --header "Content-Type: application/json" \
     | jq -r .idToken`

echo $idToken


#
# Create a sensor
#
sensorId=`curl --silent \
  --request POST \
  --url ${url}/sensor \
  --header "Authorization: Bearer ${idToken}" \
  --header "Content-Type: application/json" \
  --data '{"label": "some-random-label"}' | jq -r .sensorId`

echo ${sensorId}


#
# Update the sensor label
#
curl --silent \
  --request PUT \
  --url ${url}/sensor \
  --header "Authorization: Bearer ${idToken}" \
  --header "Content-Type: application/json" \
  --header "sensorId: ${sensorId}" \
  --data '{"label": "motor_765_bay4"}' | jq .


#
# Configure the sensor
#
curl --silent \
  --request POST \
  --url ${url}/config \
  --header "Authorization: Bearer ${idToken}" \
  --header "Content-Type: application/json" \
  --header "sensorId: ${sensorId}" \
  --data '{"featureCount": 1, "streamingWindowSize": 25, "samplesToBuffer": 1000, "learningRateNumerator": 10, "learningRateDenominator": 10000, "learningMaxSamples": 1000000, "learningMaxClusters": 1000}' | jq .


#
# Get the sensor configuration
#
curl --silent \
  --request GET \
  --url ${url}/config \
  --header "Authorization: Bearer ${idToken}" \
  --header "Content-Type: application/json" \
  --header "sensorId: ${sensorId}" | jq .


#
# Stream data to the sensor
#
curl --silent \
  --request POST \
  --url ${url}/stream \
  --header "Authorization: Bearer ${idToken}" \
  --header "Content-Type: application/json" \
  --header "sensorId: ${sensorId}" \
  --data '{"data": "1,2,3,4,5,6,1,2,3,4,4"}' | jq .


#
# Get sensor information
#
curl --silent \
  --request GET \
  --url ${url}/sensor \
  --header "Authorization: Bearer ${idToken}" \
  --header "Content-Type: application/json" \
  --header "sensorId: ${sensorId}"  | jq .


#
# Get sensor status
#
curl --silent \
  --request GET \
  --url ${url}/status \
  --header "Authorization: Bearer ${idToken}" \
  --header "Content-Type: application/json" \
  --header "sensorId: ${sensorId}"  | jq .


#
# Delete the sensor
#
curl --silent \
  --request DELETE \
  --url ${url}/sensor \
  --header "Authorization: Bearer ${idToken}" \
  --header "Content-Type: application/json" \
  --header "sensorId: ${sensorId}" | jq .

