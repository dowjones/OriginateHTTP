//
//  OriginateHTTPLog.h
//  PeerStars
//
//  Created by Allen Wu on 5/17/15.
//  Copyright (c) 2015 Originate. All rights reserved.
//

@import Foundation;

#import "OriginateHTTPLogging.h"

@interface OriginateHTTPLog : NSObject <OriginateHTTPLogging>

- (instancetype)initWithURLResponse:(NSURLResponse *)urlResponse
                     responseObject:(id)responseObject;

@end
