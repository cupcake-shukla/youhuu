


#import <Foundation/Foundation.h>
#import "sqlite3.h"

#define DB_NAME  @"WhizKids.sqlite"
#define ROW_ID @"_id"
#define API_ID @"api_id"
#define TITLE @"Title"
#define URL @"url"
#define MIN_AGE @"min_age"
#define MAX_AGE @"max_age"
#define DESCRIPTION @"Description"
#define CHANNEL @"channel"
#define LENGTH @"length"
#define NUM_VIEWS @"num_views"
#define RATING @"rating"
#define PUB_ON_MON @"pub_on_mon"
#define PUB_ON_DATE @"pub_on_date"
#define STATUS @"status"
#define CATEGORY @"category"

#define THEME @"theme"
#define SUB_THEME @"sub_theme"
#define ISSEEN @"isseen"


#define TAG @"WhizKids-DB"
// KP Info Table Constants

//#define TABLE_VIDEOS @"Videos"


#define CREATE_TABLE_VIDEOS  "create table if not exists Videos (_id integer primary key autoincrement,api_id integer,Title text,url text,min_age text,max_age text,Description text,channel text,length text,num_views text,rating text,pub_on_mon text,pub_on_date text,status text,category text,theme text,sub_theme text,isseen int)"


@interface DBManager : NSObject{
    
    NSString *databasePath;
    
}



+(DBManager* )getSharedInstance;


-(BOOL)createDB;
-(BOOL)insertIntoVideos:(int) api_id andTitle:(NSString *) title andURL:(NSString *) url andMIN_AGE:
(NSString *) MinAge andMAxAge:(NSString *) MaxAge andDescription:(NSString *) description andChannel: (NSString *) channel andLength: (NSString *)length andNUMViews :(NSString *) numviews andRating :(NSString *) rating andPUB_ON_MON :(NSString *) pub_on_mon andPubOnDate:(NSString *) pub_on_date andStatus : (NSString *) status andCategory :(NSString *) category andTHEME:(NSString *) theme andSUBTHEME:(NSString *) sub_theme andISSeen:(int)isSeen;
-(BOOL)updateIntoVideos:(int) _id;
-(NSArray *)getAllVideos;
-(NSArray *)getAllHistoryVideos;
-(NSArray *)get4VideobasedOnIndex:(int)firstIndex andLastIndex:(int)lastIndex;

-(NSArray *)get4VideobasedOnIndexHistory:(int)firstIndex andLastIndex:(int)lastIndex;
    
@end
