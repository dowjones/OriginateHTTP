//
//  OriginateHTTPAuthorizedObject.h
//  OriginateHTTP
//
//  Created by Philip Kluz on 5/6/15.
//  Copyright (c) 2015 Originate. All rights reserved.
//

@import Foundation;

@protocol OriginateHTTPAuthorizedObject <NSObject>

- (NSDictionary *)authorizationHeader;

@end
