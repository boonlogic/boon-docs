![Logo](../images/BoonLogic.png)   

# Boon Amber REST API

We serve an interface to the Boon Amber via the REST API described below. This API can also be accessed and explored directly through the Swagger UI [available here](../amber-static/index.html).

## Examples

Samples scripts are provided here to demonstrate each of Amber's API endpoints.  The scripts will need to be modified to properly set your own username/password.

Bash script using curl:
[amber-sample.sh](../examples/amber-sample.sh) (requires jq installation)


Windows Powershell using Invoke-RestMethod:
[amber-sample.ps1](../examples/amber-sample.ps1)


Data file used for pretraining example:
[pretrain-data.json](..examples/pretrain-data.json)


## POST /oauth2
Authenticates a set of user credentials provided in the body of the request. This must be called to acquire authentication credentials prior to using other endpoints. If authentication succeeds, response will contain a base-64 encoded string under the `"idToken"` attribute. All other API requests are then authenticated by including that token in the HTTP header: `"Authorization: Bearer ${idToken}"`.

HTTP header values: None.

Request body:

    {
      "username": Amber account username
      "password": Amber account password
    }

Response body:

    {
      "idToken": identifier token to be used as Bearer token
      "expiresIn": amount of time before token expires
      "refreshToken": refresh token identifier
      "tokenType": type of authentication token
    }

Example:

    curl --request POST \
      --url https://amber.boonlogic.com/v1/oauth2 \
      --header "Content-Type: application/json" \
      --data '{"username": "my-username", "password": "my-password"}'

## GET /sensors

List all sensor instances current associated with Amber account. The listing for each sensor includes the associated sensor ID, tenant (account username), and label. To get usage info for an individual sensor, call **GET /sensor** instead.

HTTP header values:

    "Authorization: Bearer ${idToken}"

Request body: None.

Response body:

    {
      [
        {
          "sensorId": sensor ID for this sensor
          "tenantId": account that owns this sensor
          "label": label for this sensor
        },
        ... (for all sensors)
      ]
    }

Example:

    curl --request GET \
      --url https://amber.boonlogic.com/v1/sensors \
      --header "Content-Type: application/json" \
      --header "Authorization: Bearer ${idToken}"

## POST /sensor

Create a new Amber sensor instance, returning its unique sensor identifier. The created sensor ID should be saved and tracked by the client in order to access the created instance in the future.

HTTP header values:

    "Authorization: Bearer ${idToken}"

Request body:

    {
      "label": label to assign to created sensor
    }

Response body:

    {
      "sensorId": sensor ID of created sensor
      "tenantId": account that owns this sensor
      "label": sensor label
    }

Example:

    curl --request POST \
      --url https://amber.boonlogic.com/v1/sensor \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --data '{"label": "my-label"}'

## GET /sensor

Get information about a sensor instance: sensor ID, tenant (account username), label and usage info. Unlike **GET /sensors**, the returned listing here includes `usageInfo` which tracks API calls to the given sensor during the current billing period and throughout its lifetime.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body: None.

Response body:

    {
      "sensorId": sensor ID of created sensor
      "tenantId": account that owns this sensor
      "label": sensor label
      "usageInfo": {
        "putSensor": {
        	"callsTotal": total number of calls to this endpoint
        	"callsThisPeriod": calls this billing period to this endpoint
        	"lastCalled": ISO formatted time of last call to this endpoint
        },
        "postConfig": {
        	"callsTotal":
        	"callsThisPeriod":    (same as above)
        	"lastCalled":
        },
        "getSensor": {
        	"callsTotal":
        	"callsThisPeriod":    (same as above)
        	"lastCalled":
        },
        "getConfig": {
        	"callsTotal":
        	"callsThisPeriod":    (same as above)
        	"lastCalled":
        },
        "getStatus": {
        	"callsTotal":
        	"callsThisPeriod":    (same as above)
        	"lastCalled":
        },
        "postStream": {
        	"callsTotal":
        	"callsThisPeriod":    (same as above)
        	"lastCalled":
        	"samplesTotal": total number of samples processed
        	"samplesThisPeriod": number of samples processed this billing period
        }
      }
    }

Example:

    curl --request GET \
      --url https://amber.boonlogic.com/v1/sensor \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef"

