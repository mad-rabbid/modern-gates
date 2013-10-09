#import "MRProjectCalculationDetailsViewController.h"
#import "MRCalculation.h"
#import "MRProject.h"
#import "MRCustomer.h"
#import "MRCalculationsDao.h"
#import "MRJSONHelper.h"
#import "MRFormatters.h"
#import "MRMailService.h"
#import "UIView+MRDottedBackground.h"


@implementation MRProjectCalculationDetailsViewController {
    __weak IBOutlet UILabel *_labelCalculationDate;
    __weak IBOutlet UILabel *_labelPriceDate;
    __weak IBOutlet UILabel *_labelPriceBase;
    __weak IBOutlet UILabel *_labelPriceDealer;
    __weak IBOutlet UILabel *_labelPriceSeason;

    __weak IBOutlet UIButton *_buttonChange;
    __weak IBOutlet UIButton *_buttonEmail;


    __weak IBOutlet UITextField *_textFieldCalculationDate;
    __weak IBOutlet UITextField *_textFieldPriceDate;
    __weak IBOutlet UITextField *_textFieldPriceBase;
    __weak IBOutlet UITextField *_textFieldPriceDealer;
    __weak IBOutlet UITextField *_textFieldPriceSeason;
    //__weak IBOutlet UITextView *_textViewInfo;

    __weak IBOutlet UIWebView *_webViewInfo;

}

- (NSString *)htmlStringFromDictionary:(NSDictionary *)dictionary showPrices:(BOOL)showPrices {
    NSArray *array = dictionary[@"form"];
    NSMutableString *builder = [NSMutableString stringWithString:@"<html style=\"padding: 0; margin: 0; width: 100%; font-family: HelveticaNeue, sans-serif; font-size: 15px;\">\n"
            "<head></head>\n"
            "<body style=\"width: 100%;\">\n"];
    
    

    if (showPrices) {
        [builder appendString:NSLocalizedString(@"\t<h2>Цены</h2>\n", nil)];
        [self appendPrice:_textFieldPriceBase.text withLabel:_labelPriceBase.text toBuilder:builder];
        [self appendPrice:_textFieldPriceDealer.text withLabel:_labelPriceDealer.text toBuilder:builder];
        [self appendPrice:_textFieldPriceSeason.text withLabel:_labelPriceSeason.text toBuilder:builder];
        [builder appendString:NSLocalizedString(@"\t<h2>Параметры заказа</h2>\n", nil)];
    }
    if (self.project.customer != nil && self.project.customer.title != nil) {
        [builder appendString:@"\t<h3>"];
        [builder appendString:NSLocalizedString(@"Клиент: ", nil)];
        [builder appendString:self.project.customer.title];
        [builder appendString:@"</h3>"];
    }
    if (self.project.orderAddress != nil) {
        [builder appendString:@"\t<h3>"];
        [builder appendString:NSLocalizedString(@"Адрес: ", nil)];
        [builder appendString:self.project.orderAddress];
        [builder appendString:@"</h3>"];
    }
    
    [builder appendString:@"\t<table style=\"width: 100%; padding: 10px;\">\n"];
    [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        //[builder appendFormat:@"\t\t<tr><td><strong>%@</strong></td><td style=\"width: 30%%;\">%@</td></tr>\n", obj[@"label"], obj[@"value"]];
        // ttvvaa - здесь должен быть перевод
        NSString *v = [NSString stringWithFormat:@"%@", obj[@"value"]];
        
        if ( [v isEqual:  @"true"]) v = @"Да";
        else if ([v isEqual: @"false"]) v = @"Нет";
        else if ([v isEqual: @"concrete"]) v = @"Бетон";
        else if ([v isEqual: @"wood"]) v = @"Дерево";
        else if ([v isEqual: @"brick"]) v = @"Кирпич";
        else if ([v isEqual: @"perforated_brick"]) v = @"Пустотелый кирпич";
        else if ([v isEqual: @"metal"]) v = @"Металл";
        else if ([v isEqual: @"classic"]) v = @"Гофра (классический)";
        else if ([v isEqual: @"smooth"]) v = @"Гладкий лист (без зигов)";
        else if ([v isEqual: @"withmiddleband"]) v = @"С центральной полосой";
        else if ([v isEqual: @"wave"]) v = @"Волна";
        else if ([v isEqual: @"waveandband"]) v = @"Волна с центральной полосой";
        else if ([v isEqual: @"panel"]) v = @"Филенка";
        else if ([v isEqual: @"smooth"]) v = @"Гладкий";
        else if ([v isEqual: @"classic"]) v = @"Стукко (stucco)";
        else if ([v isEqual: @"wood"]) v = @"Под дерево";
        else if ([v isEqual: @"standard"]) v = @"Стандартный (RAL)";
        else if ([v isEqual: @"nonstandard"]) v = @"Нестандартный";
        else if ([v isEqual: @"custom"]) v = @"Индивидуальный (по образцу)";
     
        //[builder appendFormat:@"<tr><td><strong>%@</strong></td><td>%@</td></tr>", obj[@"label"], obj[@"value"]];
        
        // ttvvaa
        [builder appendFormat:@"<tr><td><strong>%@</strong></td><td>%@</td></tr>", obj[@"label"], v];
    }];
    [builder appendString:@"\t</table>\n"];

    [builder appendString:@"</body>\n"
            "</html>\n"];

    NSLog(@"HTML string is: %@", builder);
    return builder;
}

