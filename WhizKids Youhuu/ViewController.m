


#import "ViewController.h"
#import "AccessApi.h"
#import "ProgressHUD.h"
#import "DBManager.h"
#import "CustomCell.h"
#import "YouTubePlayerViewController.h"
#import "Support.h"

@interface ViewController (){
    int REQ_CODE;
    NSArray *nsDictVideoList;
    ProgressHUD *loader;
    BOOL isResponseNil;
    
    float viewWidth;
    float scrollViewWidth;
    float scrollViewX;
    int setVideoIndex;
    
    NSArray *arrayOfImages;
    int pos;
    NSString *url;
    NSArray *array;
    NSArray *urlArray;
    NSString *videoIDatIndex;
        

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    VideosListArray=[[NSArray alloc] init];
  
    
    isResponseNil=true;
    REQ_CODE=221;
    NSDictionary *parameters;
    parameters = @{};
    NSArray *VideosListArray;
    
    VideosListArray=[[DBManager getSharedInstance] getAllVideos];
    if([VideosListArray count]<1){
        
        [self showLoadingMode];
        [[NSUserDefaults standardUserDefaults] setInteger:40 forKey:@"APIIndex"];
        
        int *apiIndex =[[NSUserDefaults standardUserDefaults] integerForKey:@"APIIndex"];
        NSString *url= [NSString stringWithFormat:@"http://54.179.149.254/api/v1/content/listing/%d/",apiIndex];
        [[[AccessApi alloc] initWithDelegate:self url:url  parameters:parameters reqCode:REQ_CODE] execute];
        apiIndex++;
        [[NSUserDefaults standardUserDefaults] setInteger:apiIndex forKey:@"APIIndex"];
        
        
    }else{
        [self getDataFromDB];
        [self loadCollectionView];
        
  
        
    }
 
    
    
}


