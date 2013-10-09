#import <Foundation/Foundation.h>

@class MRCalculation;
@class MRProject;


@interface MRCalculationsDao : NSObject

+ (id)sharedInstance;

- (NSArray *)calculationsForProject:(MRProject *)project;
- (void)deleteCalculationWithDate:(NSDate *)date;
- (MRCalculation *)createCalculationForProject:(MRProject *)project;
- (void)updateCalculation:(MRCalculation *)dto;

@end