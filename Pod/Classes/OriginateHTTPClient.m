//
//  OriginateHTTPClient.m
//  OriginateHTTP
//
//  Created by Philip Kluz on 4/30/15.
//  Copyright (c) 2015 Originate. All rights reserved.
//

#import "OriginateHTTPClient.h"
#import "OriginateHTTPAuthorizedObject.h"
#import "OriginateHTTPLog.h"

NSString* const OriginateHTTPClientResponseNotification = @"com.originate.http-client.response";

@implementation OriginateHTTPClient

#pragma mark - OriginateHTTPClient

- (instancetype)initWithBaseURL:(NSURL *)baseURL
               authorizedObject:(id<OriginateHTTPAuthorizedObject>)object {
    self = [super init];

    if (self) {
        _baseURL = baseURL;
        _authorizedObject = object;
    }

    return self;
}

- (NSTimeInterval)timeoutInterval
{
    if (_timeoutInterval == 0) {
        _timeoutInterval = 30.0;
    }

    return _timeoutInterval;
}

- (void)GETResource:(NSString *)URI
            headers:(NSDictionary *)headers
           response:(OriginateHTTPClientResponse)responseBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.HTTPAdditionalHeaders = headers;

    [[self class] GETResource:URI
                      baseURL:self.baseURL
                       config:configuration
                      timeout:self.timeoutInterval
                     response:^(id resource, NSError *error) {
                         if (responseBlock) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 responseBlock(resource, error);
                             });
                         }
                     }];
}

- (void)GETResource:(NSString *)URI
           response:(OriginateHTTPClientResponse)responseBlock
{
    [self GETResource:URI
              headers:[self.authorizedObject authorizationHeader]
             response:responseBlock];
}

- (void)POSTResource:(NSString *)URI
             payload:(NSData *)body
            response:(OriginateHTTPClientResponse)responseBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.HTTPAdditionalHeaders = [self.authorizedObject authorizationHeader];

    [[self class] POSTResource:URI
                       baseURL:self.baseURL
                        config:configuration
                       timeout:self.timeoutInterval
                       payload:body
                      response:^(id resource, NSError *error) {
                          if (responseBlock) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  responseBlock(resource, error);
                              });
                          }
                      }];
}

- (void)PATCHResource:(NSString *)URI
         deltaPayload:(NSData *)body
             response:(OriginateHTTPClientResponse)responseBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.HTTPAdditionalHeaders = [self.authorizedObject authorizationHeader];

    [[self class] PATCHResource:URI
                        baseURL:self.baseURL
                         config:configuration
                        timeout:self.timeoutInterval
                        payload:body
                       response:^(id resource, NSError *error)
     {
         if (responseBlock) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 responseBlock(resource, error);
             });
         }
     }];
}


- (void)PUTResource:(NSString *)URI
            payload:(NSData *)payload
           response:(OriginateHTTPClientResponse)responseBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.HTTPAdditionalHeaders = [self.authorizedObject authorizationHeader];

    [[self class] PUTResource:URI
                      baseURL:self.baseURL
                       config:configuration
                      timeout:self.timeoutInterval
                      payload:payload
                     response:^(id resource, NSError *error)
     {
         if (responseBlock) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 responseBlock(resource, error);
             });
         }
     }];

}

- (void)DELETEResource:(NSString *)URI
              response:(OriginateHTTPClientResponse)responseBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.HTTPAdditionalHeaders = [self.authorizedObject authorizationHeader];

    [[self class] DELETEResource:URI
                         baseURL:self.baseURL
                          config:configuration
                         timeout:self.timeoutInterval
                        response:^(id resource, NSError *error)
     {
         if (responseBlock) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 responseBlock(resource, error);
             });
         }
     }];
}

#pragma mark - OriginateHTTPClient (Generic Implementations)

+ (void)GETResource:(NSString *)URI
            baseURL:(NSURL *)baseURL
             config:(NSURLSessionConfiguration *)config
            timeout:(NSTimeInterval)timeout
           response:(OriginateHTTPClientResponse)responseBlock
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", baseURL, URI];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLSessionDataTask *task;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL
                                             cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                         timeoutInterval:timeout];
    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *responseError)
            {
                if (!responseBlock) {
                    return;
                }
                NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
                
                NSError *error = [self errorForResponse:HTTPResponse connectionError:responseError];
                
                if (error) {
                    responseBlock(nil, error);
                    return;
                }
                
                id result;
                
                if (HTTPResponse.statusCode >= 200 && HTTPResponse.statusCode <= 299) {
                    
                    if ([[self class] emptyBodyAcceptableForHTTPResponse:HTTPResponse] && data.length == 0) {
                        responseBlock(nil, nil);
                        return;
                    }
                    
                    if ([HTTPResponse.allHeaderFields[@"Content-Type"] hasPrefix:@"application/json"] ||
                        [HTTPResponse.allHeaderFields[@"Content-Type"] hasPrefix:@"application/vnd.api+json"])
                    {
                        result = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];
                    }
                    else {
                        result = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
                    }
                }
                
                OriginateHTTPLog *log = [[OriginateHTTPLog alloc] initWithURLResponse:response
                                                                       responseObject:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:OriginateHTTPClientResponseNotification
                                                                    object:log];
                responseBlock(result, error);
            }];

    [task resume];
}

