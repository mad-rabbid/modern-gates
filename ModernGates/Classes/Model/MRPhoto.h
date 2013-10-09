#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MRProject;

@interface MRPhoto : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) MRProject *project;

@end
