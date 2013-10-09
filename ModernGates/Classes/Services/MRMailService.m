#import "MRMailService.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

#define kSmtpServer @"smtp.yandex.ru"
#define kSmtpUser @"yett.gates"
#define kSmtpPassword @"Qwe4Rty7"
#define kSmtpTLS NO
#define kMailFrom @"yett.gates@yandex.ru"



@implementation MRMailService {
    __strong NSArray *messages;

}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static MRMailService *_sharedInstance;
    dispatch_once(&once, ^() {
        _sharedInstance = [MRMailService new];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        messages = [NSArray array];
    }

    return self;
}

- (void)sendMessageToEmail:(NSString *)email subject:(NSString *)subject text:(NSString *)text calcResult:(NSDictionary *)calcResult {
    NSMutableString *builder = [NSMutableString stringWithString:text];
    [builder appendFormat:@"\n\n%@\n%@:", NSLocalizedString(@"Результат расчета", nil), calcResult];
    [self sendMessageToEmail:email subject:subject body:builder isHTML:NO];
}

- (void)sendMessageToEmail:(NSString *)email subject:(NSString *)subject body:(NSString *)body isHTML:(BOOL)isHTML {
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.relayHost = kSmtpServer;
    testMsg.fromEmail = kMailFrom;
    testMsg.toEmail = email;
    testMsg.requiresAuth = YES;

    testMsg.login = kSmtpUser;
    testMsg.pass = kSmtpPassword;

    testMsg.wantsSecure = kSmtpTLS;


    testMsg.subject = subject;
    testMsg.delegate = self;

    NSDictionary *plainPart = @{
        kSKPSMTPPartContentTypeKey : [NSString stringWithFormat:@"text/%@; charset=utf-8", isHTML ? @"html" : @"plain"],
        kSKPSMTPPartMessageKey : [[body dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData],
        kSKPSMTPPartContentTransferEncodingKey : @"base64"
    };

    testMsg.parts = @[plainPart];

    [testMsg send];

}

- (void)messageSent:(SKPSMTPMessage *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Информация", nil)
                                                        message:NSLocalizedString(@"Сообщение успешно отправлено", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Закрыть", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    [self removeMessage:message];
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Закрыть", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    [self removeMessage:message];
}

- (void)removeMessage:(SKPSMTPMessage *)message {
    if ([messages containsObject:message]) {
        [messages delete:message];
    }
}
@end