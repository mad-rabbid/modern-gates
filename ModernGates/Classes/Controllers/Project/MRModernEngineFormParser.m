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

@property (nonatomic, strong) MRFormPickerElement *picker;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation MRModernEngineFormParser {

}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.source = dictionary;
    }
    return self;
}

- (void)parse {
    self.form = [MRForm new];

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
            [self parseElementWithDictionary:dictionary section:currentSection];
        }

    }

    [self addSection:currentSection toForm:self.form];
}

- (void)addSection:(MRFormSection *)section toForm:(MRForm *)form {
    if (section) {
        [form addSection:section];
    }
}

- (void)parseElementWithDictionary:(NSDictionary *)dictionary section:(MRFormSection *)section {
    NSString *type = dictionary[@"type"];
    if (!type.length) {
        MRLog(@"Тип элемента не задан: %@", dictionary);
        return;
    }

    if (self.picker && (![type isEqualToString:@"radio"] || ![dictionary[@"groupName"] isEqual:self.picker.fetchKey])) {
        [section addElement:self.picker];
        self.picker = nil;
    }

    MRFormLabelElement *row = nil;
    if ([type isEqualToString:@"number"]) {
        row = [self numberElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"radio"]) {
        [self parsePickerElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"checkbox"]) {
        row = [self booleanElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"text"]) {
        row = [self editableElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"info"]) {
        row = [self labelElementWithDictionary:dictionary];
    } else {
        MRLog(@"Неизвестный тип элемента '%@', %@", type, dictionary);
    }

    if (row) {
        [section addElement:row];
    }
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
    element.info = value ?: @"";
    return element;
}

- (MRFormEditableElement *)editableElementWithDictionary:(NSDictionary *)source {
    MRFormEditableElement *element = [MRFormEditableElement new];
    [self setupElement:element source:source];
    NSString *value = source[@"value"];
    element.text = value ? value : @"";
    return element;
}

- (void)parsePickerElementWithDictionary:(NSDictionary *)source {
    if (!self.picker) {
        self.picker = [[MRFormPickerElement alloc] init];
        [self setupElement:self.picker source:source delegate:_delegate];
        self.picker.label = source[@"groupName"] ?: NSLocalizedString(@"Not set", nil);
        self.picker.fetchKey = source[@"group"];
        self.picker.groupKey = self.picker.fetchKey;
        self.items = [NSMutableArray array];
    }

    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    if (source[@"name"]) {
        item[@"label"] = source[@"name"];
    }

    if (source[@"code"]) {
        item[@"value"] = source[@"code"];
    }

    if (source[@"commentHover"]) {
        item[@"comment"] = source[@"commentHover"];
    }

    item[@"expressions"] = [source[@"expressions"] copy];
    [self.items addObject:item];
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
    element.groupKey = source[@"group"];

    element.delegate = delegate;
    element.disabled = ![[source[@"activity"] lowercaseString] isEqualToString:@"on"];
    element.hidden = [self parseBoolean:source[@"hidden"]];

    if (![source[@"type"] isEqualToString:@"radio"]) {
        element.expressions = [source[@"expressions"] copy];
    }
}

@end