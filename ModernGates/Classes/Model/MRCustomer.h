#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MRProject;

@interface MRCustomer : NSManagedObject

@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSSet *projects;
@end

@interface MRCustomer (CoreDataGeneratedAccessors)

- (void)addProjectsObject:(MRProject *)value;
- (void)removeProjectsObject:(MRProject *)value;
- (void)addProjects:(NSSet *)values;
- (void)removeProjects:(NSSet *)values;

@end
