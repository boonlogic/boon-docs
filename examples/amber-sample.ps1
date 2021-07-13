# Powershell script to exercise Boon Logic Amber API

# adjust these as necessary
$username="your-username"
$password="your-password"

$url="https://amber.boonlogic.com/v1"


#
# run the oauth2 authentication call and store authToken
#
$Params = @{
 "URI"     = "$url/oauth2"
 "Method"  = 'POST'
 "Headers" = @{
   "Content-Type"  = 'application/json'
 }
 "Body"    = '{ "username": "' + $username + '", "password": "' + $password + '" }'
}
$authToken = (Invoke-RestMethod @Params).idToken


#
# Create a sensor
#
$Params = @{
 "URI"     = "$url/sensor"
 "Method"  = 'POST'
 "Headers" = @{
   "Content-Type"  = 'application/json'
   "Authorization" = "Bearer $authToken"
   "Body" = '{"label": "some-random-label"}'
 }
}
$response = (Invoke-RestMethod @Params)

echo $response | ConvertTo-Json

# save off sensorId
$sensorId = $response.sensorId


#
# Update the sensor label
#
$Params = @{
 "URI"     = "$url/sensor"
 "Method"  = 'PUT'
 "Headers" = @{
   "Content-Type"  = 'application/json'
   "Authorization" = "Bearer $authToken"
   "sensorId" = "$sensorId"
   "Body" = '{"label": "motor_765_bay4"}'
 }
}
$response = (Invoke-RestMethod @Params)

echo $response | ConvertTo-Json


#
# Configure the sensor
#
$Params = @{
 "URI"     = "$url/config"
 "Method"  = 'POST'
 "Headers" = @{
   "Content-Type"  = 'application/json'
   "Authorization" = "Bearer $authToken"
   "sensorId" = "$sensorId"
 }
 "Body" = '{"featureCount": 1, "streamingWindowSize": 25, "samplesToBuffer": 1000, "learningRateNumerator": 10, "learningRateDenominator": 10000, "learningMaxSamples": 1000000, "learningMaxClusters": 1000}'
}
$response = Invoke-RestMethod @Params

echo $response | ConvertTo-Json


#
# Get the sensor configuration
#
$Params = @{
 "URI"     = "$url/config"
 "Method"  = 'GET'
 "Headers" = @{
   "Content-Type"  = 'application/json'
   "Authorization" = "Bearer $authToken"
   "sensorId" = "$sensorId"
 }
}
$response = Invoke-RestMethod @Params

echo $response | ConvertTo-Json


#
# Stream data to the sensor
#
$Params = @{
 "URI"     = "$url/stream"
 "Method"  = 'POST'
 "Headers" = @{
   "Content-Type"  = 'application/json'
   "Authorization" = "Bearer $authToken"
   "sensorId" = "$sensorId"
 }
 "Body" = '{"data": "1,2,3,4,5,6,1,2,3,4,4"}'
}
$response = Invoke-RestMethod @Params

echo $response | ConvertTo-Json


#
# Get sensor information
#
$Params = @{
 "URI"     = "$url/sensor"
 "Method"  = 'GET'
 "Headers" = @{
   "Content-Type"  = 'application/json'
   "Authorization" = "Bearer $authToken"
   "sensorId" = "$sensorId"
 }
}
$response = Invoke-RestMethod @Params

echo $response | ConvertTo-Json


#
# Get sensor status
#
$Params = @{
 "URI"     = "$url/status"
 "Method"  = 'GET'
 "Headers" = @{
   "Content-Type"  = 'application/json'
   "Authorization" = "Bearer $authToken"
   "sensorId" = "$sensorId"
 }
}
Invoke-RestMethod @Params 

echo $response | ConvertTo-Json

#
# Pretrain sensor, checking status regularly until completed
#
$Params = @{
 "URI"     = "$url/pretrain"
 "Method"  = 'POST'
 "Headers" = @{
   "Content-Type"  = 'application/json'
   "Authorization" = "Bearer $authToken"
   "sensorId" = "$sensorId"
 }
 "InFile" = "pretrain-data.json"
}
Invoke-RestMethod @Params
while($true)
{
    Start-Sleep -s 5
    $Params = @{
     "URI"     = "$url/pretrain"
     "Method"  = 'GET'
     "Headers" = @{
       "Content-Type"  = 'application/json'
       "Authorization" = "Bearer $authToken"
       "sensorId" = "$sensorId"
     }
    }
    $response = Invoke-RestMethod @Params
    echo $response.state
    if ( $response.state -ne "Pretraining" )
    {
        break
    }
}

echo $response | ConvertTo-Json

#
# Delete the sensor
#
$Params = @{
 "URI"     = "$url/sensor"
 "Method"  = 'DELETE'
 "Headers" = @{
   "Content-Type"  = 'application/json'
   "Authorization" = "Bearer $authToken"
   "sensorId" = "$sensorId"
 }
}
$response = (Invoke-RestMethod @Params)

echo $response | ConvertTo-Json
