#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MRPhoto;
@class MRCustomer;
@class MRCalculation;

@interface MRProject : NSManagedObject

@property (nonatomic, retain) NSString *orderAddress;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *orderDescription;
@property (nonatomic, retain) NSString *orderTitle;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSNumber *orderLatitude;
@property (nonatomic, retain) NSNumber *orderLongitude;
@property (nonatomic, retain) NSString *factoryId;
@property (nonatomic, retain) NSDate *factoryDate;
@property (nonatomic, retain) NSString *factoryStatus;
@property (nonatomic, retain) NSDecimalNumber *payedAmount;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *calculations;
@property (nonatomic, retain) MRCustomer *customer;
@end

@interface MRProject (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(MRPhoto *)value;
- (void)removePhotosObject:(MRPhoto *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addCalculationsObject:(MRCalculation *)value;
- (void)removeCalculationsObject:(MRCalculation *)value;
- (void)addCalculations:(NSSet *)values;
- (void)removeCalculations:(NSSet *)values;

@end
