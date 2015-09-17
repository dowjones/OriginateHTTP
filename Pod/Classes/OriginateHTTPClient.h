//
//  OriginateHTTPClient.h
//  OriginateHTTP
//
//  Created by Philip Kluz on 4/30/15.
//  Copyright (c) 2015 Originate. All rights reserved.
//

@import Foundation;

extern NSString* const OriginateHTTPClientResponseNotification;

typedef void (^OriginateHTTPClientResponse)(id response, NSError *error);

@protocol OriginateHTTPAuthorizedObject;

/// Lightweight HTTP client supporting the most common CRUDs.
@interface OriginateHTTPClient : NSObject

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSURL *baseURL;
@property (nonatomic, strong, readwrite) id<OriginateHTTPAuthorizedObject> authorizedObject;
@property (nonatomic, assign, readwrite) NSTimeInterval timeoutInterval;

#pragma mark - Methods
- (instancetype)initWithBaseURL:(NSURL *)URL
               authorizedObject:(id<OriginateHTTPAuthorizedObject>)authorizedObject;

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

@end
