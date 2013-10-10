#import "MRFormPickerCell.h"
#import "MRFormPickerElement.h"

@implementation MRFormPickerCell {
	__strong UIView *_pickerHost;
	__strong UIPickerView *_pickerView;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];

	_pickerHost = [[UIView alloc] initWithFrame:CGRectZero];
	_pickerHost.autoresizingMask = (UIViewAutoresizingNone);
	_pickerHost.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	
	_pickerView = [[UIPickerView alloc] init];
	_pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	
	_pickerView.showsSelectionIndicator = YES;
	_pickerView.dataSource = self;
	_pickerView.delegate = self;
	
	_pickerHost.frame = _pickerView.frame;
	
	[_pickerHost addSubview:_pickerView];
	self.textValue.inputView = _pickerHost;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
	
}

- (void)updateCellFromElement {
    [_pickerView reloadAllComponents];

    if (self.pickerElement.selectedIndex >= 0) {
        [_pickerView selectRow:self.pickerElement.selectedIndex inComponent:0 animated:YES];
    }

    self.pickerElement.text = [self.pickerElement labelForItemAtIndex:self.pickerElement.selectedIndex];
    [super updateCellFromElement];
}

- (MRFormPickerElement *)pickerElement {
    return (MRFormPickerElement *)self.element;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self.textValue reloadInputViews];
	
	[super textFieldDidBeginEditing:textField];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSLog(@"Rows: %d", self.pickerElement.items.count);
	
	return self.pickerElement.items.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSLog(@"Index: %d", row);
    return [self.pickerElement.items[row] description];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.pickerElement.selectedIndex = row;
    self.pickerElement.text = [self.pickerElement labelForItemAtIndex:row];
    self.textValue.text = self.pickerElement.text;

    [self notifyAboutValueWasChanged];
	[self setNeedsDisplay];
}

#pragma mark - Getting/setting value from UIPickerView

- (void)keyboardDidAppear:(NSNotification *)notification {
	if (self.superview && self.textValue.isFirstResponder) {
		
		//[_pickerView setNeedsLayout];
		CGRect keyboardFrame = [self convertRect:[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
		
		CGRect frame = 	_pickerHost.frame;
		frame.size = keyboardFrame.size;
		if (self.textValue.inputAccessoryView) {
			frame.size.height -= self.textValue.inputAccessoryView.bounds.size.height;
		}
		_pickerHost.frame = frame;
	}
}
@end
