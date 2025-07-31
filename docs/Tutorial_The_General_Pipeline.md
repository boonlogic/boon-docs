![Boon Logic company logo](../images/BoonLogic.png)
# Tutorial: The General Pipeline

If you have already authenticated the web page, skip to Initialize Instance
### Getting Started
1. Open web browser
2. In the URL, go to the web address assigned to your account. It should be your api-tenant followed by boonlogic.com. For example: https://6d4ed33b636a961b.boonlogic.com/index.html?api-tenant=130778449cb1588d. This link can be found in the welcome email.

3. There should be a title that says: `Boon Logic BoonNano API`
4. Copy your unique api-key associated with your account from the .BoonLogic file.
2. In the nano web page, on the right side after the title panel, click on the blue button labeled `Authorize` with a lock
3. When prompted, enter the copied api key in the `Value` field
4. Click `Authorize`
5. Close the prompt window

### Initialize Instance
1. Click on the header labelled `instances` (second from the top)
2. Find and click on the first green `POST` option which is labelled `/expert/v3/nanoInstance`
3. On the right side, click on `Try it out`
4. The input field will not be greyed out and two new buttons will appear. Enter a label for the nano instance you want to allocate.
4. Choose `Execute`
5. A few lines down there is a header labelled `Code` followed by `Details` on the same line. Immediately under that is the response code to the request. For a successful request, the code should be `200` with a JSON block containing some information about the instance ID.

    ```json
    {
      "createdAt": "Wed Jan 15 15:37:35 2020",
      "instanceID": "example",
      "isNew": true,
      "modifiedAt": "Wed Jan 15 15:37:35 2020"
    }
    ```

### Load the Configuration
1. Scroll down to find the next header labelled `configuration`.
2. The first option is a blue `GET` command labelled `expert/v3/configTemplate`. Click on the blue bar to expand the command.
3. Click on `Try it out` on the right hand side.
4. Fill in each field with the following values:

    | variable | value |
    | ---| ---|
    | featureCount | 20 |
    | numericType | float32 |
    | minVal | -10 |
    | maxVal | 15 |
    | weight | 1 |
    | percentVariation | 0.037 |
    | streamingWindowSize | 1 |
    | accuracy | 0.99 |

5. After the last variable, click on the blue `Execute` button.
6. A few lines down, there is the `Code` and `Details` header followed by a number and a `Response body` on the next line. If the number is `200`, highlight the entire JSON block in the `Response body` field. Save to clipboard.
7. Scroll down the webpage to the next rest call. It should be a green `POST` labelled `/expert/v3/clusterConfig/{instanceID}`. Click on the call bar and click the `Try it out` button on the right.
8. In the `instanceID` field, enter your nano label (e.g. "example"). This should be the input from step 4 in Initialize Instance.
9. Select everything in the `config` field. Paste the JSON block copied from step 6 so that it replaces what was there.
10. Click the blue `Execute` button.
11. A few lines down, find the `Code`/`Details` line and the results after it. The code should be `200` and the `Response body` should match exactly what was copied to your clipboard.

### Post Data
1. To download the example dataset, go [here](https://github.com/boonlogic/boonlogic-rest-api/blob/master/Data.csv) (or use your own data). Select the `raw` option from the list on the left side about halfway down the page. Right click on the page and select `Save As...`.
1. Return to the Nano UI. Scroll all the way to the bottom of the webpage to the second to last header labelled `cluster`.
2. The first call after `cluster` should be a green `POST` labelled `expert/v3/data/{instanceID}`. Click on the title to expand the call and click the `Try it out` button on the right.
3. The first input field is labelled `instanceID`. In the input field, enter the nano label. Again, this should be the input from step 4 in the Initialize Instance section.
4. The second input is labelled `data`. Click on the `Choose File` button and select the `Data.csv` file.
5. Fill in the following fields with the given values:

    | variable | value |
    | --- | --- |
    | fileType | csv |
    | gzip | false |
    | metadata |  |
    | appendData | false |
    | runNano | false |
    | results | -- |

6. Click the blue `Execute` button.
7. Check the result under the `Code` and `Details` heading for code `200` and `Response headers`
```
content-length: 0
content-type: application/json
date: Thu, 31 Oct 2019 15:00:27 GMT
```

### Run Nano
1. Scroll down the webpage to the next green header bar labelled `POST` `/expert/v3/nanoRun/{instanceID}`. Click on the bar to expand the options.
2. Click on the `Try it out` button on the right.
3. In the field labelled `instanceID`, enter the nano label - the same value from the Initialize Instance section.
4. In the `results` field, select `--`.
3. Click on the blue `Execute` button.
2. Finally, double check the results code. Under the `Code` and `Details` header, the value should be `200` and the `Response body` should be {}.

### Get Results
1. Under the same section header, find `GET` `/expert/v3/nanoResults/{instanceID}`. Click on the words to expand.
2. Select `Try it out` on the right.
3. Enter the `instanceID` used in each previous section.
4. For results, select `ID`
5. Select the blue `Execute` button.
6. The output should be a json block with one header: "ID" followed by a list of integers starting with a 1. These are the IDs for each pattern clustered and which cluster they are associated with.


  Congratulations! You have successfully clustered the data!
  See For more information on function calls or [Guide: Nano Results](./Guide_Nano_Results.md) and [Guide: Nano Status](./Guide_Nano_Status.md) for information on getting results.
  <br/>

[Return to documentation homepage](./UI-docs.md)
