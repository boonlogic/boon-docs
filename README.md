![Boon Logo](images/BoonLogic.png)
  
# Boon Logic Application Interface Documentation

<table class="table">
  <tr>
    <td><img src="images/overview.png" width="400"></td>  
  </tr>
  <tr>
    <td><em>The Expert Console API and Amber Streaming API provide two different interfaces to the Boon Nano clustering engine.</em></td>
  </tr>
</table>

## The Boon Nano: The Core Technology

[Clustering with the Boon Nano](docs/Intro_to_Clustering.md)

## Amber: Streaming Analytics
**[Introduction to Amber](docs/AmberDocs/Overview.md#Intro)**

**[Operational Overview](docs/AmberDocs/Overview.md/#Operation)**

* *[Amber Training Phases](docs/AmberDocs/Overview.md/#Operation)*
* *[Amber Training Example](docs/AmberDocs/Overview.md/#Operation_Example)*

**[Definitions and Terminology](docs/AmberDocs/Overview.md/#Definitions)**

**[Configuring Amber](docs/AmberDocs/Overview.md/#Configuring_Amber)**

* *[Single-Feature Versus Multi-Feature Processing](docs/AmberDocs/Overview.md/#Configuring_Amber)*
* *[Single-Feature Processing](docs/AmberDocs/Overview.md/#Single_Feature)*
* *[Multi-Feature Processing (Sensor Fusion)](docs/AmberDocs/Overview.md/#Multi_Feature)*
* *[Configuration Parameters](docs/AmberDocs/Overview.md/#Config_Params)*

**[Amber Input Data Recommendations](docs/AmberDocs/Overview.md/#Data_Input_Recommendations)**

* *[Confounding Features](docs/AmberDocs/Overview.md/#Confounding)*
* *[Redundant and Poorly Correlated Features](docs/AmberDocs/Overview.md/#Redundant)*
* *[Missing Data and Variable Sample Rates](docs/AmberDocs/Overview.md/#Missing)*
* *[Categorical Data](docs/AmberDocs/Overview.md/#Categorical)*

**[Amber Training Recommendations](docs/AmberDocs/Overview.md/#Training_Recommendations)**

* *[The Autotuning Buffer](docs/AmberDocs/Overview.md/#Autotuning_Buffer)*
* *[The Training Buffer](docs/AmberDocs/Overview.md/#Training_Buffer)*
* *[Anomalies During Training](docs/AmberDocs/Overview.md/#Anomalies_During_Training)*

**[Amber Outputs](docs/AmberDocs/Overview.md#Amber_Outputs)**

* *[(ID) Cluster ID](docs/AmberDocs/Overview.md#ID)*
* *[(SI) Smoothed Anomaly Index](docs/AmberDocs/Overview.md#SI)*
* *[(AD) Anomaly Detections](docs/AmberDocs/Overview.md#AD)*
* *[(AH) Anomaly History](docs/AmberDocs/Overview.md#AH)*
* *[(AM) Anomaly Metric](docs/AmberDocs/Overview.md#AM)*
* *[(AW) Amber Warning Level](docs/AmberDocs/Overview.md#AW)*

**Examples**

* *[Anomaly Detection in a Single-Sensor Asset](Single_Sensor_Example/TimeSeries.md)*
* *[Anomaly Detection in a Multi-Sensor Asset (Sensor Fusion)](SensorFusionExample/SensorFusionExample.md)*

**Programming Intefaces**

* *[REST API](docs/Amber_REST.md)*
* *[Python SDK](https://boonlogic.github.io/amber-python-sdk)*
* *[Javascript SDK (beta)](https://boonlogic.github.io/amber-javascript-sdk)*
* *[C++ SDK (beta)](https://boonlogic.github.io/amber-cpp-sdk)*

## Expert Console: General-Purpose Analytics

**Programming Intefaces**

* *[REST API](static/index.html)*
* *[Excel SDK](https://boonlogic.github.io/expert-excel-sdk)*
* *[Python SDK](https://boonlogic.github.io/expert-python-sdk)*
* *[Matlab SDK](https://boonlogic.github.io/expert-matlab-sdk)*
* *[Mathematica SDK](https://boonlogic.github.io/expert-mathematica-sdk)*

## AVIS DICOM

[Visual Inspection of Mammography Images](https://boonlogic.github.io/AVIS-DICOM/)
