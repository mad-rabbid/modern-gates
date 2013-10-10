#import "MRProjectsDao.h"
#import "MRProject.h"
#import "MagicalRecordShorthand.h"

#define kModelName @"MRDataModel.momd"
#define kSQLiteExtension @"sqlite"
#define kMaxAttemptsNumber 2

@implementation MRProjectsDao {
    __strong NSURL *_storeUrl;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static MRProjectsDao *_sharedInstance;
    dispatch_once(&once, ^() {
        _sharedInstance = [MRProjectsDao new];
    });
    return _sharedInstance;
}

- (NSURL *)storeUrl {
    if (!_storeUrl) {
        NSURL *directoryUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSString *model = [kModelName stringByDeletingPathExtension];

        _storeUrl = [directoryUrl URLByAppendingPathComponent:[model stringByAppendingPathExtension:kSQLiteExtension]];
    }
    return _storeUrl;
}


- (void)setup {
    for (NSInteger index = 0; index < kMaxAttemptsNumber; index++) {
        MRLog(@"Retrieving a persistence store coordinator. Current attempt is: %d", index);
        NSPersistentStoreCoordinator *coordinator = nil;

        MRLog(@"The store location is: %@", self.storeUrl);
        [MagicalRecord cleanUp];
        coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel managedObjectModelNamed:kModelName]];

        __autoreleasing NSError *error = nil;
        MRLog(@"Adding a persistent store to the coordinator...");
        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeUrl options:nil error:&error]) {

            [MagicalRecord handleErrors:error];

            [[NSFileManager defaultManager] removeItemAtURL:self.storeUrl error:nil];
            coordinator = nil;
        }

        if (coordinator != nil) {
            MRLog(@"Creating a managed object context...");
            NSPersistentStoreCoordinator.defaultStoreCoordinator = coordinator;
            [NSManagedObjectContext initializeDefaultContextWithCoordinator:coordinator];
            break;
        }
    }
}

- (NSArray *)projects {
    NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
    NSFetchRequest *request = [MRProject createFetchRequestInContext:context];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]];
    return [MRProject executeFetchRequest:request inContext:context];
}

- (MRProject *)projectWithDate:(NSDate *)date {
    NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", date];
    return [MRProject findFirstWithPredicate:predicate inContext:context];
}

- (void)deleteProjectWithDate:(NSDate *)date {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", date];
        MRProject *project = [MRProject findFirstWithPredicate:predicate inContext:context];
        [project deleteInContext:context];
    }];
}

- (NSDate *)createProjectWithType:(NSString *)type {
    NSDate *date = [NSDate new];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
        MRProject *project = [MRProject createInContext:context];
        project.orderTitle = type;
        project.date = date;
        project.type = type;
        project.orderAddress = @"Address";
    }];

    return date;
}

- (void)updateProject:(MRProject *)dto {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", dto.date];
        MRProject *project = [MRProject findFirstWithPredicate:predicate inContext:context];
        if (project) {
            project.orderTitle = dto.orderTitle;
            project.orderAddress = dto.orderAddress;
            project.data = dto.data;
        }
    }];
}
@end