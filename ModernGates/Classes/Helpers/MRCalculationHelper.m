#import "MRFormatters.h"
#import "MRCalculationHelper.h"


@implementation MRCalculationHelper

+ (NSDictionary *)prepareServerRequestDataWithForm:(NSArray *)form {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [form enumerateObjectsUsingBlock:^(NSDictionary *section, NSUInteger idx, BOOL *stop) {
        NSArray *elements = section[@"elements"];
        if (elements) {
            [elements enumerateObjectsUsingBlock:^(NSDictionary *element, NSUInteger idx1, BOOL *stop1) {
                NSString *identifier = element[@"name"];
                NSString *value = element[@"value"];
                if (identifier.length && value.length) {
                    NSString *type = element[@"type"];
                    if ([type isEqualToString:@"number"]) {
                        result[identifier] = [NSDecimalNumber decimalNumberWithString:value];
                    } else {
                        result[identifier] = value;
                    }
                }
            }];
        }
    }];
    return result;
}

+ (NSDictionary *)prepareCalculationResultDataWithForm:(NSArray *)form calculationResult:(NSDictionary *)calculationResult priceDate:(NSDate *)priceDate {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSMutableArray *array = [NSMutableArray array];
    [form enumerateObjectsUsingBlock:^(NSDictionary *section, NSUInteger idx, BOOL *stop) {
        NSArray *elements = section[@"elements"];
        if (elements) {
            [elements enumerateObjectsUsingBlock:^(NSDictionary *element, NSUInteger idx1, BOOL *stop1) {
                NSString *identifier = element[@"name"];
                NSString *value = element[@"value"];
                if (identifier.length && value.length) {
                    [array addObject: @{ @"value" : value, @"label" : element[@"label"] }];
                }
            }];
        }
    }];

    result[@"form"] = array;

    if (priceDate) {
        result[@"calculation_date"] = [[MRFormatters dateFormatter] stringFromDate:priceDate];
    }

    if (calculationResult) {
        [result addEntriesFromDictionary:calculationResult];
    }
    return result;
}

@end