## PUT /sensor

Update the label of an existing sensor instance.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body:

    {
      "label": new label to assign to sensor
    }

Response body:

    {
      "sensorId": sensor ID of re-labeled sensor
      "tenantId": account that owns this sensor
      "label": new sensor label
    }

Example:

    curl --request PUT \
      --url https://amber.boonlogic.com/v1/sensor \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef" \
      --data '{"label": "my-new-label"}'

## DELETE /sensor

Delete an Amber sensor instance.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body: None.

Response body:

    "sensor has been deleted"

Example:

    curl --request DELETE \
      --url https://amber.boonlogic.com/v1/sensor \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef"

## POST /config

Apply the provided configuration to an Amber sensor instance. A sensor's configuration determines the dimensionality and streaming window size for input data, how many samples to ingest before autotuning, and its criteria for transitioning from Learning to Monitoring mode. A sensor must be configured before any data can be streamed to it using **POST /stream**. Basic parameter descriptions are below. For complete documentation see [Configuring Amber](AmberDocs/Overview.md/#Configuring_Amber).

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body:

    {
      "featureCount":  number of features (dimensionality of each data sample)
      "streamingWindowSize": streaming window size (number of samples)
      "samplesToBuffer": number of initial samples to load before autotuning
      "learningRateNumerator": sensor "graduates" (i.e. transitions from learning to monitoring mode) if fewer than learningRateNumerator new clusters are created in the last learningRateDenominator samples
      "learningRateDenominator': see learningRateNumerator
      "learningMaxClusters": sensor graduates if this many clusters are created
      "learningMaxSamples": sensor graduates if this many samples are processed
    }

Response body:

    {
      "featureCount": applied featureCount
      "streamingWindowSize": applied streamingWindowSize
      "samplesToBuffer": applied samplesToBuffer
      "learningRateNumerator": applied learningRateNumerator
      "learningRateDenominator": applied learningRateDenominator
      "learningMaxClusters": applied learningMaxClusters
      "learningMaxSamples": applied learningMaxSamples
    }

Example:

    curl --request POST \
      --url https://amber.boonlogic.com/v1/config \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef" \
      --data '{"featureCount": 1, "streamingWindowSize": 25, "samplesToBuffer": 1000, "learningRateNumerator": 10, "learningRateDenominator": 10000, "learningMaxSamples": 1000000, "learningMaxClusters": 1000}'

## GET /config

