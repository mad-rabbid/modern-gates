#import "MRPhotosDao.h"
#import "MRPhoto.h"
#import "MRProject.h"
#import "MRProjectsDao.h"


@implementation MRPhotosDao {

}

+ (instancetype)sharedInstance {
    static MRPhotosDao *_sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^() {
        _sharedInstance = [MRPhotosDao new];
    });
    return _sharedInstance;
}

- (NSArray *)photos {
    NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];

    NSFetchRequest *request = [MRPhoto createFetchRequestInContext:context];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]];
    return [MRPhoto executeFetchRequest:request inContext:context];
}

- (void)deletePhotoWithName:(NSString *)name {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
        MRPhoto *photo = [MRPhoto findFirstWithPredicate:predicate inContext:context];
        [photo deleteInContext:context];
    }];
}

- (MRPhoto *)createPhotoWithName:(NSString *)name project:(MRProject *)sourceProject {
    __block MRPhoto *photo = nil;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
        MRProject *project = [[MRProjectsDao sharedInstance] projectWithDate:sourceProject.date];

        photo = [MRPhoto createInContext:context];
        photo.name = name;
        photo.project = project;
        [project addPhotosObject:photo];
    }];

    return photo;
}
@end