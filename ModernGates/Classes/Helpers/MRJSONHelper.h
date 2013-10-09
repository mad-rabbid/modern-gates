#import <Foundation/Foundation.h>


@interface MRJSONHelper : NSObject

+ (NSString *)loadJsonAtPath:(NSString *)path;

+ (NSString *)loadJsonFromFile:(NSString *)fileName bundle:(NSBundle *)bundle;
+ (NSString *)loadJsonFromFile:(NSString *)fileName;

+ (id)objectFromJsonAtPath:(NSString *)path;

+ (id)objectFromJsonFile:(NSString *)fileName bundle:(NSBundle *)bundle;
+ (id)objectFromJsonFile:(NSString *)fileName;

+ (id)objectFromJson:(NSString *)source;
+ (id)objectFromData:(NSData *)source;

+ (NSString *)jsonFromObject:(id)source;

+ (NSData *)jsonDataFromObject:(id)source;

@end