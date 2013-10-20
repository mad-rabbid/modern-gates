#import "MREngineFormHolder.h"
#import "JSONKit.h"
#import "MRForm.h"
#import "MRModernEngineFormParser.h"
#import "MRFormRowElement.h"
#import "MRFormLabelElement.h"
#import "MRFormPickerElement.h"
#import "MRFormBooleanElement.h"

static NSString *const kMRVariableFormat = @"var %@ = %@;\n";

@interface MREngineFormHolder () <MRFormElementDelegate>
@property (nonatomic, strong) NSDictionary *source;

@property (nonatomic, strong) MRForm *form;
@property (nonatomic, strong) NSDictionary *elements;
@end

@implementation MREngineFormHolder {

}

- (id)initWithProjectType:(NSString *)type {
    self = [super init];
    if (self) {
        [self loadProjectWithType:type];
    }
    return self;
}

- (void)loadProjectWithType:(NSString *)type {
    NSString *relativePath = [NSString stringWithFormat:@"MRModernEngines.bundle/%@/wizard.json", type];
    NSString *path = [NSBundle.mainBundle pathForResource:relativePath ofType:nil];

    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.source = [jsonString objectFromJSONString];

    MRModernEngineFormParser *parser = [[MRModernEngineFormParser alloc] initWithDictionary:self.source];
    parser.delegate = self;
    [parser parse];
    self.form = parser.form;
}

- (void)valueChangedForElement:(MRFormRowElement *)element {
    if (self.delegate) {
        [self.delegate valueChangedForElement:element];
    }
}

- (void)template {
    __block NSMutableDictionary *values = [NSMutableDictionary dictionary];
    __block NSMutableDictionary *expressions = [NSMutableDictionary dictionary];

    NSMutableString *script = [NSMutableString string];
    [self.form enumerateElementsWithBlock:^BOOL(MRFormSection *section, MRFormLabelElement *element) {
        if ([element isKindOfClass:MRFormPickerElement.class]) {
            MRFormPickerElement *pickerElement = (MRFormPickerElement *)element;
            [pickerElement.items enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                NSString *key = [NSString stringWithFormat:@"$%@$", item[@"value"]];
                values[key] = @(idx == pickerElement.selectedIndex);

                if (item[@"expressions"]) {
                    expressions[item[@"value"]] = item[@"expressions"];
                }

                [script appendFormat:kMRVariableFormat, key, values[key]];
            }];
        } else {
            if (element.expressions) {
                expressions[element.fetchKey] = element.expressions;
            }

            NSString *key = [NSString stringWithFormat:@"$%@$", element.fetchKey];
            if ([element isKindOfClass:MRFormEditableElement.class]) {
                MRFormEditableElement *editableElement = (MRFormEditableElement *)element;
                values[key] = @(editableElement.text.length > 0);
            } else if ([element isKindOfClass:MRFormBooleanElement.class]) {
                MRFormBooleanElement *booleanElement = (MRFormBooleanElement *)element;
                values[key] = @(booleanElement.isOn);
            }

            [script appendFormat:kMRVariableFormat, key, values[key]];
        }


        return NO;
    }];

    [script appendFormat:@"\nvar expressions = %@;", [expressions JSONString]];
    MRLog(@"Values: %@", values);
    MRLog(@"Expressions: %@", expressions);
    MRLog(@"Script: %@", script);
}

@end