+ (void)POSTResource:(NSString *)URI
             baseURL:(NSURL *)baseURL
              config:(NSURLSessionConfiguration *)config
             timeout:(NSTimeInterval)timeout
             payload:(NSData *)payload
            response:(OriginateHTTPClientResponse)responseBlock
{
    NSURL *URL = [baseURL URLByAppendingPathComponent:URI];
    NSURLSessionDataTask *task;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                       timeoutInterval:timeout];

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:payload];
    
    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *responseError)
            {
                if (!responseBlock) {
                    return;
                }
                
                NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
                
                NSError *error = [[self class] errorForResponse:HTTPResponse
                                                connectionError:responseError];
                
                if (error) {
                    responseBlock(nil, error);
                    return;
                }
                
                NSString *resourceLocation = HTTPResponse.allHeaderFields[@"Location"];
                
                OriginateHTTPLog* log = [[OriginateHTTPLog alloc] initWithURLResponse:response
                                                                       responseObject:resourceLocation];
                [[NSNotificationCenter defaultCenter] postNotificationName:OriginateHTTPClientResponseNotification
                                                                    object:log];
                
                responseBlock(resourceLocation, nil);
            }];
    
    [task resume];
}

+ (void)PATCHResource:(NSString *)URI
              baseURL:(NSURL *)baseURL
               config:(NSURLSessionConfiguration *)config
              timeout:(NSTimeInterval)timeout
              payload:(NSData *)body
             response:(OriginateHTTPClientResponse)responseBlock
{
    NSURL *URL = [baseURL URLByAppendingPathComponent:URI];
    NSURLSessionDataTask *task;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                       timeoutInterval:timeout];

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [request setHTTPMethod:@"PATCH"];
    [request setHTTPBody:body];
    
    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *responseError)
            {
                if (!responseBlock) {
                    return;
                }
                
                NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
                NSError *error = [self errorForResponse:HTTPResponse connectionError:responseError];
                
                if (error) {
                    responseBlock(nil, error);
                    return;
                }
                
                if ([[self class] emptyBodyAcceptableForHTTPResponse:HTTPResponse] && data.length == 0) {
                    responseBlock(nil, nil);
                    return;
                }
                
                NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:&error];
                
                if (error) {
                    responseBlock(nil, [[self class] HTTPError500InternalServer]);
                    return;
                }
                
                OriginateHTTPLog* log = [[OriginateHTTPLog alloc] initWithURLResponse:response
                                                                       responseObject:responseBody];
                [[NSNotificationCenter defaultCenter] postNotificationName:OriginateHTTPClientResponseNotification
                                                                    object:log];
                responseBlock(responseBody, nil);
            }];

    [task resume];
}


+ (void)PUTResource:(NSString *)URI
            baseURL:(NSURL *)baseURL
             config:(NSURLSessionConfiguration *)config
            timeout:(NSTimeInterval)timeout
            payload:(NSData *)body
           response:(OriginateHTTPClientResponse)responseBlock
{
    NSURL *URL = [baseURL URLByAppendingPathComponent:URI];
    NSURLSessionDataTask *task;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                       timeoutInterval:timeout];

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [request setHTTPMethod:@"PUT"];

    [request setHTTPBody:body];

    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *responseError)
            {
                if (!responseBlock) {
                    return;
                }
                
                NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
                
                NSError *error = [[self class] errorForResponse:HTTPResponse
                                                connectionError:responseError];
                
                if (error) {
                    responseBlock(nil, error);
                    return;
                }
                
                if ([[self class] emptyBodyAcceptableForHTTPResponse:HTTPResponse] && data.length == 0) {
                    responseBlock(nil, nil);
                    return;
                }
                
                id result = nil;
                
                NSDictionary *decodedResult = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingAllowFragments
                                                                                error:&error];
                if (!error) {
                    result = decodedResult;
                }
                
                OriginateHTTPLog* log = [[OriginateHTTPLog alloc] initWithURLResponse:response
                                                                       responseObject:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:OriginateHTTPClientResponseNotification
                                                                    object:log];
                responseBlock(result, error);
            }];
    
    [task resume];
}

