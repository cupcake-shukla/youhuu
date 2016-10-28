

#import "YouTubePlayerViewController.h"
#import "ProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "MPMoviePlayerController+BackgroundPlayback.h"
#import "TactImageView.h"
#import "CustomCell.h"
#import "DBManager.h"


@interface YouTubePlayerViewController (){
    
    ProgressHUD *loader;
    NSArray *arrayOfImages;
    int pos;
    NSString *url;
    NSArray *array;
    NSArray *urlArray;
    NSArray *VideosListArray;
    int setVideoIndex;
    int collectionViewCount;
    BOOL isFromSuggestion;

  
}
@property (weak, nonatomic) IBOutlet TactImageView *imageView1;
@property (weak, nonatomic) IBOutlet TactImageView *imageView2;
@property (weak, nonatomic) IBOutlet TactImageView *imageView3;
@property (weak, nonatomic) IBOutlet TactImageView *imageView4;

//@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
//@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;

@end

@implementation YouTubePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFromSuggestion = false;
  
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.url];
    videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlayVideoInBackground"];

    videoPlayerViewController.preferredVideoQualities = @[ @(XCDYouTubeVideoQualityMedium360)] ; //nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayerViewController.moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
    
    [self loadCollectionView];
    
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
    
    
    arrayOfImages = [[NSArray alloc] initWithObjects:@"engine_1.png", @"green_boggy", @"yellow_boggy.png", @"blue_boggy.png",@"green_boggy", @"guard_boggy.png",nil];

    collectionViewCount = 0;
}





