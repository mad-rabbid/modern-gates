#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MRProject;


@interface MRCalculation : NSManagedObject

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSDate *priceDate;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) MRProject *project;

@end
