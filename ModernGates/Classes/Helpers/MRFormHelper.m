#import "MRFormHelper.h"
#import "MRForm.h"
#import "MRFormSection.h"
#import "MRFormRowElement.h"
#import "MRFormLabelInfoElement.h"
#import "MRFormEditableElement.h"
#import "MRFormPickerElement.h"
#import "MRFormBooleanElement.h"
#import "MRFormNumberElement.h"
#import "MagicalRecord.h"


@implementation MRFormHelper {
    __weak id <MRFormElementDelegate> _delegate;
    __strong NSDictionary *_settings;
}


- (id)initWithSettings:(NSDictionary *)settings delegate:(id <MRFormElementDelegate>)delegate {
    self = [super init];
    if (self) {
        _settings = settings;
        _delegate = delegate;
    }

    return self;
}

+ (id)helperWithSettings:(NSDictionary *)settings delegate:(id <MRFormElementDelegate>)delegate {
    return [[MRFormHelper alloc] initWithSettings:settings delegate:delegate];
}

- (MRForm *)parseFormElements:(NSArray *)elements sectionName:(NSString *)sectionName formErrors:(NSDictionary *)formErrors errors:(NSMutableArray *)errors {
    MRForm *form = [MRForm new];
    MRFormSection *section = [MRFormSection new];
    [form addSection:section];

    [elements enumerateObjectsUsingBlock:^(NSDictionary *element, NSUInteger idx, BOOL *stop) {
        NSString *type = element[@"type"];
        if (!type.length) {

            [errors addObject:NSLocalizedString(@"Тип элемента не задан", nil)];

            return;
        }

        MRFormLabelElement *rowElement = nil;
        if ([type isEqualToString:@"number"]) {
            rowElement = [self numberElementWithDictionary:element delegate:_delegate errors:errors];
        } else if ([type isEqualToString:@"select"]) {
            rowElement = [self pickerElementWithDictionary:element delegate:_delegate errors:errors];
        } else if ([type isEqualToString:@"boolean"]) {
            rowElement = [self booleanElementWithDictionary:element delegate:_delegate errors:errors];
        } else if ([type isEqualToString:@"text"]) {
            rowElement = [self editableElementWithDictionary:element errors:errors];
        } else if ([type isEqualToString:@"info"]) {
            rowElement = [self labelElementWithDictionary:element errors:errors];
        } else {
            [errors addObject:[NSString stringWithFormat:NSLocalizedString(@"Неизвестный тип элемента '%@'", nil), type]];
        }

        if (rowElement) {
            if (sectionName && formErrors) {
                NSString *errorKey = [sectionName stringByAppendingFormat:@".%@", rowElement.fetchKey];
                rowElement.errorText = formErrors[errorKey];
            }
            [section addElement:rowElement];
        }


    }];

    return form;
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

- (MRFormNumberElement *)numberElementWithDictionary:(NSDictionary *)source delegate:(id <MRFormElementDelegate>)delegate errors:(NSMutableArray *)errors {
    MRFormNumberElement *element = [MRFormNumberElement new];
    [self setupElement:element source:source delegate:delegate];
    element.number = [self parseNumber:source[@"value"]];
    return element;
}

- (MRFormLabelInfoElement *)labelElementWithDictionary:(NSDictionary *)source errors:(NSMutableArray *)errors {
    MRFormLabelInfoElement *element = [MRFormLabelInfoElement new];
    [self setupElement:element source:source];
    NSString *value = source[@"value"];
    element.info = value ? value : @"";
    return element;
}

- (MRFormEditableElement *)editableElementWithDictionary:(NSDictionary *)source errors:(NSMutableArray *)errors {
    MRFormEditableElement *element = [MRFormEditableElement new];
    [self setupElement:element source:source];
    NSString *value = source[@"value"];
    element.text = value ? value : @"";
    return element;
}

- (MRFormPickerElement *)pickerElementWithDictionary:(NSDictionary *)source delegate:(id <MRFormElementDelegate>)delegate errors:(NSMutableArray *)errors {
    NSArray *items = nil;
    if ([source[@"items"] isKindOfClass:NSString.class]) {
        NSDictionary *dictionary = _settings[@"dictionaries"];
        if (dictionary.count) {
            NSArray *commonItems = dictionary[source[@"items"]];
            if ([commonItems isKindOfClass:NSArray.class]) {
                items = commonItems;
            }
        }
    } else if ([source[@"items"] isKindOfClass:NSArray.class]) {
        items = source[@"items"];
    }



    if (!items) {
        [errors addObject:[NSString stringWithFormat:NSLocalizedString(@"Неизвестный тип элемента селектора '%@'", nil), source[@"name"]]];
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

    [self setupElement:element source:source delegate:delegate];


    return element;
}

- (MRFormBooleanElement *)booleanElementWithDictionary:(NSDictionary *)source delegate:(id <MRFormElementDelegate>)delegate errors:(NSMutableArray *)errors {
    MRFormBooleanElement *element = [MRFormBooleanElement new];
    [self setupElement:element source:source delegate:delegate];
    element.on = [@"true" isEqualToString:[source[@"value"] lowercaseString]];
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
    element.label = source[@"label"] ? source[@"label"] : NSLocalizedString(@"Not set", nil);

    element.label = NSLocalizedString(element.label, nil);

    element.fetchKey = source[@"name"];
    element.delegate = delegate;
    element.hidden = [self parseBoolean:source[@"hidden"]];
}
@end