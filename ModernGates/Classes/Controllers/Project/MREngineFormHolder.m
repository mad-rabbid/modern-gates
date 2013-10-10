#import "MREngineFormHolder.h"
#import "JSONKit.h"
#import "MRForm.h"
#import "MRModernEngineFormParser.h"
#import "MRFormRowElement.h"

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

@end