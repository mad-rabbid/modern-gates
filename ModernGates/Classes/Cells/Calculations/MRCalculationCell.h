#import <Foundation/Foundation.h>
#import "MRAbstractCell.h"

@class MRCalculation;


@interface MRCalculationCell : MRAbstractCell

- (void)updateFromVO:(MRCalculation *)vo;
@end