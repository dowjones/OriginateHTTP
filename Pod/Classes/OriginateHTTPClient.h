//
//  OriginateHTTPClient.h
//  OriginateHTTP
//
//  Created by Philip Kluz on 4/30/15.
//  Copyright (c) 2015 Originate. All rights reserved.
//

@import Foundation;

extern NSString * const OriginateHTTPClientResponseNotification;

typedef void (^OriginateHTTPClientResponse)(id response, NSError *error);

@protocol OriginateHTTPAuthorizedObject;

/// Lightweight HTTP client supporting the most common CRUDs.
@interface OriginateHTTPClient : NSObject

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSURL *baseURL;
@property (nonatomic, strong, readwrite) id<OriginateHTTPAuthorizedObject> authorizedObject;
@property (nonatomic, assign, readwrite) NSTimeInterval timeoutInterval;
@property (nonatomic, copy, readwrite) NSString *userAgent;

#pragma mark - Methods
- (instancetype)initWithBaseURL:(NSURL *)URL
               authorizedObject:(id<OriginateHTTPAuthorizedObject>)authorizedObject;


// GET
- (void)GETResource:(NSString *)URI
           response:(OriginateHTTPClientResponse)responseBlock;

- (void)GETResource:(NSString *)URI
  additionalHeaders:(NSDictionary *)additionalHeaders
           response:(OriginateHTTPClientResponse)responseBlock;


// POST

- (void)POSTResource:(NSString *)URI
             payload:(NSData *)body
            response:(OriginateHTTPClientResponse)responseBlock;

- (void)POSTResource:(NSString *)URI
   additionalHeaders:(NSDictionary *)additionalHeaders
             payload:(NSData *)body
            response:(OriginateHTTPClientResponse)responseBlock;


// PATCH

- (void)PATCHResource:(NSString *)URI
         deltaPayload:(NSData *)payload
             response:(OriginateHTTPClientResponse)responseBlock;

- (void)PATCHResource:(NSString *)URI
    additionalHeaders:(NSDictionary *)additionalHeaders
         deltaPayload:(NSData *)payload
             response:(OriginateHTTPClientResponse)responseBlock;


// PUT
- (void)PUTResource:(NSString *)URI
            payload:(NSData *)payload
           response:(OriginateHTTPClientResponse)responseBlock;

- (void)PUTResource:(NSString *)URI
  additionalHeaders:(NSDictionary *)additionalHeaders
            payload:(NSData *)payload
           response:(OriginateHTTPClientResponse)responseBlock;

// DELETE

- (void)DELETEResource:(NSString *)URI
              response:(OriginateHTTPClientResponse)responseBlock;

- (void)DELETEResource:(NSString *)URI
     additionalHeaders:(NSDictionary *)additionalHeaders
              response:(OriginateHTTPClientResponse)responseBlock;

@end
