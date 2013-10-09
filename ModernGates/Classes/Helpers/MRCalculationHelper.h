#import <Foundation/Foundation.h>


@interface MRCalculationHelper : NSObject

+ (NSDictionary *)prepareServerRequestDataWithForm:(NSArray *)form;

+ (NSDictionary *)prepareCalculationResultDataWithForm:(NSArray *)form calculationResult:(NSDictionary *)result priceDate:(NSDate *)priceDate;

@end