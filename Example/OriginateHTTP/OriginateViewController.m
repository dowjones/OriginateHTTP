//
//  OriginateViewController.m
//  OriginateHTTP
//
//  Created by Allen Wu on 09/16/2015.
//  Copyright (c) 2015 Allen Wu. All rights reserved.
//

#import "OriginateViewController.h"

@interface OriginateViewController ()

@end

@implementation OriginateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *URL = [NSURL URLWithString:@"https://www.apple.com/"];
    
    OriginateHTTPClient *httpClient = [[OriginateHTTPClient alloc] initWithBaseURL:URL
                                                                  authorizedObject:nil];
    
    [httpClient GETResource:@"robots.txt" response:^(id response, NSError *error) {
        NSLog(@"response = %@", response);
    }];
}

@end
