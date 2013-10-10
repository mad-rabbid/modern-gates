#import "MRCalculationCell.h"
#import "MRCalculation.h"
#import "MRJSONHelper.h"
#import "MRFormatters.h"


@implementation MRCalculationCell {
    __weak IBOutlet UILabel *_labelCalculationDate;
    __weak IBOutlet UILabel *_labelPriceDate;
    __weak IBOutlet UILabel *_labelBasePrice;
}

- (void)awakeFromNib {
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-form-background.png"]];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-form-background.png"]];
    [self sendSubviewToBack:self.backgroundView];
}

- (void)updateFromVO:(MRCalculation *)vo {
    NSDictionary *data = [MRJSONHelper objectFromData:vo.data];
    _labelPriceDate.text = [[MRFormatters dateFormatter] stringFromDate:vo.priceDate];
    _labelCalculationDate.text = [[MRFormatters dateFormatter] stringFromDate:vo.date];
    NSNumber *amount = data[@"base"];
    _labelBasePrice.text = [NSString stringWithFormat:@"%@ %@", [[MRFormatters currencyFormatter] stringFromNumber:amount], NSLocalizedString(@"у.е.", nil)];
}

@end