- (void)appendPrice:(NSString *)price withLabel:(NSString *)label toBuilder:(NSMutableString *)builder {
    [builder appendFormat:@"\t<div style=\"width: 100%%; text-align: left;\">%@: %@</div>\n", label, price];
}

- (void)loadData {
    NSNumberFormatter *formatter = [MRFormatters currencyFormatter];
    NSDictionary *dictionary = [MRJSONHelper objectFromData:_calculation.data];
    _textFieldPriceBase.text = [formatter stringFromNumber:dictionary[@"base"]];
    _textFieldPriceDealer.text = [formatter stringFromNumber:dictionary[@"dealer"]];
    _textFieldPriceSeason.text = [formatter stringFromNumber:dictionary[@"season"]];

    NSDateFormatter *dateFormatter = [MRFormatters dateFormatter];
    _textFieldCalculationDate.text = [dateFormatter stringFromDate:_calculation.date];
    _textFieldPriceDate.text = [dateFormatter stringFromDate:_calculation.priceDate];
    //_textViewInfo.text = [MRJSONHelper jsonFromObject:dictionary];

    [_webViewInfo loadHTMLString:[self htmlStringFromDictionary:dictionary showPrices:NO] baseURL:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view useDottedBackground];

    [self loadData];

    _labelCalculationDate.text = NSLocalizedString(@"Дата расчета", nil);
    _labelPriceDate.text = NSLocalizedString(@"Дата прайса", nil);
    _labelPriceBase.text = NSLocalizedString(@"Цена для пользователя, у.е.", nil);
    _labelPriceDealer.text = NSLocalizedString(@"Цена для дилера, у.е.", nil);
    _labelPriceSeason.text = NSLocalizedString(@"Сезонная цена, у.е.", nil);

    [_buttonChange setTitle:@"Изменить" forState:UIControlStateNormal];
    [_buttonEmail setTitle:@"Отправить по E-mail" forState:UIControlStateNormal];

    _textFieldPriceBase.enabled = !(_project.payedAmount && _project.factoryId);
    _buttonChange.enabled = _textFieldPriceBase.enabled;
}

- (IBAction)didTouchButtonChange {
    NSMutableDictionary *dictionary = [[MRJSONHelper objectFromData:_calculation.data] mutableCopy];

    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:_textFieldPriceBase.text];
    if (![number isEqualToNumber:[NSDecimalNumber notANumber]]) {
        dictionary[@"base"] = number;
        self.calculation.data = [MRJSONHelper jsonDataFromObject:dictionary];
        [[MRCalculationsDao sharedInstance] updateCalculation:self.calculation];
    }
}

- (IBAction)didTouchButtonEmail {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Отправка заказа", nil)
                                                        message:NSLocalizedString(@"Отправить заказ по электронной почте?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Закрыть", nil)
                                              otherButtonTitles:NSLocalizedString(@"Отправить", nil), nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        NSString *email = [settings objectForKey:@"gates.settings.email"];
        if (email.length) {
            NSDictionary *dictionary = [MRJSONHelper objectFromData:_calculation.data];
            [MRMailService.sharedInstance sendMessageToEmail:email
                                                     subject:NSLocalizedString(@"Yett.Gates.iOS Order", nil)
                                                        body:[self htmlStringFromDictionary:dictionary showPrices:YES]
                                                      isHTML:YES];
        }
    }
}

@end