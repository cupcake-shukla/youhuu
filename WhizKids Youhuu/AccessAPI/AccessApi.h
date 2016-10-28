//
//  AccessApi.h
//  HitService
//
//  Created by trend on 25/04/16.
//  Copyright © 2016 Trendsetterz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ApiDoneDelegate <NSObject>
@required
- (void) onDone:(int)statusCode andData:(NSData*) data andReqCode:(int) reqCode;
@end

@interface AccessApi : NSObject{
     id <ApiDoneDelegate> _delegate;

}
@property (nonatomic,strong) id delegate;
@property (nonatomic,strong) NSString* url;

@property (nonatomic,strong) NSString* data;
@property (nonatomic, strong) NSMutableData *myData;
@property (nonatomic, strong) NSDictionary *parameters;
@property  int reqCode;

-(id) initWithDelegate:(id) delegate url:(NSString *) url parameters:(NSDictionary *) parameters reqCode:(int) reqCode;
-(void) execute;
@end
