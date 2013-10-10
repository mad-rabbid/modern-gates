#import "MRCalculationsDao.h"
#import "MRCalculation.h"
#import "MRProject.h"
#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObject+MagicalRecord.h"


@implementation MRCalculationsDao {

}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static MRCalculationsDao *_sharedInstance;
    dispatch_once(&once, ^() {
        _sharedInstance = [MRCalculationsDao new];
    });
    return _sharedInstance;
}


- (NSArray *)calculationsForProject:(MRProject *)project {
    if (project && project.calculations) {
        NSArray *orders = @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]];
        return [[project.calculations allObjects] sortedArrayUsingDescriptors:orders];
    }

    return nil;
}

- (void)deleteCalculationWithDate:(NSDate *)date {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", date];
        MRCalculation *calculation = [MRCalculation findFirstWithPredicate:predicate inContext:context];
        [calculation deleteInContext:context];
    }];
}

- (MRCalculation *)createCalculationForProject:(MRProject *)project {
    __block MRCalculation *calculation = nil;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
        calculation = [MRCalculation createInContext:context];
        calculation.date = [NSDate new];
        calculation.project = project;
    }];

    return calculation;
}

- (void)updateCalculation:(MRCalculation *)dto {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", dto.date];
        MRCalculation *calculation = [MRCalculation findFirstWithPredicate:predicate inContext:context];
        if (calculation) {
            calculation.data = dto.data;
            calculation.priceDate = dto.priceDate;
        }
    }];
}

@end