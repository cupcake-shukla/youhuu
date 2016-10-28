//
//  Support.h
//  State Election Commission
//
//  Created by admin on 28/06/16.
//  Copyright © 2016 TACT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CommonCrypto/CommonDigest.h>
#import "UIView+Toast.h"

@interface Support : NSObject

+(UIColor*)colorWithHexString:(NSString*)hex;
-(NSString *) convertDateFormate:(NSString *) dateString;
+(void) showAlert:(NSString *)msg;
+(void) showAlertWithDelegate:(id)delegate Msg:(NSString *)msg Tag:(int)tag PositiveButton:(NSString *)pButton NegativeButton:(NSString *)nButton;
+(void) showErrorFromResult:(NSData *) data;
+(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
+(void) showAlertWithDelegate:(id)delegate Msg:(NSString *)msg Tag:(int)tag PositiveButton:(NSString *)pButton;
+(void) showAlertInternetErrorWithTag503AndDelegateSelf:(id)delegate;

+(NSString *) getCurrentDate;
@end
