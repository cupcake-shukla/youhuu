//
//  Support.m
//  State Election Commission
//
//  Created by admin on 28/06/16.
//  Copyright © 2016 TACT. All rights reserved.
//

#import "Support.h"




@implementation Support

+(NSString *) getCurrentDate{
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@", stringDate);
    
    stringDate = [stringDate stringByReplacingOccurrencesOfString:@" "
                                                       withString:@"T"];
    stringDate = [NSString stringWithFormat:@"%@Z",stringDate];
    
    return stringDate;
}

+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}



-(NSString *) convertDateFormate:(NSString *) dateString{
    
    NSString *str = dateString;
    NSArray *Array = [str componentsSeparatedByString:@"T"];
    dateString= [Array objectAtIndex:0];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDate *dateFromString = [[NSDate alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *stringDate = [dateFormatter stringFromDate:dateFromString];
    NSLog(@"%@", stringDate);
    
    return stringDate;
}


+(void) showAlert:(NSString *)msg{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alertView show];
     }];
}
+(void) showAlertInternetErrorWithTag503AndDelegateSelf:(id)delegate{
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^
//     {
         UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"" message:@"Please check Internet Connection./इंटरनेट कनेक्शन की जांच करें।" delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alertView.tag = 503;
         [alertView show];
//     }];
}

+(void) showAlertWithDelegate:(id)delegate Msg:(NSString *)msg Tag:(int)tag PositiveButton:(NSString *)pButton{
    
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:delegate cancelButtonTitle:pButton otherButtonTitles:nil];
    alertView.tag=tag;
    [alertView show];
    
}

+(void) showAlertWithDelegate:(id)delegate Msg:(NSString *)msg Tag:(int)tag PositiveButton:(NSString *)pButton NegativeButton:(NSString *)nButton{
    
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:delegate cancelButtonTitle:nButton otherButtonTitles:pButton, nil];
    alertView.tag=tag;
    [alertView show];
    
}

+(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

+(void) showErrorFromResult:(NSData *) data{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         @try{
             NSMutableDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
             if ([object objectForKey:@"Message" ] !=[NSNull null]) {
                 [Support showAlert:object[@"Message"]];
             }else{
                 [Support showAlert:@"Please check internet"];
             }
         }@catch(NSException *ex){
             [Support showAlert:@"Please check internet"];
         }
     }];
}



@end
