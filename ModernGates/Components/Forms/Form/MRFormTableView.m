#import "MRFormTableView.h"
#import "MRFormDataSource.h"
#import "MRForm.h"
#import "MRFormSection.h"
#import "MRFormTableViewDelegate.h"

@implementation MRFormTableView {
	__strong id <UITableViewDataSource> formDataSource;
    __strong id <UITableViewDelegate> formDelegate;
}

- (void)awakeFromNib {	
	formDataSource = [[MRFormDataSource alloc] initWithTableView:self];
	self.dataSource = formDataSource;
	
	formDelegate = [[MRFormTableViewDelegate alloc] initWithTableView:self];
	self.delegate = formDelegate;

	self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)reloadForm  {
    [((MRFormDataSource *) formDataSource) reloadForm];
}

- (MRForm *)form {
    return [(MRFormDataSource *)formDataSource form];
}

- (void)setForm:(MRForm *)form {
    ((MRFormDataSource *)formDataSource).form = form;
}

- (NSIndexPath *)indexForElement:(MRFormRowElement *)element {
    __block NSIndexPath *result = nil;
    [self.form.sections enumerateObjectsUsingBlock:^(MRFormSection *currSection, NSUInteger idx, BOOL *stop) {
        NSInteger row = [currSection visibleIndexOfElement:element];
        if (row != NSNotFound) {
            result = [NSIndexPath indexPathForRow:row inSection:idx];
            *stop = YES;
        }
    }];
    return result;
}

- (UITableViewCell *)cellForElement:(MRFormRowElement *)element {
    return [self cellForRowAtIndexPath:[self indexForElement:element]];
}
@end
