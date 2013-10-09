#import <Foundation/Foundation.h>
#import "SKPSMTPMessage.h"


@interface MRMailService : NSObject<SKPSMTPMessageDelegate>

+ (MRMailService *)sharedInstance;
- (void)sendMessageToEmail:(NSString *)email subject:(NSString *)subject text:(NSString *)text calcResult:(NSDictionary *)calcResult;


- (void)sendMessageToEmail:(NSString *)email subject:(NSString *)subject body:(NSString *)body isHTML:(BOOL)isHTML;
@end