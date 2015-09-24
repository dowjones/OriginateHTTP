# OriginateHTTP

[![CI Status](http://img.shields.io/travis/Originate/OriginateHTTP.svg?style=flat)](https://travis-ci.org/Originate/OriginateHTTP)

> A lightweight HTTP networking client backed by NSURLSession.


## Installation with CocoaPods

Add the following lines to your Podfile and then run `pod install`.

```ruby
source 'https://github.com/Originate/CocoaPods.git'
pod 'OriginateHTTP'
```


## Requirements

* iOS 7.0+


## Usage

### Basic HTTP

```objc
NSURL *URL = [NSURL URLWithString:@"https://www.apple.com/"];

OriginateHTTPClient *HTTPClient = [[OriginateHTTPClient alloc] initWithBaseURL:URL
                                                              authorizedObject:nil];

// perform GET on www.apple.com/robots.txt
[HTTPClient GETResource:@"robots.txt" 
               response:^(id response, NSError *error)  {
    NSLog(@"response = %@", response);
}];
```

Other HTTP methods are supported as well:

```objc
- (void)GETResource:(NSString *)URI
            headers:(NSDictionary *)headers
           response:(OriginateHTTPClientResponse)responseBlock;

- (void)GETResource:(NSString *)URI
           response:(OriginateHTTPClientResponse)responseBlock;

- (void)POSTResource:(NSString *)URI
             payload:(NSData *)body
            response:(OriginateHTTPClientResponse)responseBlock;

- (void)PATCHResource:(NSString *)URI
         deltaPayload:(NSData *)payload
             response:(OriginateHTTPClientResponse)responseBlock;

- (void)PUTResource:(NSString *)URI
            payload:(NSData *)payload
           response:(OriginateHTTPClientResponse)responseBlock;

- (void)DELETEResource:(NSString *)URI
              response:(OriginateHTTPClientResponse)responseBlock;
```


### Authorization

Any additional headers necessary for authorization can be passed into the `OriginateHTTPClient` via an object conforming to `<OriginateHTTPAuthorizedObject>`.

All requests made thereafter will automatically include the appropriate headers.


### Logging

Log responses by listening to `OriginateHTTPClientResponseNotification`. The notification will include an object conforming to `<OriginateHTTPLogging>`.


## License

OriginateHTTP is available under the MIT license. See the LICENSE file for more info.
