![Boon Logic company logo](../images/BoonLogic.png)

# Boon Amber REST API

We serve an interface to the Boon Amber via the REST API described below. This API can also be accessed and explored directly through the Swagger UI [available here](../amber-static/index.html).

## Examples

Samples scripts are provided here to demonstrate each of Amber's API endpoints.  The scripts will need to be modified to properly set your own username/password.

Bash script using curl:
[amber-sample.sh](../examples/amber-sample.sh) (requires jq installation)


Windows Powershell using Invoke-RestMethod:
[amber-sample.ps1](../examples/amber-sample.ps1)


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
      "label": sensor label
      "usageInfo": {
        "postSensor": {
            "callsTotal":
            "callsThisPeriod":    (same as above)
            "lastCalled":
        },
        "postConfig": {
            "callsTotal":
            "callsThisPeriod":    (same as above)
            "lastCalled":
        },
        "postStream": {
            "callsTotal": total number of calls to the /PUT stream endpoint
            "callsThisPeriod": calls this billing period to this endpoint
            "lastCalled": ISO formatted time of last call to this endpoint
            "samplesTotal": total number of samples processed
            "samplesThisPeriod": number of samples processed this billing period
        }
        "getSensor": {
        	"callsTotal":
        	"callsThisPeriod":    (same as above)
        	"lastCalled":
        },
        "getConfig": {
            "callsTotal":
            "callsThisPeriod":    (same as above)
            "lastCalled":
        }
        ... same as above for each of:
        - getAmberSummary
        - getRootCause
        - getStatus
        - postPretrain
        - putSensor
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
      "label": newly assigned label
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
      "samplesToBuffer": number of initial samples to load before autotuning (default 10000)
      "learningRateNumerator": sensor "graduates" (i.e. transitions from learning to monitoring mode) if fewer than learningRateNumerator new clusters are created in the last learningRateDenominator samples (default 10)
      "learningRateDenominator': see learningRateNumerator (default 10000)
      "learningMaxClusters": sensor graduates if this many clusters are created (default 1000)
      "learningMaxSamples": sensor graduates if this many samples are processed (default 1000000)
      "anomalyHistoryWindow": number of past samples to use when assessing historical anomalies (default 10000)
      "features": [
        {
          "label": label for this feature
          "min": (optional) minimum value for this feature - data values below this will be clipped into min/max range
          "max": (optional) maximum value for this feature - data values above this will be clipped into min/max range
          "submitRule": (optional) whether updates to this feature's value should submit the feature vector for inference in fusion mode (see /PUT config). One of "submit", "nosubmit" (default is "submit")
        }
        ... (for all features)
      ]
    }

`"featureCount"` is meant as a shortcut which will config features with default labels and find smart min/max values during autotuning. If `"features"` is provided, the number of elements must agree with `"featureCount"` and the features are then configured explicitly according to the `"features"` array.

Response body:

    {
      "featureCount": applied featureCount
      "streamingWindowSize": applied streamingWindowSize
      "samplesToBuffer": applied samplesToBuffer
      "learningRateNumerator": applied learningRateNumerator
      "learningRateDenominator": applied learningRateDenominator
      "learningMaxClusters": applied learningMaxClusters
      "learningMaxSamples": applied learningMaxSamples
      "anomalyHistoryWindow": applied anomalyHistoryWindow,
      "features": [
          {
            "label": feature name (default "feature-0")
            "maxVal": explicit min value for this feature, (default 0, will be set by autotuning)
            "minVal": explicit max value for this feature, (default 1, will be set by autotuning)
            "submitRule": "submit" | "nosubmit" (default "submit")
          },
          ... (for all features)
      ]
    }

Example:

    curl --request POST \
      --url https://amber.boonlogic.com/v1/config \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef" \
      --data '{"featureCount": 1, "streamingWindowSize": 25, "samplesToBuffer": 1000, "learningRateNumerator": 10, "learningRateDenominator": 10000, "learningMaxSamples": 1000000, "learningMaxClusters": 1000}'

## PUT /config

This endpoint has two capabilities:

1. Configure the sensor for "sensor fusion" mode. In this mode, the sensor is configured with an input vector of explicitly named features. Each input feature represents an individual data stream to be combined with the others to form a "fusion vector". The fusion vector is composed of the latest value from each input stream, where the inputs are various sensor streams from the same process under monitoring. The fusion vector acts as a state vector for the system as a whole, enabling joint anomaly detection across all sensors on the asset.