Get the current configuration of an Amber sensor instance. Note that the response includes `percentVariation` and `features`, which are not present in the posted configuration. These two hyperparameters are not set by the user but rather discovered automatically during autotuning. For complete configuration documentation see [Configuring Amber](AmberDocs/Overview.md/#Configuring_Amber).

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body: None.

Response body:

    {
      "featureCount":  number of features (dimensionality of each data sample)
      "streamingWindowSize": streaming window size (number of samples)
      "samplesToBuffer": number of initial samples to load before autotuning
      "learningRateNumerator": sensor "graduates" (i.e. transitions from learning to monitoring mode) if fewer than learningRateNumerator new clusters are created in the last learningRateDenominator samples
      "learningRateDenominator': see learningRateNumerator
      "learningMaxClusters": sensor graduates if this many clusters are created
      "learningMaxSamples": sensor graduates if this many samples are processed
      "percentVariation": percent variation hyperparameter discovered by autotuning
      "features": [
        {
          "minVal": min value discovered by autotuning for feature 1
          "maxVal": max value discovered by autotuning for feature 1
        },
        ... (for all features)
      ]
    }

Example:

    curl --request GET \
      --url https://amber.boonlogic.com/v1/config \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef"

## POST /stream

Stream data to a sensor and return the inference result. Ingoing data should be formatted as a simple string of comma-separated numbers with no spaces. The response values are briefly described below. For complete documentation see [Amber Outputs](AmberDocs/Overview.md#Amber_Outputs).

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body:

    {
      "data": <comma-separated string of numbers with no spaces>
    }

Response body:

    {
      "state": sensor state as of this call. One of:
          "Buffering": gathering initial sensor data
          "Autotuning": autotuning in progress
          "Learning": sensor is active and learning
          "Monitoring": sensor is active but monitoring only (learning disabled)
          "Error": fatal error has occurred
      "message": accompanying message for current sensor state
      "progress": progress as a percentage value (applicable for "Buffering" and "Autotuning" states)
      "clusterCount": number of clusters created so far
      "retryCount": number of times autotuning was re-attempted to tune streamingWindowSize
      "streamingWindowSize": streaming window size of sensor (may differ from value given at configuration if window size was adjusted during autotune)
      "ID": list of cluster IDs. The values in this list correspond one-to-one with input samples, indicating the cluster to which each input pattern was assigned.
      "SI": smoothed anomaly index. The values in this list correspond one-for-one with input samples and range between 0 and 1000. Values closer to 0 represent input patterns which are ordinary given the data seen so far on this sensor. Values closer to 1 represent novel patterns which are anomalous with respect to data seen before.
      "RI": raw anomaly index. These values are the SI values without any smoothing.
      "AD": list of binary anomaly detection values. These correspond one-to-one with input samples and are produced by thresholding the smoothed anomaly index (SI). The threshold is determined automatically from the SI values. A value of 0 indicates that the SI has not exceeded the anomaly detection threshold. A value of 1 indicates it has, signaling an anomaly at the corresponding input sample.
      "AH": list of anomaly history values. These values are a moving-window sum of the AD value, giving the number of anomaly detections (1's) present in the AD signal over a "recent history" window whose length is the buffer size.
      "AM": list of Amber metric values. These are floating point values between 0.0 and 1.0 indicating the extent to which each corresponding AH value shows an unusually high number of anomalies in recent history. The values are derived statistically from a Poisson model, with values close to 0.0 signaling a lower, and values close to 1.0 signaling a higher, frequency of anomalies than usual.
      "AW": list of Amber warning level values. This index is produced by thresholding the Amber Metric (AM) and takes on the values 0, 1 or 2 representing a discrete "warning level" for an asset based on the frequency of anomalies within recent history. 0 = normal, 1 = asset changing, 2 = asset critical. The default thresholds for the two warning levels are the standard statistical values of 0.95 (outlier, asset changing) and 0.997 (extreme outlier, asset critical).
    }

Example:

    curl --request POST \
      --url https://amber.boonlogic.com/v1/stream \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef" \
      --data '{"data": "0,0.5,1,1.5,2"}'

## POST /pretrain

Pretrain a sensor using historical data. This resets the sensor instance and then trains as much as possible using the data given. The amount of data must be enough to fill up the sample buffer, i.e. greater than the `samplesToBuffer` value given during configuration. After successfully pretraining, the sensor will be in either "Learning" or "Monitoring" mode.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body:

    {
      "data": <comma-separated string of numbers with no spaces>
    }

Response body:

    {
      "state": "Pretraining"
    }

Example:

    curl --request POST \
      --url https://amber.boonlogic.com/v1/pretrain \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef" \
      --data "@pretrain-data.json"

where the file `output_current.csv` contains the request body with data to be pretrained upon.

## GET /pretrain

Get a status message indicating whether the sensor instance is currently pretraining. Typically this is polled repeatedly after a sensor has begun pretraining in order to determine when pretraining has completed.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body: None.

Response body:

    {
      "state": "Pretraining" | "Pretrained" | "Error"
      "message": <error message if state is Error>
    }

Example:

    curl --request GET \
      --url https://amber.boonlogic.com/v1/pretrain \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef"

## GET /status

Get analytics derived from data processed by a sensor so far.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body: None.

Response body:

    {
      "pca": list of length-3 vectors representing cluster centroids
          with dimensionality reduced to 3 principal components. List length
          is one plus the maximum cluster ID, with element 0 corresponding
          to the "zero" cluster, element 1 corresponding to cluster ID 1, etc.
      "clusterGrowth": sample index at which each new cluster was created.
          Elements for this and other list results are ordered as in "pca".
      "clusterSizes": number of samples in each cluster
      "anomalyIndexes": anomaly index associated with each cluster
      "frequencyIndexes": frequency index associated with each cluster
      "distanceIndexes": distance index associated with each cluster
      "totalInferences": total number of inferences performed so far
      "numClusters": number of clusters created so far (includes zero cluster)
    }
    
Example:

    curl --request GET \
      --url https://amber.boonlogic.com/v1/status \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef"
