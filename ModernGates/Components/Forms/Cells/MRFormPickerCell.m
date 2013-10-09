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
    [self updateControls];
    self.pickerElement.text = [self getPickerViewValue];
    [super updateCellFromElement];
}

- (void)updateControls {
    self.textValue.text = self.pickerElement.text;
    [self setPickerViewValue:self.pickerElement.text];
}

- (MRFormPickerElement *)pickerElement {
    return (MRFormPickerElement *)self.element;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self.textValue reloadInputViews];
	
	[super textFieldDidBeginEditing:textField];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSLog(@"Count: %d", self.pickerElement.items.count);
	return self.pickerElement.items.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSLog(@"Rows: %d", [self.pickerElement.items[component] count]);
	
	return [[self.pickerElement.items objectAtIndex:component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSLog(@"Index: %d", row);
    return [[[self.pickerElement.items objectAtIndex:component] objectAtIndex:row] description];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.pickerElement.text = [self getPickerViewValue];
    [self updateControls];
    [self notifyAboutValueWasChanged];
	[self setNeedsDisplay];
}

#pragma mark - Getting/setting value from UIPickerView

- (NSArray *)getSelectedIndices {
    NSMutableArray *componentsValues = [NSMutableArray array];
    
    for (int i = 0; i < _pickerView.numberOfComponents; i++) {
        NSInteger rowIndex = [_pickerView selectedRowInComponent:i];
        if (rowIndex >= 0) {
            [componentsValues addObject:[self pickerView:_pickerView titleForRow:rowIndex forComponent:i]];
        } else {
            [componentsValues addObject:[NSNull null]];
        }
    }
	
    return componentsValues;
}

- (NSString *)getPickerViewValue {
	NSArray *selections = [self getSelectedIndices];
	self.pickerElement.selectedIndices = selections;
    return [self.pickerElement.valueParser objectFromComponentsValues:selections];
}

- (void)setPickerViewValue:(NSString *)value {
    NSArray *componentsValues = [self.pickerElement.valueParser componentsValuesFromObject:value];
    
    for (int index = 0; index < componentsValues.count && _pickerView.numberOfComponents; index++) {
        id componentValue = [componentsValues objectAtIndex:(NSUInteger) index];
        NSInteger rowIndex = [[self.pickerElement.items objectAtIndex:index] indexOfObject:componentValue];
        if (rowIndex != NSNotFound) {
            [_pickerView selectRow:rowIndex inComponent:index animated:YES];
        }
    }
}

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
