


#import "DBManager.h"

#import "DBManager.h"
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;


@implementation DBManager

+(DBManager* )getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:DB_NAME]];
    
    BOOL isSuccess = YES;
    BOOL isSuccessConnected = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        NSLog(@"%s",dbpath);
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            
            
            
            if (sqlite3_exec(database, CREATE_TABLE_VIDEOS, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccessConnected = NO;
                NSLog(@"Failed to create table");
            }
            
           
            
            
            if(isSuccess && isSuccessConnected){
                isSuccess = YES;
                
            }
            else{
                isSuccess = NO;
                
            }
            
            
            sqlite3_close(database);
            return isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}
-(BOOL)insertIntoVideos:(int) api_id andTitle:(NSString *) title andURL:(NSString *) url andMIN_AGE:(NSString *) MinAge andMAxAge:(NSString *) MaxAge andDescription:(NSString *) description andChannel: (NSString *) channel andLength: (NSString *)length andNUMViews :(NSString *) numviews andRating :(NSString *) rating andPUB_ON_MON :(NSString *) pub_on_mon andPubOnDate:(NSString *) pub_on_date andStatus : (NSString *) status andCategory :(NSString *) category andTHEME:(NSString *) theme andSUBTHEME:(NSString *) sub_theme andISSeen:(int)isSeen{
    
    const char *dbpath = [databasePath UTF8String];
    NSLog(@"%s",dbpath);
    
    
    if(sqlite3_open(dbpath, &database)==SQLITE_OK){
        
        NSString *query;
        query = @"insert into Videos(api_id,Title,url,min_age,max_age,Description,channel,length,num_views,rating,pub_on_mon,pub_on_date,status,category,theme,sub_theme,isseen) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        const char *query_stmt = [query UTF8String];
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, api_id);
        sqlite3_bind_text(statement, 2, [title UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [url UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [MinAge UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [MaxAge UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [description UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [channel UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 8, [length UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 9, [numviews UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 10, [rating UTF8String],-1,SQLITE_TRANSIENT);

        
        sqlite3_bind_text(statement, 11, [pub_on_mon UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 12, [pub_on_date UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 13, [status UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 14, [category UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 15, [theme UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 16, [sub_theme UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 17, isSeen);
        
    
        
        if(sqlite3_step(statement)==SQLITE_DONE){
            
            sqlite3_finalize(statement);
            return YES;
        }else{
            NSLog(@"error: %s", sqlite3_errmsg(database));
            
            sqlite3_finalize(statement);
            return NO;
        }
        
    }
    return NO;
    
    }

-(BOOL)updateIntoVideos:(int)_id{
    

    
    const char *dbpath = [databasePath UTF8String];
    if(sqlite3_open(dbpath, &database)==SQLITE_OK){
        NSString *query =
        [NSString stringWithFormat:@"update Videos set isseen=1 where _id = \'%d\' ",_id];
        const char *query_stmt = [query UTF8String];
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
        if(sqlite3_step(statement)==SQLITE_DONE){
            return YES;
        }else{
            return NO;
        }
    }
    return NO;

}

-(NSArray *)get4VideobasedOnIndex:(int)firstIndex andLastIndex:(int)lastIndex{

    const char *dbpath = [databasePath UTF8String];
    
    NSLog(@"%s",dbpath);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"select * from Videos where (_id>%d and _id<%d)  and isseen = 0 ORDER BY _id desc ",firstIndex,lastIndex];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        BOOL res = sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) ;
        if (res == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                @try{
                    NSString *_id = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    NSString *api_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                    NSString *title = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                    NSString *url = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                    NSString *minage = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                    NSString *maxage = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)];
                    NSString *description = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)];
                    NSString *channel = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)];
                    NSString *length = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)];
                    NSString *num_views = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)];
                    NSString *rating = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)];
                    
                    NSString *pub_on_mon = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)];
                    NSString *pub_on_date = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)];
                    NSString *status = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)];
                    NSString *category = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)];
                    NSString *theme = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)];
                    NSString *subtheme = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)];
                    NSString *isSeen = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)];
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    
                    [dict setValue:_id forKey:ROW_ID];
                    [dict setValue:api_id forKey:API_ID];
                    [dict setValue:title forKey:TITLE];
                    [dict setValue:url forKey:URL];
                    [dict setValue:minage forKey:MIN_AGE];
                    [dict setValue:maxage forKey:MAX_AGE];
                    [dict setValue:description forKey:DESCRIPTION];
                    [dict setValue:channel forKey:CHANNEL];
                    [dict setValue:length forKey:LENGTH];
                    [dict setValue:num_views forKey:NUM_VIEWS];
                    [dict setValue:rating forKey:RATING];
                    [dict setValue:pub_on_mon forKey:PUB_ON_MON];
                    [dict setValue:pub_on_date forKey:PUB_ON_DATE];
                    [dict setValue:status forKey:STATUS];
                    [dict setValue:category forKey:CATEGORY];
                    [dict setValue:theme forKey:THEME];
                    
                    [dict setValue:subtheme forKey:SUB_THEME];
                    [dict setValue:isSeen forKey:ISSEEN];
                    [resultArray addObject:dict];
                }@catch(NSException *ex){
                    
                }
            }
            sqlite3_reset(statement);
            return resultArray;
            
            
        }
    }
    
    
    return nil;

}

