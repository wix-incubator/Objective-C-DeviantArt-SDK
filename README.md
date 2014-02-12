# deviantART SDK
deviantART SDK is a library that makes it easier for developers to create and develop apps using the [deviantART API](https://www.deviantart.com/developers). It currently supports all public OAuth2 API methods on the deviantART API with simple authentication methods provided. Using this SDK should simplify deviantART integration for any developer who wishes to add it to their app.

## How To Get Started

* Download the SDK and try the included example iOS app or the example [Mac app](https://github.com/deviantART/Sta.sh-for-Mac). 
* Checkout and read the documentation of the code included for a deeper look at what is available to use.
* Questions? Post an issue!

### Installation with CocoaPods

CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like the deviantART SDK in your projects.

#### Podfile

```ruby
platform :ios, '7.0'
pod "deviantART-SDK", "~> 1.0.0"
```

#### Setup
To setup, add this line and import DVNTAPI.h in your application delegate’s application:didFinishLaunchingWithOptions: method, to set your client ID and secret SDK-wide:

```objective-c
[DVNTAPIClient setClientID:@"__CHANGE_ME__" clientSecret:@"__CHANGE_ME__"];
```

Register your application [here](http://www.deviantart.com/developers/register) to get a client ID and secret. 

The SDK defaults to using a redirect URI of https://www.deviantart.com/oauth2/redirect, you can change this by calling setRedirectURI: on DVNTAPIClient directly after setting your client ID and secret.

#### Authenticating with deviantART
Authenticate with deviantART via the SDK by implementing the below method:

```objective-c
[DVNTAPIClient authenticateFromController:self scope:@"basic" completionHandler:^(NSError *error) {

    if(!error && [DVNTAPIClient isAuthenticated]) {
        // App is fully authenticated with no errors 
        // and ready to perform API calls
    } else {
    	NSLog(@"Error: %@", error);
    }
}];
```

This method will show a view controller or window, dependent on platform, that loads the OAuth2 forms as neccessary. The completionHandler will be called when login is completed in this controller/window.

## Usage

### DVNTAPIClient
DVNTAPIClient encapsulates the OAuth2 authentication and client logic. It also provides basic methods for GET/POST calls. These GET/POST methods are wrapped by DVNTAPIRequest to provide a nicer API for you to use within your application. Use this for any API call that DVNTAPIRequest does not have already. If DVNTAPIRequest is missing an API call within it's methods, please open an issue or send in a pull request to add it.

#### `GET` Request
GET call to retrieve a folder’s metadata.

```objective-c
[DVNTAPIClient GET:@"/api/oauth2/stash/metadata" parameters:@{@"folderid": @"12345"} success:^(NSURLSessionDataTask *task, id JSON) {

    NSLog(@"Your folder's title is %@", JSON[@"title"]);               
} failure:^(NSURLSessionDataTask *task, NSError *error) { 

    NSLog(@"Error: %@", error);
}];
```

#### `POST` Request
POST call to delete a Sta.sh item.

```objective-c
[DVNTAPIClient POST:@"/api/oauth2/stash/delete" parameters:@{@"stashid": @"12345"} success:^(NSURLSessionDataTask *task, id JSON) {
           
    NSLog(@"Your deleted StashID was %@”, JSON[@"stashid"]);               
} failure:^(NSURLSessionDataTask *task, NSError *error) { 

    NSLog(@"Error: %@", error);
}];
```

### DVNTAPIRequest
This class provides wrappers around every endpoint on the deviantART API as listed below. For indepth details about what these calls perform, check the [Developers](https://www.deviantart.com/developers) page on deviantART.

* `user/whoami`
* `user/whois`
* `stash/submit`
* `stash/delete`
* `stash/move/folder`
* `stash/move/file`
* `stash/folder`
* `stash/space`
* `stash/delta`
* `stash/metadata`
* `stash/media`
* `oEmbed`

For more information on the methods within DVNTAPIRequest, check the header file of the class or the below documentation.

## Documentation
Full documentation of DVNTAPIRequest and DVNTAPIClient will be installed into Xcode's documentation tool when the Pod is installed. Open the documentation viewer under 'Help -> Documentation and API Reference" then select 'deviantART SDK Documentation'.

## Issues and Pull Requests

#### Issues
Please ensure all issues opened have clear and concise information provided. For bugs, please include steps to reproduce if possible as this will make correcting the issue simpler to achieve. For other general issues, please provide as much information as possible so that we can clearly understand the problem you have having.


#### Pull Requests
Any pull requests must obey deviantART's [Objective-C Style Guide](https://github.com/deviantART/objective-c-style-guide). This ensures that the code base is coherent and clear to any developer who may work with the project. 

Your pull requests should ideally provide information as to why the changes are needed, either by linking to a current issue or by explaining your changes and their outcome clearly. This allows us to quickly manage your pull request and merge changes as needed.
