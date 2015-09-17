//
//  OriginateHTTPLogging.h
//  PeerStars
//
//  Created by Allen Wu on 5/17/15.
//  Copyright (c) 2015 Originate. All rights reserved.
//

@import Foundation;

@protocol OriginateHTTPLogging <NSObject>

- (NSString *)URI;
- (id)responseObject;

@end
