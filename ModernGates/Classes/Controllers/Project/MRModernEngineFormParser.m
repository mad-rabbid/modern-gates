#import "MRModernEngineFormParser.h"
#import "MRForm.h"
#import "MRFormSection.h"
#import "MRFormLabelElement.h"
#import "MRFormPickerElement.h"
#import "MRFormBooleanElement.h"
#import "MRFormNumberElement.h"
#import "MRFormLabelInfoElement.h"

@interface MRModernEngineFormParser ()
@property (nonatomic, strong) NSDictionary *source;

@property (nonatomic, strong) MRForm *form;
@property (nonatomic, strong) NSMutableDictionary *elements;
@property (nonatomic, strong) NSMutableArray *errors;

@property (nonatomic, strong) MRFormPickerElement *picker;
@end

@implementation MRModernEngineFormParser {

}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.source = [dictionary copy];
    }
    return self;
}


- (NSDictionary *)formElements {
    return [NSDictionary dictionaryWithDictionary:self.elements];
}

- (NSArray *)parseErrors {
    return [NSArray arrayWithArray:self.errors];
}

- (BOOL)parse {
    self.form = [MRForm new];

    self.elements = [NSMutableDictionary dictionary];
    self.errors = [NSMutableArray array];


    MRFormSection *currentSection = nil;
    for (NSDictionary *dictionary in self.source[@"inputBlocks"]) {
        NSString *sectionTitle = dictionary[@"groupHead"];
        if (sectionTitle.length) {
            [self addSection:currentSection toForm:self.form];
            currentSection = [MRFormSection new];
            currentSection.title = sectionTitle;
        } else {
            if (!currentSection) {
                currentSection = [MRFormSection new];
            }
        }

    }

    [self addSection:currentSection toForm:self.form];
    return !self.errors.count;
}

- (void)addSection:(MRFormSection *)section toForm:(MRForm *)form {
    if (section) {
        [form addSection:section];
    }
}

- (void)parseElementWithDictionary:(NSDictionary *)dictionary section:(MRFormSection *)section {
    NSString *type = dictionary[@"type"];
    if (!type.length) {

        [self.errors addObject:NSLocalizedString(@"Тип элемента не задан", nil)];

        return;
    }

    if (self.picker && (![type isEqualToString:@"radio"] || ![dictionary[@"groupName"] isEqual:self.picker.fetchKey])) {
        self.picker = nil;
    }

    MRFormLabelElement *row = nil;
    if ([type isEqualToString:@"number"]) {
        row = [self numberElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"radio"]) {
        row = [self pickerElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"checkbox"]) {
        row = [self booleanElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"text"]) {
        row = [self editableElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"info"]) {
        row = [self labelElementWithDictionary:dictionary];
    } else {
        [self.errors addObject:[NSString stringWithFormat:NSLocalizedString(@"Неизвестный тип элемента '%@'", nil), type]];
    }

    if (row) {
        [section addElement:row];
    }
}

- (void)updateValuesFromFormSection:(MRFormSection *)section dictionary:(NSDictionary *)dictionary {
    [section.elements enumerateObjectsUsingBlock:^(MRFormLabelElement *labelElement, NSUInteger idx, BOOL *stop) {
        NSString *key = labelElement.fetchKey;
        __block NSString *value = nil;
        if ([labelElement isMemberOfClass:MRFormNumberElement.class]) {
            value = [((MRFormNumberElement *) labelElement).number stringValue];
        } else if ([labelElement isMemberOfClass:MRFormEditableElement.class]) {
            value = ((MRFormEditableElement *) labelElement).text;
        } else if ([labelElement isMemberOfClass:MRFormPickerElement.class]) {
            MRFormPickerElement *picker = ((MRFormPickerElement *) labelElement);
            if (picker.selectedIndices.count) {
                MRLog(@"Picker %@ value %@ !!!", key, picker.selectedIndices[0]);

                [picker.source enumerateObjectsUsingBlock:^(NSDictionary *current, NSUInteger idx1, BOOL *stop1) {
                    if ([current[@"label"] isEqualToString:picker.text]) {
                        value = current[@"value"];
                        *stop1 = YES;
                    }
                }];
            }
        } else if ([labelElement isMemberOfClass:MRFormBooleanElement.class]) {
            value = ((MRFormBooleanElement *) labelElement).isOn ? @"true" : @"false";
        } else {
            return;
        }

        NSLog(@"key: %@, value: %@", key, value);
        dictionary[key][@"value"] = value.length ? value : @"";
    }];
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
    NSArray *items = nil;
    if ([source[@"items"] isKindOfClass:NSString.class]) {
        NSDictionary *dictionary = nil;//_settings[@"dictionaries"];
        if (dictionary.count) {
            NSArray *commonItems = dictionary[source[@"items"]];
            if ([commonItems isKindOfClass:NSArray.class]) {
                items = commonItems;
            }
        }
    } else if ([source[@"items"] isKindOfClass:NSArray.class]) {
        items = source[@"items"];
    }

    MRLog(@"Picker %@ value %@", source[@"name"], source[@"value"]);

    __block NSString *value = source[@"value"];

    NSMutableArray *textItems = nil;
    if (items) {
        textItems = [NSMutableArray arrayWithCapacity:items.count];
        [items enumerateObjectsUsingBlock:^(NSDictionary *current, NSUInteger idx, BOOL *stop) {
            NSString *label = NSLocalizedString(current[@"label"], nil);
            [textItems addObject:label];
            if (value.length && [current[@"value"] isEqualToString:value]) {
                value = label;
            }
        }];
    } else {
        value = nil;
    }

    MRFormPickerElement *element = [[MRFormPickerElement alloc] initWithItems:(textItems ? @[textItems] : @[]) value:value];
    element.source = items;

    [self setupElement:element source:source delegate:_delegate];


    return element;
}

- (MRFormBooleanElement *)booleanElementWithDictionary:(NSDictionary *)source {
    MRFormBooleanElement *element = [MRFormBooleanElement new];
    [self setupElement:element source:source delegate:_delegate];
    element.on = [@"on" isEqualToString:[source[@"defaultVal"] lowercaseString]];
    return element;
}


- (BOOL)parseBoolean:(NSNumber *)number {
    return [number boolValue];
}

- (NSDecimalNumber *)parseNumber:(NSString *)source {
    NSDecimalNumber *result = source ? [NSDecimalNumber decimalNumberWithString:source] : nil;
    return result && [[NSDecimalNumber notANumber] compare:result] != NSOrderedSame ? result : NSDecimalNumber.zero;
}

- (void)setupElement:(MRFormLabelElement *)element source:(NSDictionary *)source {
    [self setupElement:element source:source delegate:nil];
}

- (void)setupElement:(MRFormLabelElement *)element source:(NSDictionary *)source delegate:(id <MRFormElementDelegate>)delegate {
    element.label = source[@"name"] ? source[@"name"] : NSLocalizedString(@"Not set", nil);

    element.label = NSLocalizedString(element.label, nil);

    element.fetchKey = source[@"code"];
    element.delegate = delegate;
    element.disabled = ![[source[@"activity"] lowercaseString] isEqualToString:@"on"];
    element.hidden = [self parseBoolean:source[@"hidden"]];
}

@end