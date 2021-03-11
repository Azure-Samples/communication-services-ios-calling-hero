# communication-services-ios-calling-hero

This project demonstrates the integration of [communication-services](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/voice-video-calling/calling-client-samples?pivots=platform-ios) for iOS application.

## Features

- Initialize the CallClient, create a CallAgent, and access the DeviceManager
- Start a new group call
- Join an existing group call
- Render remote participant video streams
- Turning local video stream from camera on/off
- Mute/unmute local microphone audio

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).
- A Mac running [Xcode](https://go.microsoft.com/fwLink/p/?LinkID=266532), along with a valid developer certificate installed into your Keychain. CocoaPods must also be installed to fetch dependencies.
- A deployed Communication Services resource. [Create a Communication Services resource](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/create-communication-resource).
- An Authentication Endpoint that will return the Azure Communication Services Token. See [example](https://docs.microsoft.com/en-us/azure/communication-services/tutorials/trusted-service-tutorial) or clone the [code](https://github.com/Azure-Samples/communication-services-javascript-quickstarts/tree/main/Trusted%20Authentication%20Service)

## Install Dependencies

- Run `pod install`

## Steps to Run

1. Open `ACSCall.xcworkspace` in XCode.
2. Update `AppSettings.plist`. Set the value for the `acsTokenFetchUrl` key to be the URL for your Authentication Endpoint.
3. Build/Run.

## Securing Authentication Endpoint

For simple demonstration purposes, this sample uses a publicly accessible endpoint by default to fetch an ACS token. For production scenarios, it is recommended that the ACS token is returned from a secured endpoint.  
With additional configuration, this sample also supports connecting to an **Azure Active Directory** (AAD) protected endpoint so that user login is required for the app to fetch an ACS token. See steps below:

1. Enable Azure Active Directory authentication in your app.
   - [Register your app under Azure Active Directory (using iOS / macOS platform settings)](https://docs.microsoft.com/en-us/azure/active-directory/develop/tutorial-v2-ios)
   - [Configure your App Service or Azure Functions app to use Azure AD login](https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad)
2. Go to your registered app overview page under Azure Active Directory App Registrations. Take note of the `Application (client) ID`, `Directory (tenant) ID`, `Application ID URI`
   ![](./docs/images/aadOverview.png)
3. Open `AppSettings.plist` in Xcode, add the following key values:
   - `acsTokenFetchUrl`: the URL to request Azure Communication Services token
   - `isAADAuthEnabled`: a boolean value to indicate if the Azure Communication Services token authentication is required or not
   - `aadClientId`: your Application (client) ID
   - `aadTenantId`: your Directory (tenant) ID
   - `aadRedirectURI`: the redirect URI should be in this format: `msauth.<app_bundle_id>://auth`
   - `aadScopes`: an array of permission scopes requested from users for authorization. Add `<Application ID URI>/user_impersonation` to the array to grant access to authentication endpoint
