#import "MRForm.h"
#import "MRFormSection.h"
#import "MRFormRowElement.h"


@implementation MRForm {
	
}

@synthesize sections;

- (id)init {
	self = [super init];
	if (self) {
		self.sections = [NSMutableArray array];
	}
	return self;
}

- (void)addSection:(MRFormSection *)section {
    section.form = self;
	[self.sections addObject:section];
}

- (NSInteger)sectionsCount {
	return [self.sections count];
}

- (void)fetchValueIntoObject:(id)object {
    for (MRFormSection *section in sections) {
        [section fetchValueIntoObject:object];
    }
}

- (MRFormRowElement *)elementWithKey:(NSString *)key {
    for (MRFormSection *section in sections) {
        for (MRFormElement *element in section.elements) {
            if ([element isKindOfClass:MRFormRowElement.class]) {
                MRFormRowElement *rowElement = (MRFormRowElement *)element;
                if ([rowElement.fetchKey isEqualToString:key]) {
                    return rowElement;
                }
            }
        }
    }
    return nil;

}
@end
