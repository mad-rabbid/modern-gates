#import "MRAbstractCell.h"


@implementation MRAbstractCell

+ (NSString *)reusableIdentifier {
    return NSStringFromClass(self);
}

+ (id)cellForTableView:(UITableView *)tableView {
    return [tableView dequeueReusableCellWithIdentifier:self.reusableIdentifier];
}


@end