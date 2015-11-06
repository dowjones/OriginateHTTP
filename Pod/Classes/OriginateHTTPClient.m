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

NSString * const OriginateHTTPClientResponseNotification = @"com.originate.http-client.response";

#define EXEC_BLOCK_SAFELY(block, ...) (block ? block(__VA_ARGS__) : nil)
#define EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(block, ...) if (block) { dispatch_async(dispatch_get_main_queue(), ^{ block(__VA_ARGS__); }); }

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
        _timeoutInterval = 45.0;
    }

    return _timeoutInterval;
}

- (NSString *)userAgent
{
    if (!_userAgent) {
        _userAgent = @"OriginateHTTP/0.1 (iPhone; iOS 8_0+)";
    }
    
    return _userAgent;
}

- (NSDictionary *)baseHeaders
{
    NSDictionary *authorizationHeader = [self.authorizedObject authorizationHeader];
    NSMutableDictionary *headers = [@{ @"User-Agent" : self.userAgent,
                                       @"Accept" : @"application/json",
                                       @"Content-Type" : @"application/json" } mutableCopy];
    [headers addEntriesFromDictionary:authorizationHeader];
    
    return [headers copy];
}

- (NSDictionary *)baseHeadersWithAdditionalHeaders:(NSDictionary *)additional
{
    if (additional.count == 0) {
        return self.baseHeaders;
    }
    
    NSMutableDictionary *headers = [self.baseHeaders mutableCopy];
    [headers addEntriesFromDictionary:additional];
    return [headers copy];
}

- (NSURLSessionConfiguration *)sessionConfigurationWithHeaders:(NSDictionary *)headers
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.HTTPAdditionalHeaders = headers;
    return configuration;
}

#pragma mark - OriginateHTTPClient (API)

// GET

- (void)GETResource:(NSString *)URI
           response:(OriginateHTTPClientResponse)responseBlock
{
    [self GETResource:URI additionalHeaders:nil response:responseBlock];
}

- (void)GETResource:(NSString *)URI
  additionalHeaders:(NSDictionary *)additionalHeaders
           response:(OriginateHTTPClientResponse)responseBlock
{
    NSDictionary *headers = [self baseHeadersWithAdditionalHeaders:additionalHeaders];
    NSURLSessionConfiguration *config = [self sessionConfigurationWithHeaders:headers];

    [[self class] GETResource:URI
                      baseURL:self.baseURL
                       config:config
                      timeout:self.timeoutInterval
                     response:^(id resource, NSError *error)
     {
         EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(responseBlock, resource, error);
     }];
}

// POST

- (void)POSTResource:(NSString *)URI
             payload:(NSData *)body
            response:(OriginateHTTPClientResponse)responseBlock
{
    [self POSTResource:URI additionalHeaders:nil payload:body response:responseBlock];
}

- (void)POSTResource:(NSString *)URI
   additionalHeaders:(NSDictionary *)additionalHeaders
             payload:(NSData *)body
            response:(OriginateHTTPClientResponse)responseBlock
{
    NSDictionary *headers = [self baseHeadersWithAdditionalHeaders:additionalHeaders];
    NSURLSessionConfiguration *config = [self sessionConfigurationWithHeaders:headers];

    [[self class] POSTResource:URI
                       baseURL:self.baseURL
                        config:config
                       timeout:self.timeoutInterval
                       payload:body
                      response:^(id resource, NSError *error)
     {
         EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(responseBlock, resource, error);
     }];
}

// PATCH

- (void)PATCHResource:(NSString *)URI
         deltaPayload:(NSData *)payload
             response:(OriginateHTTPClientResponse)responseBlock
{
    [self PATCHResource:URI additionalHeaders:nil deltaPayload:payload response:responseBlock];
}

- (void)PATCHResource:(NSString *)URI
    additionalHeaders:(NSDictionary *)additionalHeaders
         deltaPayload:(NSData *)body
             response:(OriginateHTTPClientResponse)responseBlock
{
    NSDictionary *headers = [self baseHeadersWithAdditionalHeaders:additionalHeaders];
    NSURLSessionConfiguration *config = [self sessionConfigurationWithHeaders:headers];
    
    [[self class] PATCHResource:URI
                        baseURL:self.baseURL
                         config:config
                        timeout:self.timeoutInterval
                        payload:body
                       response:^(id resource, NSError *error)
     {
         EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(responseBlock, resource, error);
     }];
}

// PUT

- (void)PUTResource:(NSString *)URI
            payload:(NSData *)payload
           response:(OriginateHTTPClientResponse)responseBlock
{
    [self PUTResource:URI additionalHeaders:nil payload:payload response:responseBlock];
}

- (void)PUTResource:(NSString *)URI
  additionalHeaders:(NSDictionary *)additionalHeaders
            payload:(NSData *)payload
           response:(OriginateHTTPClientResponse)responseBlock
{
    NSDictionary *headers = [self baseHeadersWithAdditionalHeaders:additionalHeaders];
    NSURLSessionConfiguration *config = [self sessionConfigurationWithHeaders:headers];
    
    [[self class] PUTResource:URI
                      baseURL:self.baseURL
                       config:config
                      timeout:self.timeoutInterval
                      payload:payload
                     response:^(id resource, NSError *error)
     {
         EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(responseBlock, resource, error);
     }];
}

// DELETE

- (void)DELETEResource:(NSString *)URI
              response:(OriginateHTTPClientResponse)responseBlock
{
    [self DELETEResource:URI additionalHeaders:nil response:responseBlock];
}

