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
            if (self.picker) {
                [self appendPickerToSection:currentSection];
            }
            [self addSection:currentSection toForm:self.form];
            currentSection = [MRFormSection new];
            currentSection.title = sectionTitle;
        } else {
            if (currentSection) {
                [self parseElementWithDictionary:dictionary section:currentSection];
            }
        }

    }

    [self addSection:currentSection toForm:self.form];
}

- (void)addSection:(MRFormSection *)section toForm:(MRForm *)form {
    if (section) {
        [form addSection:section];
    }
}

- (void)appendPickerToSection:(MRFormSection *)section {
    self.picker.items = self.items;
    if (section) {
        [section addElement:self.picker];
    }
    self.items = nil;
    self.picker = nil;

}

- (void)parseElementWithDictionary:(NSDictionary *)dictionary section:(MRFormSection *)section {
    NSString *type = dictionary[@"type"];
    if (!type.length) {
        MRLog(@"Тип элемента не задан: %@", dictionary);
        return;
    }

    if (self.picker && (![type isEqualToString:@"radio"] || ![dictionary[@"group"] isEqual:self.picker.fetchKey])) {
        [self appendPickerToSection:section];
    }

    MRFormLabelElement *row = nil;
    if ([type isEqualToString:@"number"]) {
        row = [self editableElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"radio"]) {
        [self parsePickerElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"checkbox"]) {
        row = [self booleanElementWithDictionary:dictionary];
    } else if ([type isEqualToString:@"text"]) {
        row = [self numberElementWithDictionary:dictionary];
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
        self.picker.label = source[@"groupName"];
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

    id expressions = source[@"expressions"];
    if (expressions)  {
        item[@"expressions"] = [self prepareExpressions:expressions];
    }
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
    element.label = source[@"name"];

    element.label = NSLocalizedString(element.label, nil);

    element.fetchKey = source[@"code"];
    element.groupKey = source[@"group"];

    element.delegate = delegate;
    element.disabled = ![[source[@"activity"] lowercaseString] isEqualToString:@"on"] || [source[@"type"] isEqualToString:@"number"];
    element.hidden = [self parseBoolean:source[@"hidden"]];

    if (![source[@"type"] isEqualToString:@"radio"]) {
        id expressions = source[@"expressions"];
        if (expressions)  {
            element.expressions = [self prepareExpressions:expressions];
        }
    }
}

- (NSArray *)prepareExpressions:(NSArray *)source {
    NSMutableArray *result = [source mutableCopy];

    for (NSInteger index = 0; index < result.count; index++) {
        NSMutableDictionary *dictionary = [result[index] mutableCopy];

        [self prepareExpressionWithName:@"text" inDictionary:dictionary];
        [self prepareExpressionWithName:@"newval" inDictionary:dictionary];

        result[index] = dictionary;
    }

    return [NSMutableArray arrayWithArray:result];
}

- (void)prepareExpressionWithName:(NSString *)name inDictionary:(NSMutableDictionary *)dictionary {
    NSString *expression = dictionary[name];
    if (expression) {
        dictionary[name] = [expression stringByReplacingOccurrencesOfString:@"#" withString:@"$"];
    }
}
@end