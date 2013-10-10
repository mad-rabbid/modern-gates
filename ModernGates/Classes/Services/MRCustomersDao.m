#import "MRCustomersDao.h"
#import "MRCustomer.h"
#import "MRProject.h"


@implementation MRCustomersDao

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static MRCustomersDao *_sharedInstance;
    dispatch_once(&once, ^() {
        _sharedInstance = [MRCustomersDao new];
    });
    return _sharedInstance;
}

- (NSArray *)customers {
    NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
    NSFetchRequest *request = [MRCustomer createFetchRequestInContext:context];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
    return [MRCustomer executeFetchRequest:request inContext:context];
}

- (void)deleteCustomerWithDate:(NSDate *)date {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creationDate == %@", date];
        MRCustomer *customer = [MRCustomer findFirstWithPredicate:predicate inContext:context];
        [customer deleteInContext:context];
    }];
}

- (MRCustomer *)createCustomer {
    __block MRCustomer *customer = nil;

    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
        customer = [MRCustomer createInContext:context];
        customer.creationDate = [NSDate new];
        customer.title = NSLocalizedString(@"Новый заказчик", nil);
        customer.name = @"";
    }];

    return customer;
}

- (MRCustomer *)customerByProject:(MRProject *)project {
    NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", project.date];
    return [MRProject findFirstWithPredicate:predicate inContext:context];
}

- (void)updateCustomer:(MRCustomer *)dto {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creationDate == %@", dto.creationDate];
        MRCustomer *customer = [MRCustomer findFirstWithPredicate:predicate inContext:context];
        if (customer) {
            customer.address = dto.address;
            customer.email = dto.email;
            customer.info = dto.info;
            customer.name = dto.name;
            customer.phone = dto.phone;
            customer.title = dto.title;
        }
    }];
}
@end