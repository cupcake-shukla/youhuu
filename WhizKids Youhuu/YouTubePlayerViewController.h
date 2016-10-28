

#import <UIKit/UIKit.h>



@interface YouTubePlayerViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>{
    
    NSArray *videoArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString* dbId;


@property (weak, nonatomic) IBOutlet UIWebView *wvWebView;

@end
