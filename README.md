# Network Layer Overview
## This document provides an overview of the classes used in the network layer for data communication and caching.

## Classes
1. NetworkInfo

- Purpose: Provides information about the device's network connectivity.
- Methods: (implementation details may vary)
- isConnected: Checks if the device has an active internet connection. Returns true if connected, false otherwise.

2. NetworkResponseHandler

- Purpose: Handles responses from network requests, parses data, and stores tokens in the cache.
- Methods: call(Response res): Handles responses for raw data requests.
- Parses JSON data from the response body.
- Stores a retrieved token in the cache using CacheService.
- Throws exceptions for unauthorized (401), not found (404), and other error codes.
- handleFormData(StreamedResponse res): Handles responses for form data and multipart requests. Similar functionality to call but retrieves data from the streamed response.

3. CacheService

- Purpose: Provides methods for storing and retrieving data from the device's shared preferences.
#### Properties:
- userToken: Static string constant for the key used to store the user token.
####  Methods:
- setUserToken(token): Stores the provided token in shared preferences with the "Bearer" prefix.
- getUserToken(): Retrieves the stored user token from shared preferences.
- clear(): Clears all data stored in shared preferences (optional, can be used for logout or data clearing).

4. NetworkManager (Optional, depending on implementation)

- Purpose: Provides a central point for making network requests and handling responses.
####  Methods:
- get(String url): Makes a GET request to the specified URL.
- post(String url, dynamic body): Makes a POST request to the specified URL with a body.
- (Optional) Additional methods for other HTTP verbs (PUT, DELETE, etc.).

## Usage
#### Dependency Injection:
Ensure SharedPreferences and relevant network libraries are registered with your dependency injection framework (e.g., getIt).
#### Network Connectivity:
Use NetworkInfo.isConnected to check for an internet connection before making requests.
#### Network Requests:
Use NetworkManager (if available) for convenient request methods. Alternatively, use libraries like http directly.
#### Response Handling:
Use NetworkResponseHandler to handle the response:
For raw data requests, use call(response).
For form data and multipart requests, use handleFormData(response).
The handler parses data, stores tokens (if present), and throws exceptions for errors.
#### Cache Interaction:
Use CacheService methods to store and retrieve user tokens:
setUserToken(token) to store a new token.
getUserToken() to retrieve the stored token.
clear() to clear all cached data.

