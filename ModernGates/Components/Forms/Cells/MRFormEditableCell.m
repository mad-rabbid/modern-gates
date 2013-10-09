#import "MRFormEditableCell.h"
#import "MRFormTableView.h"
#import "MRFormRowElement.h"
#import "MRFormSection.h"
#import "MRForm.h"
#import "MRFormEditableElement.h"

@implementation MRFormEditableCell {
    UISegmentedControl *prevNext;
}

@synthesize textValue;

- (void)awakeFromNib {
	//self.textValue.background = [[UIImage imageNamed:@"edit-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    //self.textValue.borderStyle = UITextBorderStyleNone;
    [self.textValue addTarget:self action:@selector(didTextValueEditingChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (UIToolbar *)createActionBar {
    UIToolbar *toolbar = [UIToolbar new];
    toolbar.translucent = YES;
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [toolbar sizeToFit];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Готово", @"") style:UIBarButtonItemStyleDone target:self action:@selector(handleActionBarDone:)];
    
    prevNext = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Назад", @""), NSLocalizedString(@"Далее", @""), nil]];
    prevNext.momentary = YES;
    prevNext.segmentedControlStyle = UISegmentedControlStyleBar;
    prevNext.tintColor = toolbar.tintColor;
    [prevNext addTarget:self action:@selector(handleActionBarPreviousNext:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *prevNextWrapper = [[UIBarButtonItem alloc] initWithCustomView:prevNext];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:prevNextWrapper, flexible, doneButton, nil]];
    
	return toolbar;
}

- (void)updateCellForElement:(MRFormRowElement *)anElement andTableView:(MRFormTableView *)aTableView {
    textValue.text = ((MRFormEditableElement *)anElement).text;
    textValue.inputAccessoryView = [self createActionBar];
    
    [super updateCellForElement:anElement andTableView:aTableView];
    
    [self updatePrevNextStatus];
	//[self notificateAboutValueWasChanged];
}

#pragma mark - UITextField delegate -
- (void)textFieldEditingChanged:(UITextField *)textFieldEditingChanged {
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 50 * USEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexForElement:self.element] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
    
    
    if (textValue.returnKeyType == UIReturnKeyDefault) {
        UIReturnKeyType returnType = ([self findNextElement] != nil) ? UIReturnKeyNext : UIReturnKeyDone;
        textValue.returnKeyType = returnType;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (void)updateCellFromElement {
    [super updateCellFromElement];

    self.textValue.text = ((MRFormEditableElement *)self.element).text;
}

- (void)updateElementFromTextValue:(NSString *)value {
    ((MRFormEditableElement *)self.element).text = value;
}

- (void)didTextValueEditingChanged:(UITextField *)textField {
    [self updateElementFromTextValue:textField.text];
    //[self updateCellFromElement];

    [self notifyAboutValueWasChanged];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    MRFormRowElement *nextElement = [self findNextElement];
    if (nextElement) {
        UITableViewCell *cell = [self.tableView cellForElement:nextElement];
        if (cell) {
            [cell becomeFirstResponder];
        }
    }  else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)updatePrevNextStatus {
    [prevNext setEnabled:([self findPreviousElement] != nil) forSegmentAtIndex:0];
    [prevNext setEnabled:([self findNextElement] != nil) forSegmentAtIndex:1];
}

#pragma mark - Action bar handlers -
- (BOOL)handleActionBarDone:(NSObject *)sender {
    [self endEditing:YES];
    [self endEditing:NO];
    [textValue resignFirstResponder];
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    return NO;
}

- (void)handleActionBarPreviousNext:(NSObject *)sender {
	MRFormRowElement *target = (prevNext.selectedSegmentIndex == 1) ? [self findNextElement] : [self findPreviousElement];
	
	if (target) {
        UITableViewCell *cell = [self.tableView cellForElement:target];
		if (cell) {
			[cell becomeFirstResponder];
		} else {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 50 * USEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                UITableViewCell *aCell = [self.tableView cellForElement:self.element];
                if (aCell) {
                    [aCell becomeFirstResponder];
                }
            });
        }
	}
}

#pragma mark - Responder stuff -

- (BOOL)becomeFirstResponder {
    [textValue becomeFirstResponder];
    return YES;
}

- (BOOL)resignFirstResponder {
    return YES;
}

#pragma mark - Previous and next element search methods -

- (MRFormRowElement *)findPreviousElement {
    MRFormRowElement *previousElement = nil;
    for (MRFormSection *section in self.element.section.form.sections) {
        for (MRFormRowElement *current in section.elements) {
            if (current == self.element) {
                return previousElement;
            } else if ([current isKindOfClass:[MRFormEditableElement class]]){
                previousElement = (MRFormRowElement *)current;
            }
        }
    }
    return nil;
}

- (MRFormRowElement *)findNextElement {
    BOOL foundSelf = NO;
    for (MRFormSection *section in self.element.section.form.sections) {
        for (MRFormRowElement *current in section.elements) {
            if (current == self.element) {
                foundSelf = YES;
            } else if (foundSelf && [current isKindOfClass:[MRFormEditableElement class]]){
                return (MRFormRowElement *)current;
            }
        }
    }
    return nil;
}

@end