-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return collectionViewCount;
    
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
    
    if(indexPath.row == 0){
        cell.ivWheel.hidden=YES;
        cell.ivSecondWheel.hidden=YES;
    }
    if(indexPath.row == 0 || indexPath.row == 5){
        cell.thumbnailImageView.hidden =YES;
        cell.ivPlayButton.hidden=YES;
        cell.btthumbnailOutlet.userInteractionEnabled=NO;
        setVideoIndex= 0;
    }else{
        
      
     
        
[cell.btthumbnailOutlet addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        
      
        
        int indexValue =(int) indexPath.row-1;

        int tag= (int)indexPath.row;
        cell.btthumbnailOutlet.tag=tag;
        int currentIndex=[self.dbId intValue];
        int NextIndex= currentIndex + 5;
        if(NextIndex >100){
            currentIndex = 0;
            NextIndex = 20;
        }
        
        
        
        NSArray *arrayFromDb=[[DBManager getSharedInstance] get4VideobasedOnIndexHistory:currentIndex andLastIndex:NextIndex];
        NSString *stringUrl1 =arrayFromDb[indexPath.row-1][@"url"];
        NSArray *urlarray1 = [stringUrl1 componentsSeparatedByString:@"="];
        NSString *stringurl1 =[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",[urlarray1 objectAtIndex:1]];
        
        cell.thumbnailImageView.imageneryURL = [NSURL URLWithString:stringurl1];

        
        if(currentIndex<96){
            
            NSArray *arrayFromDb=[[DBManager getSharedInstance] get4VideobasedOnIndexHistory:currentIndex andLastIndex:NextIndex];
            NSString *stringUrl1 =arrayFromDb[indexPath.row-1][@"url"];
            NSArray *urlarray1 = [stringUrl1 componentsSeparatedByString:@"="];
            NSString *stringurl1 =[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",[urlarray1 objectAtIndex:1]];
      
            cell.thumbnailImageView.imageneryURL = [NSURL URLWithString:stringurl1];
            
        }else{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    
    
    return cell;
    
    
}



- (void)playVideo:(UIButton*)button
{
    
//    int buttonTag = (int)button.tag;
//    NSLog(@"Button  clicked. %d",buttonTag);
//    url= VideosListArray[buttonTag][@"url"];
//    NSString *currentIndexValue = [NSString stringWithFormat:@"%@",VideosListArray[buttonTag][@"_id"]];
//    urlArray = [url componentsSeparatedByString:@"="];
//    BOOL isUpdate =  [[DBManager getSharedInstance] updateIntoVideos:[currentIndexValue intValue]];
//    
//    if(isUpdate){
//        NSLog(@"Update");
//    }else{
//        NSLog(@"Unable To Update");
//    }
    
    int indexValue =(int)button.tag;
    indexValue--;
    int currentIndex=[self.dbId intValue];
    int NextIndex= currentIndex + 5;
    if(NextIndex >100){
        currentIndex = 0;
        NextIndex = 20;
    }
    
    
    
    NSArray *arrayFromDb=[[DBManager getSharedInstance] get4VideobasedOnIndexHistory:currentIndex andLastIndex:NextIndex];
    NSString *stringUrl1 =arrayFromDb[indexValue][@"url"];
    
    NSArray *urlarray1 = [stringUrl1 componentsSeparatedByString:@"="];
    NSString *stringurl1 =[NSString stringWithFormat:@"%@",[urlarray1 objectAtIndex:1]];
    
    
    
    
    isFromSuggestion= TRUE;
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:stringurl1];
    videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlayVideoInBackground"];
    
    videoPlayerViewController.preferredVideoQualities = @[ @(XCDYouTubeVideoQualityMedium360)] ; //nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayerViewController.moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int lastIndex =(int) [defaults integerForKey:@"lastIndex"];
    lastIndex++;
    [defaults setInteger:lastIndex forKey:@"lastIndex"];

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
    
    
    
//    int indexValue =(int) indexPath.row-1;
//    
//    int tag= (int)indexPath.row;
//    int currentIndex=[self.dbId intValue];
//    int NextIndex= currentIndex + 5;
//    if(NextIndex >100){
//        currentIndex = 0;
//        NextIndex = 20;
//    }
//    
//    
//    
//    NSArray *arrayFromDb=[[DBManager getSharedInstance] get4VideobasedOnIndexHistory:currentIndex andLastIndex:NextIndex];
//    NSString *stringUrl1 =arrayFromDb[indexPath.row-1][@"url"];
//    NSArray *urlarray1 = [stringUrl1 componentsSeparatedByString:@"="];
//    NSString *stringurl1 =[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",[urlarray1 objectAtIndex:1]];
//    
//    
//    if(currentIndex<96){
//        
//        NSArray *arrayFromDb=[[DBManager getSharedInstance] get4VideobasedOnIndexHistory:currentIndex andLastIndex:NextIndex];
//        NSString *stringUrl1 =arrayFromDb[indexPath.row-1][@"url"];
//        NSArray *urlarray1 = [stringUrl1 componentsSeparatedByString:@"="];
//        NSString *stringurl1 =[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",[urlarray1 objectAtIndex:1]];
//        
//        
//    }




//    isFromSuggestion= TRUE;
//    
//    
//    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.url];
//    videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlayVideoInBackground"];
//    
//    videoPlayerViewController.preferredVideoQualities = @[ @(XCDYouTubeVideoQualityMedium360)] ; //nil;
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayerViewController.moviePlayer];
//    [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];

    
    
   }


- (void)doneButtonClick:(NSNotification*)aNotification
{
        NSLog(@"done button tapped");
}

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    
    if(!isFromSuggestion){
    collectionViewCount = 6;
    
    [self.myCollectionView reloadData];
    }
}

//- (void)playVideo:(UIButton*)button
//{
//    
//    int buttonTag = (int)button.tag;
//    NSLog(@"Button  clicked. %d",buttonTag);
//    
//    url= VideosListArray[buttonTag][@"url"];
//    
//    NSString *currentIndexValue = [NSString stringWithFormat:@"%@",VideosListArray[buttonTag][@"_id"]];
//    
//    videoIDatIndex = currentIndexValue;
//    
//    
//    urlArray = [url componentsSeparatedByString:@"="];
//    //NSString *stringurl =[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",[array objectAtIndex:1]];
//    //  NSURL *url=[NSURL URLWithString:stringurl];
//    //NSLog(@"%@",url);
//    
//    
//    
//    BOOL isUpdate =  [[DBManager getSharedInstance] updateIntoVideos:[currentIndexValue intValue]];
//    
//    if(isUpdate){
//        NSLog(@"Update");
//    }else{
//        NSLog(@"Unable To Update");
//    }
//    
//    
//    
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    int lastIndex =(int) [defaults integerForKey:@"lastIndex"];
//    lastIndex++;
//    [defaults setInteger:lastIndex forKey:@"lastIndex"];
//    [self performSegueWithIdentifier:@"playerfromview" sender:self];
//    // [self getDataFromDB];
//    
//    
//    //    setVideoIndex = 0;
//    //
//    //    [self.myCollectionView reloadData];
//    
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