2. Enable learning: forcibly switch a sensor in Monitoring mode back into Learning with the provided streaming configuration.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body:

    {
      "features": [
        {
          "label": feature name
          "submitRule": "submit" | "nosubmit" (default "submit")
        }
        ... (for all features)
      ],
      "streaming": {
        "featureCount": same as /POST config
        "streamingWindowSize": same as /POST config
        "samplesToBuffer": same as /POST config
        "learningRateNumerator": same as /POST config
        "learningRateDenominator": same as /POST config
        "learningMaxClusters": same as /POST config
        "learningMaxSamples": same as /POST config
        "anomalyHistoryWindow": same as /POST config
      }
    }

One or both of `"features"` and `"streaming"` may be provided.

Response body:

    {
      "features": [
        {
          "label": applied label
          "submitRule": applied submit rule
        }
        ... (for all features)
    }

Example:

    curl --request PUT \
      --url https://amber.boonlogic.com/v1/config \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef" \
      --data '{"features": [{"label": "f0", "submitRule": "submit"}, {"label": "f1", "submitRule": "submit"}, {"label": "f2", "submitRule": "nosubmit"}]}'

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
      "anomalyHistoryWindow": configured anomaly history window
      "features": [
        {
          "minVal": min value discovered by autotuning for first feature
          "maxVal": max value discovered by autotuning for first feature
          "label": label for first feature
          "submitRule": submit rule for first feature
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
      "data": comma-separated string of numbers with no spaces
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

## PUT /stream

Update one or more values of the sensor's fusion vector, returning an inference result if the updated vector was submitted. Updates are provided as a list of new sample values for individual features.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body:

    {
      "vector": [
        {
          "label": name of fusion feature to update
          "value": set fusion feature to this new value
        },
        ... (for one or more fields to update)
      ],
      "submitRule": whether to submit vector for inference on this request. Setting this field to "submit" or "nosubmit" will forcibly override the per-feature submit rules in determining whether to perform an inference. If not provided, default is "default" which respects per-feature submit rules.
    }

Response body:

If vector was submitted for inference, response code is 200 and body is the same as that of /POST stream.

If vector was updated but not submitted for inference, response code is 202 (accepted) with the following body:

    {
      "vector": [
        {
          "label": label for first feature in vector
          "value": updated value for first feature in vector
        },
        ... (for all values in vector)
      ],
      "vectorCSV": comma-separated string of raw vector values
    }

Example:

    curl --request PUT \
      --url https://amber.boonlogic.com/v1/stream \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef" \
      --data '{"features": [{"label": "f0", "value": "0.25"}, {"label": "f2", "value": "0.5"}]}'

## POST /pretrain

Send historical data to a sensor to train the model. Ingoing data should be formatted as a simple string of comma-separated numbers with no spaces. The model is then trained and set to monitoring if autotuneConfig is true, otherwise is trained with the given data. For complete documentation see [Amber Outputs](AmberDocs/Overview.md#Pretraining).

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body:

    {
      "data": comma-separated string of numbers with no spaces
      "autotuneConfig": if true, automatically adjust streaming configuration so that sensor is in Monitoring mode upon completion
    }

Response body:

    {
      "state": "None" | "Pretraining" | "Pretrained" | "Error"
      "message": error message if state is Error
    }

Example:

    curl --request POST \
      --url https://amber.boonlogic.com/v1/pretrain \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef" \
      --data '{"data": "0,0.5,1,1.5,2", "autotuneConfig": "true"}'

## GET /status

Get analytics derived from data processed by a sensor so far.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

Request body: None.

Response body:

    {
      "state": "Buffering" | "Autotuning" | "Learning" | "Monitoring" | "Error"
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
      "anomalyThreshold": anomaly index detection threshold auto-set by Amber
    }

Example:

    curl --request GET \
      --url https://amber.boonlogic.com/v1/status \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef"


## GET /rootCause

Gets the root cause analysis vector for the given cluster ID or pattern vector.

HTTP header values:

    "Authorization: Bearer ${idToken}"
    "sensorId: <sensor-id>"

URL query parameters:

    "pattern=[pattern-vectors]"
    "clusterID=[cluster-ids]"

Request body: None.

Response body:

    [
    	[root cause vector for the first pattern/ID given],
    	[root cause vector for the second pattern/ID given (if applicable)],
    	...
    ]

Example:

    curl --request GET \
      --url https://amber.boonlogic.com/v1/rootCause? \
      clusterID=[1,2] \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef"

OR

    curl --request GET \
      --url https://amber.boonlogic.com/v1/rootCause? \
      pattern=[[1,1,2,3,1,2]] \
      --header "Authorization: Bearer ${idToken}" \
      --header "Content-Type: application/json" \
      --header "sensorId: 0123456789abcdef"