-(NSArray *)get4VideobasedOnIndexHistory:(int)firstIndex andLastIndex:(int)lastIndex{
    
    const char *dbpath = [databasePath UTF8String];
    
    NSLog(@"%s",dbpath);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"select * from Videos where (_id>%d and _id<%d)   ORDER BY _id desc ",firstIndex,lastIndex];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        BOOL res = sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) ;
        if (res == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                @try{
                    NSString *_id = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    NSString *api_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                    NSString *title = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                    NSString *url = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                    NSString *minage = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                    NSString *maxage = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)];
                    NSString *description = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)];
                    NSString *channel = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)];
                    NSString *length = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)];
                    NSString *num_views = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)];
                    NSString *rating = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)];
                    
                    NSString *pub_on_mon = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)];
                    NSString *pub_on_date = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)];
                    NSString *status = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)];
                    NSString *category = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)];
                    NSString *theme = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)];
                    NSString *subtheme = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)];
                    NSString *isSeen = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)];
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    
                    [dict setValue:_id forKey:ROW_ID];
                    [dict setValue:api_id forKey:API_ID];
                    [dict setValue:title forKey:TITLE];
                    [dict setValue:url forKey:URL];
                    [dict setValue:minage forKey:MIN_AGE];
                    [dict setValue:maxage forKey:MAX_AGE];
                    [dict setValue:description forKey:DESCRIPTION];
                    [dict setValue:channel forKey:CHANNEL];
                    [dict setValue:length forKey:LENGTH];
                    [dict setValue:num_views forKey:NUM_VIEWS];
                    [dict setValue:rating forKey:RATING];
                    [dict setValue:pub_on_mon forKey:PUB_ON_MON];
                    [dict setValue:pub_on_date forKey:PUB_ON_DATE];
                    [dict setValue:status forKey:STATUS];
                    [dict setValue:category forKey:CATEGORY];
                    [dict setValue:theme forKey:THEME];
                    
                    [dict setValue:subtheme forKey:SUB_THEME];
                    [dict setValue:isSeen forKey:ISSEEN];
                    [resultArray addObject:dict];
                }@catch(NSException *ex){
                    
                }
            }
            sqlite3_reset(statement);
            return resultArray;
            
            
        }
    }
    
    
    return nil;
    
}

