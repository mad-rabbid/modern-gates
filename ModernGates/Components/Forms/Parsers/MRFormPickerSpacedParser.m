#import "MRFormPickerSpacedParser.h"

@implementation MRFormPickerSpacedParser

- (NSString *)objectFromComponentsValues:(NSArray *)componentsValues {
    return [componentsValues componentsJoinedByString:@"|"];
}

- (NSArray *)componentsValuesFromObject:(NSString *)stringValue {
    return [stringValue componentsSeparatedByString:@"|"];
}

@end
