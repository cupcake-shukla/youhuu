


#import <UIKit/UIKit.h>


@interface ViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>{

 NSArray *videoArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
- (IBAction)btHistoryAction:(id)sender;
@property (weak, nonatomic) NSTimer *timer;


- (IBAction)btTrafficLight:(id)sender;



@end

