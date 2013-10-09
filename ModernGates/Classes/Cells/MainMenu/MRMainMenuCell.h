#import <Foundation/Foundation.h>
#import "MRAbstractCell.h"


@interface MRMainMenuCell : MRAbstractCell

- (void)setTitle:(NSString *)title;
- (void)setImageWithName:(NSString *)imageName;

@end