#import <Foundation/Foundation.h>

@class MRProject;


@interface MRProjectsDao : NSObject

+ (MRProjectsDao *)sharedInstance;

- (void)setup;
- (NSArray *)projects;
- (MRProject *)projectWithDate:(NSDate *)date;
- (void)deleteProjectWithDate:(NSDate *)date;
- (NSDate *)createProjectWithType:(NSString *)type;
- (void)updateProject:(MRProject *)dto;

@end