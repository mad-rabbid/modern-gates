#import "MREngineFormHolder.h"
#import "JSONKit.h"
#import "MRForm.h"
#import "MRModernEngineFormParser.h"
#import "MRFormRowElement.h"
#import "MRFormLabelElement.h"
#import "MRFormPickerElement.h"
#import "MRFormBooleanElement.h"
#import "MRFormNumberElement.h"

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
                values[key] = [self elementValue:editableElement];
            } else if ([element isKindOfClass:MRFormBooleanElement.class]) {
                MRFormBooleanElement *booleanElement = (MRFormBooleanElement *)element;
                values[key] = @(booleanElement.isOn);
            }

            [script appendFormat:kMRVariableFormat, key, [self scriptValueWithValue:values[key]]];
        }

        return NO;
    }];

    [script appendFormat:@"\nvar expressions = %@;", [self prepareExpresstionsScriptPart:expressions]];
    MRLog(@"Values: %@", values);
    MRLog(@"Expressions: %@", expressions);
    MRLog(@"Script: %@", script);

    [self executeScript:script];
}

- (NSString *)prepareExpresstionsScriptPart:(NSDictionary *)expressions {
    NSMutableString *builder = [NSMutableString string];
    [builder appendString:@"{\n"];
    [expressions enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *list, BOOL *stop) {
        if (builder.length > 2) {
            [builder appendString:@",\n"];
        }

        [builder appendFormat:@"\t\"%@\" : [\n", key];

        __block BOOL isFirst = YES;
        [list enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop1) {
            if (!isFirst) {
                [builder appendString:@"\t\t,\n"];
            } else {
                isFirst = NO;
            }

            NSMutableString *internalBuilder = [NSMutableString string];
            [internalBuilder appendString:@"\t\t{\n"];
            [self appendParameter:dictionary[@"text"] label:@"expression" builder:internalBuilder];
            [self appendParameter:dictionary[@"newval"] label:@"newValue" builder:internalBuilder];
            [internalBuilder appendString:@"\n\t\t}\n"];
            [builder appendString:internalBuilder];
        }];
        [builder appendString:@"\t]"];
    }];
    [builder appendString:@"}"];
    return builder;
}

- (void)appendParameter:(NSString *)parameter label:(NSString *)label builder:(NSMutableString *)builder {
    if (parameter.length && ![parameter isEqualToString:@"select"]) {
        if (builder.length > 4) {
            [builder appendString:@",\n"];
        }
        [builder appendFormat:@"\t\t\t\"%@\" : %@", label, parameter];
    }
}

- (id)elementValue:(MRFormEditableElement *)element {
    id value;
    if ([element isKindOfClass:MRFormNumberElement.class]) {
        value = element.text ? [NSDecimalNumber decimalNumberWithString:element.text] : @(0);
    } else {
        value = element.text ?: @"";
    }
    return value;
}

- (NSString *)scriptValueWithValue:(id)value {
    return [value isKindOfClass:NSNumber.class] ? value : [NSString stringWithFormat:@"'%@'", value];
}

- (void)executeScript:(NSString *)script {
    static NSString *template = @"(function() {\n"
                "%@\n"
                "return JSON.stringify(expressions);"
            "})();\n";

    NSString *data = [NSString stringWithFormat:template, script];

    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:data];
    NSLog(@"Result: %@", result);

}
@end