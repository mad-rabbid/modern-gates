#import <Foundation/Foundation.h>


@interface MRAbstractCell : UITableViewCell

+ (NSString *)reusableIdentifier;
+ (id)cellForTableView:(UITableView *)tableView;
@end