-(void)loadCollectionView{
    [[self myCollectionView]setDataSource:self];
    [[self myCollectionView]setDelegate:self];
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.myCollectionView.collectionViewLayout = collectionViewFlowLayout;
    
    self.myCollectionView.pagingEnabled = NO;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(193, 193);
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    self.myCollectionView.collectionViewLayout = flow;
    
    
    arrayOfImages = [[NSArray alloc] initWithObjects:@"engine_1.png", @"green_boggy.png", @"yellow_boggy.png", @"blue_boggy.png",@"green_boggy.png", @"guard_boggy.png",nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
    
    
    
    
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [arrayOfImages count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    
    static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    //
    //    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    //    imgView.contentMode = UIViewContentModeScaleAspectFit;
    //    imgView.clipsToBounds = YES;
    //    imgView.image = [arrayOfImages objectAtIndex:indexPath.row];
    //    [cell addSubview:imgView];
    cell.myImage.image = [UIImage imageNamed:[arrayOfImages objectAtIndex:indexPath.item]];
    
    if(indexPath.row==0){
        cell.ivWheel.hidden=YES;
        cell.ivSecondWheel.hidden=YES;
    }
    if(indexPath.row == 0 || indexPath.row == 5){
        cell.thumbnailImageView.hidden =YES;
        cell.ivPlayButton.hidden=YES;
        cell.btthumbnailOutlet.userInteractionEnabled=NO;
       
        setVideoIndex= 0;
    }else{
        
        int indexValue = (int)indexPath.row-1;
        
        NSString *stringUrl = videoArray[indexValue][@"url"];
        array = [stringUrl componentsSeparatedByString:@"="];
        NSURL *ThumbnailUrl;
        if([array count]>1){
            NSString *stringurl =[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",[array objectAtIndex:1]];
            ThumbnailUrl=[NSURL URLWithString:stringurl];
              NSLog(@"%@",ThumbnailUrl);

        }else{
            ThumbnailUrl=[NSURL URLWithString:@"http://www.wi-fi.org/sites/all/themes/wfa/assets/images/video-thumbnail-overlay.png"];
        }
    

        setVideoIndex++;
        cell.thumbnailImageView.imageneryURL=ThumbnailUrl;
         [cell.btthumbnailOutlet addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        int tag= (int) indexPath.row;//[videoArray[setVideoIndex][@"_id"] intValue];
        cell.btthumbnailOutlet.tag=tag;
    }
    
    //[[cell myImage]setImage:[UIImage imageNamed:[arrayOfImages objectAtIndex:indexPath.item]]];
    // [[cell myImage]setImage:[UIImage imageNamed:@"1.png"]];
    // cell.transform = self.myCollectionView.transform;
    
    
    return cell;
    
    
}

- (void)addTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
    
}
- (void)nextPage
{
    // 1.back to the middle of sections
    NSIndexPath *currentIndexPathReset = [self resetIndexPath];
    
    // 2.next position
    NSInteger nextItem = currentIndexPathReset.item + 1;
    NSInteger nextSection = currentIndexPathReset.section;
    if (nextItem > arrayOfImages.count) {
        //        nextItem = nextItem-1;
        [self removeTimer];
        
        //        nextSection++;
        
    }else if (nextItem == arrayOfImages.count){
        nextItem = nextItem-1;
        
    }
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextItem inSection:nextSection];
    
    // 3.scroll to next position
    [self.myCollectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
    //    if (nextItem == arrayOfImages.count) {
    //        [self removeTimer];
    //
    //    }
}
- (NSIndexPath *)resetIndexPath
{
    // currentIndexPath
    NSIndexPath *currentIndexPath = [[self.myCollectionView indexPathsForVisibleItems] lastObject];
    // back to the middle of sections
    //    NSIndexPath *currentIndexPathReset = [NSIndexPath indexPathForItem:currentIndexPath.item inSection:1];
    [self.myCollectionView scrollToItemAtIndexPath:currentIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    return currentIndexPath;
}

- (void)removeTimer
{
    // stop NSTimer
    [self.timer invalidate];
    // clear NSTimer
    self.timer = nil;
}

// UIScrollView' delegate method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //    [self addTimer];
    
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top, left, bottom, right
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //return CGSizeMake( self.view.frame.size.width / 3, 140);
    return CGSizeMake( 193, 193);
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // pos represents previous or initial position
    // indexPath represents clicked cell position
    
    if(indexPath.row > pos)
    {
        if (indexPath.row - pos == 2) {
            pos = pos + 1;
        }
        [self changeDate];
    }
    else if (indexPath.row == pos)
    {
        
       
        NSLog(@"Do Nothing");
    }
    else
    {
        if (indexPath.row + 2 == pos) {
            pos = pos - 1;
        }
        [self changeDate1];
    }
    //NSLog(@"%@",[arrDate objectAtIndex:indexPath.row]);
}

-(void)changeDate
{
    if (pos<(arrayOfImages.count - 2)) {
        pos=pos+1;
        [self.myCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:pos inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        NSLog(@"%@",[arrayOfImages objectAtIndex:pos]);
        //self.lblMovieName.text =[arrayOfImages objectAtIndex:pos];
    }
}
-(void)changeDate1
{
    if(pos>2)
    {
        pos=pos-1;
        [self.myCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:pos inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        NSLog(@"%@",[arrayOfImages objectAtIndex:pos]);
        //self.lblMovieName.text =[arrayOfImages objectAtIndex:pos];
    }
    else{
        
    }
}
-(void)getDataFromDB{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int firstIndex = (int)[defaults integerForKey:@"firstIndex"];
    int lastIndex = (int)[defaults integerForKey:@"lastIndex"];
    
    videoArray = [[DBManager getSharedInstance] get4VideobasedOnIndex:firstIndex andLastIndex:lastIndex];
    NSLog(@"%@",videoArray);
    setVideoIndex = 0;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

//- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
//{
//    //generate 100 item views
//    //normally we'd use a backing array
//    //as shown in the basic iOS example
//    //but for this example we haven't bothered
//    return 6;
//}


- (void)playVideo:(UIButton*)button
{
    
    int buttonTag = (int)button.tag;
    NSLog(@"Button  clicked. %d",buttonTag);
    
    url= videoArray[buttonTag][@"url"];
    
    NSString *currentIndexValue = [NSString stringWithFormat:@"%@",videoArray[buttonTag][@"_id"]];
    
    videoIDatIndex = currentIndexValue;
    
    
    urlArray = [url componentsSeparatedByString:@"="];
    //NSString *stringurl =[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",[array objectAtIndex:1]];
  //  NSURL *url=[NSURL URLWithString:stringurl];
    //NSLog(@"%@",url);

    
    
   BOOL isUpdate =  [[DBManager getSharedInstance] updateIntoVideos:[currentIndexValue intValue]];
    
    if(isUpdate){
        NSLog(@"Update");
    }else{
        NSLog(@"Unable To Update");
    }
  
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int lastIndex =(int) [defaults integerForKey:@"lastIndex"];
    lastIndex++;
    [defaults setInteger:lastIndex forKey:@"lastIndex"];
    [self performSegueWithIdentifier:@"playerfromview" sender:self];
   // [self getDataFromDB];
    
    
//    setVideoIndex = 0;
//
//    [self.myCollectionView reloadData];
    
  }

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"playerfromview"]){
        
        YouTubePlayerViewController *controller=segue.destinationViewController;
        controller.url=[urlArray objectAtIndex:1];
        controller.dbId= videoIDatIndex;
        
        
    }
}



-(void) onDone:(int)statusCode andData:(NSData *)data andReqCode:(int)reqCode{
    
    
    
    if (data == nil)
    {
        
        [self hideLoadingMode];
        [Support showAlert:NSLocalizedString(@"Please check Internet Connection.", nil)];

        
    }else
    {
        if (data == nil)
        {
            
            if(isResponseNil){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                     
                     [self hideLoadingMode];
                     [Support showAlert:NSLocalizedString(@"Please check Internet Connection.", nil)];

                     isResponseNil =false;
                     
                 }];
            }
            
        }else
        {
            
            
            switch (reqCode) {
                case 221:
                    if(reqCode==221){
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^
                         {
                             
                             
                             //                     NSMutableDictionary *object;
                             nsDictVideoList = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                             NSLog(@"%@",nsDictVideoList);
                             [self insertIntoDatabase];
                             [self hideLoadingMode];
                             
                             [self getDataFromDB];
                             [self loadCollectionView];
                             setVideoIndex = 0;

                             [self.myCollectionView reloadData];

                             
                             
                         }];
                    }
                    break;
                    
                    
                    
                    
            }
            
        }}
    
    
}

