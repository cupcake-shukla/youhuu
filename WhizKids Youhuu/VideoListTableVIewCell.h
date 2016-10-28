

#import <UIKit/UIKit.h>
#import "TactImageView.h"


@interface VideoListTableVIewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet TactImageView *ivThumbnailImageOutlet;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitleOutlet;

@property (weak, nonatomic) IBOutlet UILabel *lbDescriptionOutlet;
@end
