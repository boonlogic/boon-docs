![Boon Logic company logo](../images/BoonLogic.png)

# Boon Amber Licensing

The Boon Amber Cloud requires that licensing information (aka. credentials) be provided when using SDKs or directly accessing the REST/API.

## Amber licensing for SDKs

When using the Amber SDKs, the username and password can be placed in a file named **~/.Amber.license** whose contents are the following:


```
{
    "default": {
        "username": "your-username",
        "password": "your-password",
        "server": "https://amber.boonlogic.com/v1"
    }
}
```

The **~/.Amber.license** file will be consulted by the Amber SDKs to find and authenticate your Amber instance with the Amber server. Credentials may optionally be provided instead via the environment variables AMBER__USERNAME and AMBER__PASSWORD.

* *[Python SDK](https://boonlogic.github.io/amber-python-sdk)*
* *[Javascript SDK (beta)](https://boonlogic.github.io/amber-javascript-sdk)*
* *[C++ SDK (beta)](https://boonlogic.github.io/amber-cpp-sdk)*


## Amber licensing with REST/API

The REST/API controls authentication through the /oauth2 API endpoint.

See: *[REST API](../docs/Amber_REST.md)*

## Amber licensing for Jupiter Notebook

TBD

