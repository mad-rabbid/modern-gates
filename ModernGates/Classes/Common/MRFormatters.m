#import "MRFormatters.h"

#define FORMATTER_FRACTION_DIGITS 2
#define FORMATTER_NEGATIVE_PREFIX @"- "
#define FORMATTER_GROUPING_SEPARATOR @" "
#define FORMATTER_DOT_DECIMAL_SEPARATOR @"."

#define FORMATTER_DATE_FORMAT @"yyyy-MM-dd HH:mm"
#define FORMATTER_SIMPLE_DATE_FORMAT @"yyyy-MM-dd"

@implementation MRFormatters {

}

+ (NSNumberFormatter *)currencyFormatter {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = FORMATTER_FRACTION_DIGITS;
    formatter.maximumFractionDigits = FORMATTER_FRACTION_DIGITS;
    formatter.negativePrefix = FORMATTER_NEGATIVE_PREFIX;
    formatter.decimalSeparator = FORMATTER_DOT_DECIMAL_SEPARATOR;
    formatter.usesGroupingSeparator = NO;
    formatter.groupingSeparator = FORMATTER_GROUPING_SEPARATOR;
    return formatter;
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = FORMATTER_DATE_FORMAT;
    return formatter;
}

+ (NSDateFormatter *)simpleDateFormatter {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = FORMATTER_SIMPLE_DATE_FORMAT;
    return formatter;
}
@end