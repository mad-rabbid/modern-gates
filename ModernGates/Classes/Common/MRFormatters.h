#import <Foundation/Foundation.h>


@interface MRFormatters : NSObject

+ (NSNumberFormatter *)currencyFormatter;
+ (NSDateFormatter *)dateFormatter;
+ (NSDateFormatter *)simpleDateFormatter;
@end