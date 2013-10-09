#import "MRPriceHelper.h"
#import "MRJSONHelper.h"
#import "MRFormatters.h"


@implementation MRPriceHelper {

}

+ (NSDate *)priceDateForEngineWithName:(NSString *)engineName {
    NSString *path = [[NSBundle mainBundle] pathForResource:[engineName stringByAppendingString:@"-price"] ofType:@"js"];
    NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (content.length) {
        NSRange range = [content rangeOfString:@".price || {"];
        if (range.location != NSNotFound) {
            content = [content substringWithRange:NSMakeRange((NSMaxRange(range) - 1), content.length - NSMaxRange(range) + 1)];
            NSDictionary *price = [MRJSONHelper objectFromJson:content];

            NSString *dateSource = price[@"date"];
            if (dateSource.length) {
                return [[MRFormatters dateFormatter] dateFromString:dateSource];
            }
        }

    }

    return nil;
}

@end