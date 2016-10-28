

#import "VideoListTableVIewController.h"
#import "VideoListTableVIewCell.h"
#import "DBManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Support.h"
#import "YouTubePlayerViewController.h"



@interface VideoListTableVIewController (){
    NSArray *WatchedVideos;
    NSString *url;
    NSArray * array;
    NSString *dbId;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation VideoListTableVIewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parent_video_history_bg.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    WatchedVideos= [[DBManager getSharedInstance] getAllHistoryVideos];
    NSLog(@"%@",WatchedVideos);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait; // or Right of course
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(void)noNotificationMessage{
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width)/2-100, ([[UIScreen mainScreen] bounds].size.height)
                                                                  /2, 200, 30)];
    [newLabel setText:@"No Notifications Yet!"];
    newLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:newLabel];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.tableView reloadData];
    
    if([WatchedVideos count]<1){
        [self noNotificationMessage];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [WatchedVideos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *simpleTableIdentifier = @"VideoListTableVIewCell";
    
    VideoListTableVIewCell *cell=(VideoListTableVIewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoListTableVIewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // cell.lbTitleOutlet.text=@"shubham";
    
    cell.lbTitleOutlet.text=WatchedVideos[indexPath.row][@"Title"];
    
    NSString *theme=WatchedVideos[indexPath.row][@"theme"];
    if([theme isEqualToString:@"<null>"]){
        
    }else{
        cell.lbDescriptionOutlet.text=theme;
    }
    
    
    NSString *stringUrl = WatchedVideos[indexPath.row][@"url"];
    array = [stringUrl componentsSeparatedByString:@"="];
    NSString *stringurl =[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",[array objectAtIndex:1]];
    NSURL *videourl=[NSURL URLWithString:stringurl];
    NSLog(@"%@",videourl);
    cell.ivThumbnailImageOutlet.imageneryURL=videourl;
    dbId = WatchedVideos[indexPath.row][@"_id"];
    
    UIColor *color = [Support colorWithHexString:@"FDFAD1"];
    cell.colorView.backgroundColor = color;
    
    
    
    
    cell.layer.cornerRadius = 2;
    cell.layer.masksToBounds = YES;
    
    return cell;
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    return 151;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    url=WatchedVideos[indexPath.row][@"url"];
    
   

    [self performSegueWithIdentifier:@"player" sender:self];
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"player"]){
        
        YouTubePlayerViewController *controller=segue.destinationViewController;
        controller.url=[array objectAtIndex:1];
        controller.dbId = dbId;
    }
}


@end
