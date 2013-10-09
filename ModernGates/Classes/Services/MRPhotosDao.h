#import <Foundation/Foundation.h>

@class MRPhoto;
@class MRProject;


@interface MRPhotosDao : NSObject


+ (id)sharedInstance;

- (NSArray *)photos;
- (void)deletePhotoWithName:(NSString *)name;
- (MRPhoto *)createPhotoWithName:(NSString *)name project:(MRProject *)sourceProject;

@end