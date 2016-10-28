


#import <UIKit/UIKit.h>
#import "TactImageView.h"

@interface CustomCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *myImage;
@property (weak, nonatomic) IBOutlet TactImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *btthumbnailOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *ivPlayButton;
@property (weak, nonatomic) IBOutlet UIImageView *ivWheel;
@property (weak, nonatomic) IBOutlet UIImageView *ivSecondWheel;

@end
