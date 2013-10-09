#import "MRFormDataSource.h"
#import "MRForm.h"
#import "MRFormTableView.h"
#import "MRFormTextFieldCell.h"
#import "MRFormRowElement.h"
#import "MRFormSection.h"
#import "MRFormLabelCell.h"
#import "MagicalRecord.h"

@implementation MRFormDataSource {
	__weak MRFormTableView *_tableView;
}

- (id)initWithTableView:(MRFormTableView *)tableView {
    self = [super init];
    if (self) {
		_tableView = tableView;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UIView *)tableView {
	return [self.form sectionsCount];
}

- (NSString *)tableView:(UIView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.form.sections[section] title];
}

- (NSInteger)tableView:(UIView *)tableView numberOfRowsInSection:(NSInteger)section {
	MRFormSection *formSection = self.form.sections[section];
	return formSection.hidden ? 0 : formSection.visibleElementsCount;
}

- (UITableViewCell *)tableView:(UIView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MRFormTableView *table = [self convertToTableView:aTableView];
    
    MRFormSection *section = [self.form.sections objectAtIndex:indexPath.section];
    MRFormRowElement *element = [section elementAtIndex:indexPath.row];
    
    return [element getCellForTableView:table];
}

- (void)reloadAnElement:(MRFormRowElement *)element {
    MRFormLabelCell *cell = (MRFormLabelCell *)[_tableView cellForElement:element];
    cell.element = element;
	[cell updateCellFromElement];
	[cell setNeedsDisplay];
}

- (void)reloadForm {
    [self.form.sections enumerateObjectsUsingBlock:^(MRFormSection *section, NSUInteger idx, BOOL *stop) {
        [section.elements enumerateObjectsUsingBlock:^(MRFormRowElement *element, NSUInteger idx1, BOOL *stop1) {
            [self reloadAnElement:element];
        }];
    }];

}

- (void)showElements:(NSArray *)elementsToShow hideElements:(NSArray *)elementsToHide {
	MRLog(@"show : %@, hide: %@", elementsToShow, elementsToHide);
	
    NSMutableArray *removeIndices = [NSMutableArray array];
    for (MRFormRowElement *element in elementsToHide) {
        NSInteger section = [self.form.sections indexOfObject:element.section];
		
        NSInteger row = [element.section visibleIndexOfElement:element];
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        
		if (!element.section.isHidden) {
			[removeIndices addObject:path];
		}
    }
	
	for (MRFormRowElement *element in elementsToHide) {
        element.hidden = YES;
    }
	
	for (MRFormRowElement *element in elementsToShow) {
        element.hidden = NO;
    }
	
	NSMutableArray *insertIndices = [NSMutableArray array];
	for (MRFormRowElement *element in elementsToShow) {
        NSInteger section = [self.form.sections indexOfObject:element.section];
		
        NSInteger row = [element.section visibleIndexOfElement:element];
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        
		if (!element.section.isHidden) {
			[insertIndices addObject:path];
		}
    }

	if (!insertIndices.count && !removeIndices.count) {
		return;
	}

	MRLog(@"insert : %@, delete: %@", insertIndices, removeIndices);
	[_tableView beginUpdates];
	if (insertIndices.count) {
		[_tableView insertRowsAtIndexPaths:insertIndices withRowAnimation:UITableViewRowAnimationBottom];
	}
	
	if (removeIndices.count) {
		[_tableView deleteRowsAtIndexPaths:removeIndices withRowAnimation:UITableViewRowAnimationTop];
	}
	[_tableView endUpdates];
}
@end
