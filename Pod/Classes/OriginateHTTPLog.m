//
//  OriginateHTTPLog.m
//  PeerStars
//
//  Created by Allen Wu on 5/17/15.
//  Copyright (c) 2015 Originate. All rights reserved.
//

#import "OriginateHTTPLog.h"

@interface OriginateHTTPLog ()

@property (nonatomic, strong) NSURLResponse* urlResponse;
@property (nonatomic, strong) id responseObject;

@end

@implementation OriginateHTTPLog

- (instancetype)initWithURLResponse:(NSURLResponse *)urlResponse
                     responseObject:(id)responseObject
{
  self = [super init];
  if (self) {
    _urlResponse = urlResponse;
    _responseObject = responseObject;
  }
  return self;
}

#pragma mark - OriginateHTTPLogging

- (NSString *)URI
{
    return [[_urlResponse URL] relativePath];
}

- (id)responseObject
{
    return _responseObject;
}

@end