-(void)insertIntoDatabase{
    
    for(int i=0;i<[nsDictVideoList count];i++){
        
        int api_id=(int)nsDictVideoList[i][@"id"];
        
        NSString *title=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"title"]];
        NSString *urlFromDb=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"url"]];
        NSString *min_age=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"min_age"]];
        NSString *max_age=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"max_age"]];
        NSString *description=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"desc"]];
        NSString *channel=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"channel"]];
        NSString *length=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"length"]];
        NSString *num_views=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"num_views"]];
        NSString *rating=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"rating"]];
        NSString *pub_on_mon=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"pub_on_mon"]];
        NSString *pub_on_date=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"pub_on_date"]];
        NSString *status=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"status"]];
        NSString *category=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"category"]];
        NSString *theme=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"theme"]];
        NSString *subtheme=[NSString stringWithFormat:@"%@",nsDictVideoList[i][@"sub_theme"]];
        int isSeen=0;
        
        
        
        BOOL inserted=  [[DBManager getSharedInstance] insertIntoVideos:api_id andTitle:title andURL:urlFromDb andMIN_AGE:min_age andMAxAge:max_age andDescription:description andChannel:channel andLength:length andNUMViews:num_views andRating:rating andPUB_ON_MON:pub_on_mon andPubOnDate:pub_on_date andStatus:status andCategory:category andTHEME:theme andSUBTHEME:subtheme andISSeen:isSeen];
        
      
        NSLog(@"%d",inserted);
        
    }
    
}

-(void)showLoadingMode {
    loader = [[ProgressHUD alloc]init];
    [loader showHudProgress:self.view];
    
}

-(void)hideLoadingMode {
    
    
    [loader hideHudProgress];
}
- (IBAction)btTrafficLight:(id)sender {
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:2 delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.myCollectionView.frame  = CGRectMake(self.myCollectionView.frame.origin.x-1000, self.myCollectionView.frame.origin.y, width*2,self.myCollectionView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            int lastIndex =(int) [defaults integerForKey:@"lastIndex"];
            lastIndex = lastIndex + 4;
            
            [defaults setInteger:lastIndex forKey:@"lastIndex"];
            
            if(lastIndex>96){
         
                [defaults setInteger:0 forKey:@"firstIndex"];
                [defaults setInteger:10 forKey:@"lastIndex"];
                
            }
            
            [self getDataFromDB];
            setVideoIndex = 0;

            [self.myCollectionView reloadData];
            
            self.myCollectionView.frame  = CGRectMake(2000, self.myCollectionView.frame.origin.y, width,self.myCollectionView.frame.size.height);
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                
                //                self.myCollectionView.frame  = CGRectMake(self.myCollectionView.frame.origin.x, self.myCollectionView.frame.origin.y, self.myCollectionView.frame.size.width,self.myCollectionView.frame.size.height);
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:2.0 delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.myCollectionView.frame  = CGRectMake(0, self.myCollectionView.frame.origin.y, width,self.myCollectionView.frame.size.height);
                    
                } completion:^(BOOL finished) {
                    
                }];
                
            }];
            
            
        }];
        
    }];

    
    
    
    
}
- (IBAction)btHistoryAction:(id)sender {
    [self performSegueWithIdentifier:@"history" sender:self];
}
@end
