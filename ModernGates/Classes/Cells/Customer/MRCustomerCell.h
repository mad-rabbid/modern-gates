#import <Foundation/Foundation.h>
#import "MRAbstractCell.h"

@class MRCustomer;


@interface MRCustomerCell : MRAbstractCell

- (void)updateFromVO:(MRCustomer *)vo;

@end