#import "MREngineFormHolder.h"
#import "JSONKit.h"
#import "MRForm.h"
#import "MRFormSection.h"
#import "MRFormLabelElement.h"
#import "MRFormBooleanElement.h"

@interface MREngineFormHolder ()
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
}

@end