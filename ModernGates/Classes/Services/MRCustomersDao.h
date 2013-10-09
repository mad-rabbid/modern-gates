#import <Foundation/Foundation.h>

@class MRCustomer;
@class MRProject;


@interface MRCustomersDao : NSObject

+ (id)sharedInstance;

- (NSArray *)customers;
- (void)deleteCustomerWithDate:(NSDate *)date;
- (MRCustomer *)createCustomer;
- (void)updateCustomer:(MRCustomer *)dto;
- (MRCustomer *)customerByProject:(MRProject *)project;
@end