-(NSArray *)getAllVideos{
    
    const char *dbpath = [databasePath UTF8String];
    
    NSLog(@"%s",dbpath);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = @"select * from Videos  ORDER BY _id desc ";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        BOOL res = sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) ;
        if (res == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                @try{
                    NSString *_id = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    NSString *api_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                     NSString *title = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                     NSString *url = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                     NSString *minage = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                     NSString *maxage = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)];
                     NSString *description = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)];
                     NSString *channel = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)];
                    NSString *length = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)];
                     NSString *num_views = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)];
                     NSString *rating = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)];
                    
                    NSString *pub_on_mon = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)];
                    NSString *pub_on_date = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)];
                    NSString *status = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)];
                    NSString *category = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)];
                     NSString *theme = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)];
                     NSString *subtheme = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)];
                     NSString *isSeen = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)];
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    
                    [dict setValue:_id forKey:ROW_ID];
                    [dict setValue:api_id forKey:API_ID];
                    [dict setValue:title forKey:TITLE];
                    [dict setValue:url forKey:URL];
                    [dict setValue:minage forKey:MIN_AGE];
                    [dict setValue:maxage forKey:MAX_AGE];
                    [dict setValue:description forKey:DESCRIPTION];
                    [dict setValue:channel forKey:CHANNEL];
                    [dict setValue:length forKey:LENGTH];
                    [dict setValue:num_views forKey:NUM_VIEWS];
                    [dict setValue:rating forKey:RATING];
                    [dict setValue:pub_on_mon forKey:PUB_ON_MON];
                    [dict setValue:pub_on_date forKey:PUB_ON_DATE];
                    [dict setValue:status forKey:STATUS];
                    [dict setValue:category forKey:CATEGORY];
                    [dict setValue:theme forKey:THEME];
                
                    [dict setValue:subtheme forKey:SUB_THEME];
                    [dict setValue:isSeen forKey:ISSEEN];
                    [resultArray addObject:dict];
                }@catch(NSException *ex){
                    
                }
            }
            sqlite3_reset(statement);
            return resultArray;
            
            
        }
    }
    
    
    return nil;
    
}


-(NSArray *)getAllHistoryVideos{
    
    
    
    const char *dbpath = [databasePath UTF8String];
    
    NSLog(@"%s",dbpath);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = @"select * from Videos  where isseen = 1  ORDER BY _id desc ";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        BOOL res = sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) ;
        if (res == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                @try{
                    NSString *_id = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    NSString *api_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                    NSString *title = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                    NSString *url = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                    NSString *minage = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                    NSString *maxage = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)];
                    NSString *description = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)];
                    NSString *channel = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)];
                    NSString *length = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)];
                    NSString *num_views = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)];
                    NSString *rating = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)];
                    
                    NSString *pub_on_mon = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)];
                    NSString *pub_on_date = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)];
                    NSString *status = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)];
                    NSString *category = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)];
                    NSString *theme = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)];
                    NSString *subtheme = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)];
                    NSString *isSeen = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)];
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    
                    [dict setValue:_id forKey:ROW_ID];
                    [dict setValue:api_id forKey:API_ID];
                    [dict setValue:title forKey:TITLE];
                    [dict setValue:url forKey:URL];
                    [dict setValue:minage forKey:MIN_AGE];
                    [dict setValue:maxage forKey:MAX_AGE];
                    [dict setValue:description forKey:DESCRIPTION];
                    [dict setValue:channel forKey:CHANNEL];
                    [dict setValue:length forKey:LENGTH];
                    [dict setValue:num_views forKey:NUM_VIEWS];
                    [dict setValue:rating forKey:RATING];
                    [dict setValue:pub_on_mon forKey:PUB_ON_MON];
                    [dict setValue:pub_on_date forKey:PUB_ON_DATE];
                    [dict setValue:status forKey:STATUS];
                    [dict setValue:category forKey:CATEGORY];
                    [dict setValue:theme forKey:THEME];
                    
                    [dict setValue:subtheme forKey:SUB_THEME];
                    [dict setValue:isSeen forKey:ISSEEN];
                    [resultArray addObject:dict];
                }@catch(NSException *ex){
                    
                }
            }
            sqlite3_reset(statement);
            return resultArray;
            
            
        }
    }
    
    
    return nil;
    

    
}

@end
