#import "MRCalculatorButton.h"

@implementation MRCalculatorButton

- (void)awakeFromNib {
	CGRect bounds = self.bounds;
	bounds.size.height = bounds.size.width = 32.0f;	
	self.bounds = bounds;
	self.backgroundColor = [UIColor clearColor];
	
	UIImage *normalStateImage = [UIImage imageNamed:@"calculator-icon.png"];
	[self setBackgroundImage:normalStateImage forState:UIControlStateNormal];
}

@end