- (void)DELETEResource:(NSString *)URI
     additionalHeaders:(NSDictionary *)additionalHeaders
              response:(OriginateHTTPClientResponse)responseBlock
{
    NSDictionary *headers = [self baseHeadersWithAdditionalHeaders:additionalHeaders];
    NSURLSessionConfiguration *config = [self sessionConfigurationWithHeaders:headers];
    
    [[self class] DELETEResource:URI
                         baseURL:self.baseURL
                          config:config
                         timeout:self.timeoutInterval
                        response:^(id resource, NSError *error)
     {
         EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(responseBlock, resource, error);
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                       timeoutInterval:timeout];
    [request setHTTPMethod:@"GET"];
    
    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *responseError)
            {
                [[self class] handleResponse:response
                                        data:data
                                       error:responseError
                      evaluateLocationHeader:NO
                                  completion:responseBlock];
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
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:payload];
    
    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *responseError)
            {
                [[self class] handleResponse:response
                                        data:data
                                       error:responseError
                      evaluateLocationHeader:YES
                                  completion:responseBlock];
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
    [request setHTTPMethod:@"PATCH"];
    [request setHTTPBody:body];
    
    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *responseError)
            {
                [[self class] handleResponse:response
                                        data:data
                                       error:responseError
                      evaluateLocationHeader:NO
                                  completion:responseBlock];
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
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:body];

    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *responseError)
            {
                [[self class] handleResponse:response
                                        data:data
                                       error:responseError
                      evaluateLocationHeader:NO
                                  completion:responseBlock];
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
                [[self class] handleResponse:response
                                        data:data
                                       error:responseError
                      evaluateLocationHeader:NO
                                  completion:responseBlock];
            }];
    
    [task resume];
}

+ (void)handleResponse:(NSURLResponse *)response
                  data:(NSData *)data
                 error:(NSError *)responseError
evaluateLocationHeader:(BOOL)evaluateLocationHeader
            completion:(OriginateHTTPClientResponse)responseBlock
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSError *error = [self errorForResponse:HTTPResponse connectionError:responseError];
    NSString *rawResponseString = data.length > 0 ? [[NSString alloc] initWithData:data
                                                                          encoding:NSUTF8StringEncoding] : nil;
    id result = rawResponseString;
    
    OriginateHTTPLog *log = [[OriginateHTTPLog alloc] initWithURLResponse:response
                                                           responseObject:result];
    [[NSNotificationCenter defaultCenter] postNotificationName:OriginateHTTPClientResponseNotification
                                                        object:log];
    
    if (!responseBlock) {
        return;
    }
    
    if (error || HTTPResponse.statusCode < 200 || HTTPResponse.statusCode > 299) {
        EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(responseBlock, rawResponseString, error);
        return;
    }
    
    if (data.length == 0) {
        if ([[self class] emptyBodyAcceptableForHTTPResponse:HTTPResponse]) {
            EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(responseBlock, nil, nil);
        }
        else {
            EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(responseBlock, nil, [self errorEmptyResponse]);
        }
        return;
    }
    
    if (([HTTPResponse.allHeaderFields[@"Content-Type"] containsString:@"application/json"] ||
         [HTTPResponse.allHeaderFields[@"Content-Type"] containsString:@"application/vnd.api+json"]) &&
        data.length > 0) {
        result = [NSJSONSerialization JSONObjectWithData:data
                                                 options:NSJSONReadingAllowFragments
                                                   error:&error];
        
        if (error) {
            error = [[self class] errorDecodingJSON];
        }
    }
    else {
        result = [[NSString alloc] initWithData:data
                                       encoding:NSUTF8StringEncoding];
    }
    
    if (evaluateLocationHeader) {
        NSString *resourceLocation = HTTPResponse.allHeaderFields[@"Location"];
        
        // Prefer the body (if present) over the location header.
        result = result ?: resourceLocation;
    }
    
    EXEC_BLOCK_SAFELY_ON_MAIN_QUEUE(responseBlock, result, error);
}

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
    else if (responseError.code == kCFURLErrorTimedOut) {
        error = [[self class] errorTimeout];
    }
    else {
        error = [[self class] HTTPErrorForCode:statusCode
                           withUnderlyingError:responseError];
    }
    
    return error;
}

+ (NSString *)errorDomain
{
    return @"com.originate.networking";
}

+ (NSError *)errorEmptyResponse
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:3
                           userInfo:@{ NSLocalizedDescriptionKey : @"The response was empty." }];
}

+ (NSError *)errorDecodingJSON
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:2
                           userInfo:@{ NSLocalizedDescriptionKey : @"The server's response cannot be processed (Invalid JSON)." }];
}

+ (NSError *)errorTimeout
{
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:kCFURLErrorTimedOut
                           userInfo:@{ NSLocalizedDescriptionKey : @"The request timed out. Please check your internet connection." }];
}

+ (NSError *)HTTPErrorForCode:(NSUInteger)code withUnderlyingError:(NSError *)error
{
    NSString *descriptionForErrorCode = [[self class] descriptionForErrorCode:code];
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : descriptionForErrorCode };
    
    if (error) {
        userInfo = @{ NSLocalizedDescriptionKey : descriptionForErrorCode,
                      @"underlyingError" : error };
    }
    
    return [NSError errorWithDomain:[[self class] errorDomain]
                               code:code
                           userInfo:userInfo];
}

+ (NSString *)descriptionForErrorCode:(NSUInteger)code
{
    switch (code) {
        case 400:
            return @"The request could not be understood by the server due to malformed syntax.";
        case 401:
            return @"The request requires user authentication.";
        case 403:
            return @"The server understood the request, but is refusing to fulfill it.";
        case 409:
            return @"The request could not be completed due to a conflict with the current state of the resource.";
        case 500:
            return @"The server encountered an unexpected condition which prevented it from fulfilling the request.";
        default:
            return @"An unknown error occured";
    }
}

@end
