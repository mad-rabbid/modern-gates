#import <Foundation/Foundation.h>

@interface MRProjectEngineHelper : NSObject


+ (MRProjectEngineHelper *)sharedInstance;

- (NSArray *)engines;

- (BOOL)doesEngineWithCodeExist:(NSString *)code;

@end