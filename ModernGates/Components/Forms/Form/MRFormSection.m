#import "MRFormSection.h"
#import "MRFormRowElement.h"

@implementation MRFormSection {
}

@synthesize title;
@synthesize form;
@synthesize elements;

- (id)init {
	self = [super init];
	if (self) {
		self.elements = [NSMutableArray array];
	}
	return self;
}

- (NSInteger) elementsCount {
	return [elements count];
}

- (NSInteger) visibleElementsCount {
	__block NSInteger visibleCount = 0;
	[self.elements enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
		MRFormRowElement *current = (MRFormRowElement *)object;
		if (!current.hidden) {
			visibleCount++;
		}
	}];
	
	return visibleCount;
}

- (NSInteger)visibleIndexOfElement:(MRFormRowElement *)element {
	__block NSInteger result = NSNotFound;
	__block NSInteger visibleIndex = 0;
	
	[self.elements enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
		MRFormRowElement *current = (MRFormRowElement *)object;
		if (!current.hidden) {
			if (current == element) {
				result = visibleIndex;
				*stop = YES;
			} else {
				visibleIndex++;
			}
		}
	}];
	
	return result;
}


- (MRFormRowElement *)elementAtIndex:(NSInteger)index {
	__block MRFormRowElement *result = nil;
	__block NSInteger visibleIndex = 0;
	
	[self.elements enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
		MRFormRowElement *current = (MRFormRowElement *)object;
		if (!current.hidden) {
			if (visibleIndex == index) {
				result = current;
				*stop = YES;
			} else {
				visibleIndex++;
			}
		}
	}];
	
	return result;
}

- (void)addElement:(MRFormRowElement *)element {
    element.section = self;
	[self.elements addObject:element];
}

- (void)fetchValueIntoObject:(id)object {
    for (MRFormRowElement *element in elements) {
        [element fetchValueIntoObject:(object)];
    }
}
@end
