#import "MRFormHelper.h"
#import "MRForm.h"
#import "MRFormSection.h"
#import "MRFormRowElement.h"
#import "MRFormLabelInfoElement.h"
#import "MRFormEditableElement.h"
#import "MRFormPickerElement.h"
#import "MRFormBooleanElement.h"
#import "MRFormNumberElement.h"


@implementation MRFormHelper {
    __weak id <MRFormElementDelegate> _delegate;
    __strong NSArray *_settings;
}


- (id)initWithSections:(NSArray *)sections delegate:(id <MRFormElementDelegate>)delegate {
    self = [super init];
    if (self) {
        _settings = sections;
        _delegate = delegate;
    }

    return self;
}

+ (id)helperWithSections:(NSArray *)sections delegate:(id <MRFormElementDelegate>)delegate {
    return [[MRFormHelper alloc] initWithSections:sections delegate:delegate];
}

- (MRForm *)parse {
    MRForm *form = [MRForm new];

    for (NSDictionary *section in _settings) {
        MRFormSection *currentSection = [MRFormSection new];
        currentSection.title = section[@"label"];
        [form addSection:currentSection];

        for (NSDictionary *element in section[@"elements"]) {
            MRFormLabelElement *currentElement = [self parseElementWithDictionary:element];
            if (currentElement) {
                [currentSection addElement:currentElement];
            }
        }
    }

    return form;
}

- (MRFormLabelElement *)parseElementWithDictionary:(NSDictionary *)dictionary {
    NSString *type = dictionary[@"type"];
    if (!type.length) {
        MRLog(@"Тип элемента не задан, %@", dictionary);
        return nil;
    }

    MRFormLabelElement *result = nil;
    if ([type isEqualToString:@"number"]) {
        result = [self numberElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"select"]) {
        result = [self pickerElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"boolean"]) {
        result = [self booleanElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"text"]) {
        result = [self editableElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"info"]) {
        result = [self labelElementWithDictionary:dictionary];
    } else {
        MRLog(@"Неизвестный тип элемента '%@', %@", type, dictionary);
    }

    return result;
}

- (MRFormNumberElement *)numberElementWithDictionary:(NSDictionary *)source {
    MRFormNumberElement *element = [MRFormNumberElement new];
    [self setupElement:element source:source delegate:_delegate];
    element.number = [self parseNumber:source[@"value"]];
    return element;
}

- (MRFormLabelInfoElement *)labelElementWithDictionary:(NSDictionary *)source {
    MRFormLabelInfoElement *element = [MRFormLabelInfoElement new];
    [self setupElement:element source:source];
    NSString *value = source[@"value"];
    element.info = value ? value : @"";
    return element;
}

- (MRFormEditableElement *)editableElementWithDictionary:(NSDictionary *)source {
    MRFormEditableElement *element = [MRFormEditableElement new];
    [self setupElement:element source:source];
    NSString *value = source[@"value"];
    element.text = value ? value : @"";
    return element;
}

- (MRFormPickerElement *)pickerElementWithDictionary:(NSDictionary *)source {
   NSMutableArray *localizedItems = [NSMutableArray new];
    for (NSDictionary *item in source[@"items"]) {
        NSMutableDictionary *localizedItem = [item mutableCopy];
        localizedItem[@"label"] = NSLocalizedString(localizedItem[@"label"], nil);
        [localizedItems addObject:localizedItem];
    }


    MRFormPickerElement *element = [MRFormPickerElement new];
    [self setupElement:element source:source delegate:_delegate];
    element.items = localizedItems;
    return element;
}

- (MRFormBooleanElement *)booleanElementWithDictionary:(NSDictionary *)source {
    MRFormBooleanElement *element = [MRFormBooleanElement new];
    [self setupElement:element source:source delegate:_delegate];
    element.on = [@"true" isEqualToString:[source[@"value"] lowercaseString]];
    return element;
}


- (BOOL)parseBoolean:(NSNumber *)number {
    return [number boolValue];
}

- (NSDecimalNumber *)parseNumber:(NSString *)source {
    NSDecimalNumber *result = source ? [NSDecimalNumber decimalNumberWithString:source] : nil;
    return (result && [[NSDecimalNumber notANumber] compare:result]) ? result : NSDecimalNumber.zero;
}

- (void)setupElement:(MRFormLabelElement *)element source:(NSDictionary *)source {
    [self setupElement:element source:source delegate:nil];
}

- (void)setupElement:(MRFormLabelElement *)element source:(NSDictionary *)source delegate:(id <MRFormElementDelegate>)delegate {
    element.label = source[@"label"] ?: NSLocalizedString(@"Not set", nil);

    element.label = NSLocalizedString(element.label, nil);

    element.fetchKey = source[@"name"];
    element.delegate = delegate;
    element.hidden = [self parseBoolean:source[@"hidden"]];
}
@end