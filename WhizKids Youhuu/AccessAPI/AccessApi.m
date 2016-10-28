//
//  AccessApi.m
//  HitService
//
//  Created by trend on 25/04/16.
//  Copyright © 2016 Trendsetterz. All rights reserved.
//

#import "AccessApi.h"

@implementation AccessApi

-(id)initWithDelegate:(id)deleg url:(NSString *)url parameters:(NSDictionary *)parameters reqCode:(int) reqCode{
    self = [self init];
    self.delegate = deleg;
    self.url = url;
    self.parameters = parameters;
    self.reqCode = reqCode;
    return self;
}

-(void) execute{
    NSDictionary *headers = @{ @"content-type": @"application/json; charset=utf-8",
                               @"auth-token": @"e144sd5f45d6s4df4l45hucb16d0-76dfs54dfd556fdsfds655c-454afsdf44545dsf45fasdf545-acd83-b698fadsfa56s78tye848fcdf3",
                               @"cache-control": @"no-cache",
                               @"postman-token": @"6173f63a-0664-5360-38ed-bc9c387a5aac" };
    
    
    if(self.reqCode == 221){
        headers = @{ @"cache-control": @"no-cache",
                     @"postman-token": @"a1d02601-594a-4320-b86b-f8ee2c6737f0" };
    
    }
    
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:self.parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setAllHTTPHeaderFields:headers];
    
    if(self.reqCode == 221){
        [request setHTTPMethod:@"GET"];
        
    }else{
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];
        
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                        if(self.delegate!=NULL){
                                                            [self.delegate onDone:0 andData:nil andReqCode:self.reqCode];
                                                        }
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        if(self.delegate!=NULL){
                                                            int statusCode = (int)httpResponse.statusCode;
                                                            [self.delegate onDone:statusCode andData:data andReqCode:self.reqCode];
                                                        }
                                                    }
                                                }];
    [dataTask resume];

    
}


@end