+ (void)DELETEResource:(NSString *)URI
               baseURL:(NSURL *)baseURL
                config:(NSURLSessionConfiguration *)config
               timeout:(NSTimeInterval)timeout
              response:(OriginateHTTPClientResponse)responseBlock
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", baseURL, URI];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLSessionDataTask *task;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                       timeoutInterval:timeout];

    [request setHTTPMethod:@"DELETE"];

    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *responseError)
            {
                if (!responseBlock) {
                    return;
                }
                
                NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
                NSError *error = [[self class] errorForResponse:HTTPResponse connectionError:responseError];
                
                if (error) {
                    responseBlock(nil, error);
                    return;
                }
                
                if ([[self class] emptyBodyAcceptableForHTTPResponse:HTTPResponse] && data.length == 0) {
                    responseBlock(nil, nil);
                    return;
                }
                
                NSError *jsonError;
                NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:&jsonError];
                
                if (jsonError) {
                    responseBlock(nil, [[self class] HTTPError500InternalServer]);
                    return;
                }
                
                OriginateHTTPLog* log = [[OriginateHTTPLog alloc] initWithURLResponse:response
                                                                       responseObject:responseBody];
                [[NSNotificationCenter defaultCenter] postNotificationName:OriginateHTTPClientResponseNotification
                                                                    object:log];
                
                responseBlock(responseBody, nil);
            }];
    
    [task resume];
}


#pragma mark - Empty HTTP body

+ (BOOL)emptyBodyAcceptableForHTTPResponse:(NSHTTPURLResponse *)HTTPResponse
{
    switch (HTTPResponse.statusCode) {
        case 201:
        case 202:
        case 204:
            return YES;
        default:
            return NO;
    }
}


#pragma mark - Errors

+ (NSError *)errorForResponse:(NSHTTPURLResponse *)HTTPResponse
              connectionError:(NSError *)responseError
{
    NSInteger statusCode = HTTPResponse.statusCode;
    NSError *error = nil;
    
    if (statusCode >= 200 && statusCode <= 299) { // Success Range. No error.
        return nil;
    }
    else if (statusCode == 401) {
        error = [[self class] HTTPError401Unauthorized];
    }
    else if (statusCode == 403) {
        error = [[self class] HTTPError403Forbidden];
    }
    else if (statusCode == 409) {
        error = [[self class] HTTPError409Conflict];
    }
    else if (statusCode >= 500 && statusCode <= 599) {
        error = [[self class] HTTPError500InternalServer];
    }
    else if (responseError.code == kCFURLErrorTimedOut) {
        error = [[self class] errorTimeout];
    }
    else if (responseError) {
        error = responseError;
    }
    else {
        error = [[self class] unknownErrorWithResponseHeader:HTTPResponse];
    }
    
    return error;
}

+ (NSString *)errorDomain
{
    return @"com.originate.networking";
}

+ (NSError *)errorDecodingJSON
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:2
                           userInfo:@{ NSLocalizedDescriptionKey : @"The server's response cannot be processed." }];
}

+ (NSError *)unknownErrorWithResponseHeader:(NSHTTPURLResponse *)response
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:-1
                           userInfo:@{ NSLocalizedDescriptionKey : @"An unknown error occured.",
                                       @"http_response" : response }];
}

+ (NSError *)errorTimeout
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:kCFURLErrorTimedOut
                           userInfo:@{ NSLocalizedDescriptionKey : @"The request timed out. Please check your internet connection." }];
}

// HTTP Errors

+ (NSError *)HTTPError400BadData
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:400
                           userInfo:@{ NSLocalizedDescriptionKey : @"The request could not be understood by the server due to malformed syntax." }];
}

+ (NSError *)HTTPError401Unauthorized
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:401
                           userInfo:@{ NSLocalizedDescriptionKey : @"The request requires user authentication." }];
}

+ (NSError *)HTTPError403Forbidden
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:403
                           userInfo:@{ NSLocalizedDescriptionKey : @"The server understood the request, but is refusing to fulfill it." }];
}

+ (NSError *)HTTPError409Conflict
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:409
                           userInfo:@{ NSLocalizedDescriptionKey : @"The request could not be completed due to a conflict with the current state of the resource." }];
}

+ (NSError *)HTTPError500InternalServer
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:500
                           userInfo:@{ NSLocalizedDescriptionKey : @"The server encountered an unexpected condition which prevented it from fulfilling the request." }];
}

@end
