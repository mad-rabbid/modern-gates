#import <Foundation/Foundation.h>


@interface MRLoginService : NSObject

@property (nonatomic, strong) NSString *token;

+ (MRLoginService *)sharedInstance;
@end