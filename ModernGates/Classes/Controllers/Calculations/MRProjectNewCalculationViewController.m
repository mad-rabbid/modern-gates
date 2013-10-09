#import "MRProjectNewCalculationViewController.h"
#import "MRScriptingService.h"
#import "MRJSONHelper.h"
#import "MRAppDelegate.h"
#import "MKNetworkOperation.h"
#import "MRCalculationHelper.h"
#import "JSONKit.h"
#import "MKNetworkEngine.h"

#define kInsetValue 15

@interface MRProjectNewCalculationViewController ()
@property (nonatomic, strong) MKNetworkOperation *operation;
@end

@implementation MRProjectNewCalculationViewController {
    __strong UITextView *_textView;
    __strong MRScriptingService *_service;
}


- (void)dealloc {
    [self cancelNetworkOperation];
}

- (void)cancelNetworkOperation {
    if (_operation) {
        [_operation cancel];
        _operation = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _textView = [[UITextView alloc] initWithFrame:CGRectInset(self.view.bounds, kInsetValue, kInsetValue)];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textView.editable = NO;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    [self.view addSubview:_textView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _textView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _textView.text = NSLocalizedString(@"Выполняется расчет стоимости...", nil);

    if (!_form && !_projectType) {
        [self appendText:NSLocalizedString(@"Не задана форма или тип проекта", nil)];
        [self notifyAboutResult:nil];
        return;
    }

    //[self calculateUsingNetwork];
    [self calculateUsingJSEngine];
}

- (void)calculateUsingNetwork {
    [self appendText:NSLocalizedString(@"Отправка данных на сервер", nil)];
    NSDictionary *dictionary = [MRCalculationHelper prepareServerRequestDataWithForm:_form];

    self.operation = [ApplicationDelegate.networkEngine operationWithPath:@"convert.php"
                                                                                  params:@{@"text_json" : [dictionary JSONString] }
                                                                              httpMethod:@"POST"];

    NSLog(@"Operation: %@", self.operation);
    __weak MRProjectNewCalculationViewController *myself = self;
    [self.operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [myself appendText:NSLocalizedString(@"Получен ответ сервера", nil)];
        NSString *response = completedOperation.responseString;
        NSString *orderId = [myself extractTag:@"documentNumber" source:response];
        NSString *total = [myself extractTag:@"total" source:response];

        NSLog(@"Operation result is: %@, %@", orderId, total);
        [myself appendText:[NSString stringWithFormat:NSLocalizedString(@"Номер документа: %@, сумма: %@ у.е.", nil), orderId, total]];
        if (orderId.length && total.length) {
            NSDictionary *result = [myself prepareResultWithOrderId:orderId total:total];
            if (result) {
                [myself notifyAboutResult:result];
                [myself appendText:NSLocalizedString(@"Расчет завершен успешно", nil)];
            } else {
                [myself appendText:NSLocalizedString(@"Ошибка расчета.", nil)];
            }
        } else {
            [myself appendText:NSLocalizedString(@"Ответ сервера не распознан", nil)];
        }

        myself.operation = nil;
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [myself appendText:NSLocalizedString(@"Ошибка при обмене данными с сервером", nil)];
        myself.operation = nil;
    }];

    [ApplicationDelegate.networkEngine enqueueOperation:_operation];
}

- (NSDictionary *)prepareResultWithOrderId:(NSString *)orderId total:(NSString *)total {
    NSDecimalNumber *dealer = [NSDecimalNumber decimalNumberWithString:total];
    if ([dealer compare:[NSDecimalNumber zero]] <= 0) {
        [self appendText:NSLocalizedString(@"Сервер вернул нулевую сумму заявки.", nil)];
        return nil;
    }

    NSDictionary *factors = self.factors;
    NSDecimalNumber *baseFactor = [[[NSDecimalNumber alloc] initWithInteger:[factors[@"dealer"] intValue]] decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInteger:100]];
    return @{
        @"order" : orderId,
        @"prices" : @{
            @"dealer" : dealer,
            @"season" : dealer,
            @"base" : [dealer decimalNumberByMultiplyingBy:[NSDecimalNumber.one decimalNumberByAdding:baseFactor]]
        }
    };
}

- (NSDictionary *)factors {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return @{
        @"dealer": [settings objectForKey:@"gates.settings.dealer"],
        @"season": [settings objectForKey:@"gates.settings.season"],
        @"fee": [settings objectForKey:@"gates.settings.fee"],
        @"transport": [settings objectForKey:@"gates.settings.transport"]
    };
}

- (void)calculateUsingJSEngine {
    [self appendText:NSLocalizedString(@"Загрузка данных расчета...", nil)];
    _service = [[MRScriptingService alloc] initWithBlock:^(BOOL success, MRScriptingService *service) {

        [self appendText:NSLocalizedString(@"Данные расчета загружены.", nil)];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendText:NSLocalizedString(@"Выполняется расчет...", nil)];

                NSMutableDictionary *result = nil;//[[service calcForm:_form] mutableCopy];
                [self appendText:NSLocalizedString(@"Расчет выполнен", nil)];

                if (result && result[@"log"]) {
                    [self appendText:result[@"log"]];
                    [result removeObjectForKey:@"log"];
                }

                [self appendText:(result) ?
                        [NSString stringWithFormat:NSLocalizedString(@"Результат: %@", nil), [MRJSONHelper jsonFromObject:result]] :
                        NSLocalizedString(@"Ошибка при выполнении расчета", nil)];

                [self notifyAboutResult:result];
            });
        });
    }];

    //[_service loadEngineWithName:_projectType];
}
- (void)appendText:(NSString *)text {
    _textView.text = [NSString stringWithFormat:@"%@\n%@", _textView.text, text];
}

- (void)notifyAboutResult:(NSDictionary *)result {
    if (_block) {
        _block(result != nil, result);
    }
}

- (NSString *)extractTag:(NSString *)tag source:(NSString *)source {
    NSString *pattern = [NSString stringWithFormat:@"&lt;%@&gt;(.*)?&lt;/%@&gt;", tag, tag];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];

    __block NSString *result = nil;
    [expression enumerateMatchesInString:source options:0 range:NSMakeRange(0, [source length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSRange range = [match rangeAtIndex:1];
        result = [source substringWithRange:range];
        *stop = YES;
    }];
    return result;
}
@end