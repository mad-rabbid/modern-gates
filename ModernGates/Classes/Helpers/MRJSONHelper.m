#import "MRJSONHelper.h"
#import "MagicalRecord.h"


@implementation MRJSONHelper

+ (NSString *)loadJsonAtPath:(NSString *)path {
    return [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path]
                                 encoding:NSUTF8StringEncoding];
}

+ (NSString *)loadJsonFromFile:(NSString *)fileName bundle:(NSBundle *)bundle {
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }

    NSString *name = fileName.stringByDeletingPathExtension;
    NSString *extension = fileName.pathExtension;
    NSString *path = [bundle pathForResource:name ofType:extension];

    return [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path]
                                                 encoding:NSUTF8StringEncoding];
}

+ (NSString *)loadJsonFromFile:(NSString *)fileName {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:fileName];

    return [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path]
                                                 encoding:NSUTF8StringEncoding];
}

+ (id)objectFromJsonAtPath:(NSString *)path {
    return [self objectFromJson:[self loadJsonAtPath:path]];
}

+ (id)objectFromJsonFile:(NSString *)fileName bundle:(NSBundle *)bundle {
    return [self objectFromJson:[self loadJsonFromFile:fileName bundle:bundle]];
}

+ (id)objectFromJsonFile:(NSString *)fileName {
    return [self objectFromJson:[self loadJsonFromFile:fileName]];
}

+ (id)objectFromData:(NSData *)source {
    if (!source) {
        return nil;
    }

    __autoreleasing NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData:source options:NSJSONReadingMutableContainers error:&error];
    if (!result) {
        MRLog(@"JSON parsing error was handled: %@", error.localizedDescription);
    } else {
        return [self JSONMutableFixObject:result];
    }

    return nil;
}

+ (id)objectFromJson:(NSString *)source {
    if (source.length) {
        __autoreleasing NSError *error;
        id result = [NSJSONSerialization JSONObjectWithData:[source dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if (!result) {
            MRLog(@"JSON parsing error was handled: %@", error.localizedDescription);
        } else {
            return [self JSONMutableFixObject:result];
        }
    }

    return nil;
}

+ (NSString *)jsonFromObject:(id)source {
    __autoreleasing NSError *error;

    NSData *result = [NSJSONSerialization dataWithJSONObject:source options:NSJSONWritingPrettyPrinted error:&error];
    if (!result) {
        MRLog(@"JSON parsing error was handled: %@", error.localizedDescription);
    } else {
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }

    return nil;
}

+ (NSData *)jsonDataFromObject:(id)source {
    return [[self jsonFromObject:source] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (id)JSONMutableFixObject:(id)object {
    if ([object isKindOfClass:[NSDictionary class]]) {
        // NSJSONSerialization creates an immutable container if it's empty (boo!!)
        if ([object count] == 0) {
            object = [object mutableCopy];
        }

        for (NSString *key in [object allKeys]) {
            [object setObject:[self JSONMutableFixObject:[object objectForKey:key]] forKey:key];
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        // NSJSONSerialization creates an immutable container if it's empty (boo!!)
        if (![object count] == 0) {
            object = [object mutableCopy];
        }

        for (NSUInteger i = 0; i < [object count]; ++i) {
            [object replaceObjectAtIndex:i withObject:[self JSONMutableFixObject:[object objectAtIndex:i]]];
        }
    }

    return object;
}

@end