#import <QuartzCore/QuartzCore.h>
#import "MRLoginViewController.h"
#import "MKNetworkEngine.h"
#import "MRAppDelegate.h"
#import "JSONKit.h"

#define kMRTableViewFrame CGRectMake(0, 0, 320, 230)
#define kMRFooterViewHeight 80
#define kMRHeaderViewHeight 40
#define kMRTagBase 0xbeaf

enum {
    kMGRowLogin = 0,
    kMGRowPassword,
    kMGRowsNumber
} __unused;

@interface MRLoginViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIActivityIndicatorView *activityView;
@end

@implementation MRLoginViewController {
    __strong MKNetworkOperation *_operation;
}

- (void)dealloc {
    [self cancelLoginOperation];
}

- (void)cancelLoginOperation {
    if (_operation) {
        [_operation cancel];
        _operation = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.view.opaque = NO;

    UITableView *tableView = [[UITableView alloc] initWithFrame:kMRTableViewFrame style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];

    tableView.center = self.view.center;
    _tableView = tableView;

    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.hidesWhenStopped = YES;
    activityView.hidden = YES;
    activityView.center = self.view.center;

    [self.view addSubview:activityView];
    _activityView = activityView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kMGRowsNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kMGCellIdentifier = @"MGCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMGCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMGCellIdentifier];


        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textField.borderStyle = UITextBorderStyleNone;
        textField.tag = kMRTagBase;
        CGRect frame = CGRectInset(cell.contentView.bounds, 15, 0);
        frame.size.height = textField.font.lineHeight;
        textField.frame = frame;
        textField.center = cell.contentView.center;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:textField];
    }

    UITextField *field = (UITextField *) [cell.contentView viewWithTag:kMRTagBase];

    BOOL isPassword = (indexPath.row == kMGRowPassword);
    field.secureTextEntry = isPassword;
    field.placeholder = (isPassword) ? NSLocalizedString(@"Пароль", nil) : NSLocalizedString(@"Логин", nil);

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kMRFooterViewHeight)];
    view.backgroundColor = UIColor.clearColor;

    UIButton *buttonLogin = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonLogin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    buttonLogin.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];

    CGRect frame = CGRectInset(view.frame, 10, 0);
    frame.size.height = kMGButtonLoginHeight;
    buttonLogin.frame = frame;
    buttonLogin.center = view.center;
    buttonLogin.tag = kMRTagBase;
    [buttonLogin setTitle:NSLocalizedString(@"Войти", nil) forState:UIControlStateNormal];
    [buttonLogin addTarget:self action:@selector(didTouchButtonLogin:) forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:buttonLogin];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kMRFooterViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kMRHeaderViewHeight)];
    view.backgroundColor = UIColor.clearColor;

    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = UIColor.clearColor;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
    label.text = NSLocalizedString(@"Авторизация", nil);
    label.textAlignment = NSTextAlignmentCenter;

    CALayer *layer = label.layer;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 1);
    layer.shadowOpacity = 0.8;
    layer.shadowRadius = 1.0;
    layer.masksToBounds = NO;

    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kMRHeaderViewHeight;
}

- (NSString *)textForRowWithIndex:(NSInteger)index {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return ((UITextField *)[cell.contentView viewWithTag:kMRTagBase]).text;
}

- (void)didTouchButtonLogin:(UIButton *)sender {
    NSString *login = [self textForRowWithIndex:kMGRowLogin];
    NSString *password = [self textForRowWithIndex:kMGRowPassword];

    if (!login.length || !password.length) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", nil)
                                                            message:NSLocalizedString(@"Логин или пароль не заданы", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Закрыть", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    __weak MRLoginViewController *myself = self;
    [UIView animateWithDuration:0.3 animations:^{
        myself.tableView.alpha = 0.0;
    } completion:^(BOOL finished) {
        myself.activityView.hidden = NO;
        [myself.activityView startAnimating];
        [myself doLogin:login password:password];
    }];
}

- (void)doLogin:(NSString *)login password:(NSString *)password {
    [self cancelLoginOperation];
    MKNetworkEngine *engine = ApplicationDelegate.networkEngine;
    _operation = [engine operationWithPath:@"checklogin.php" params:@{
        @"myusername": login,
        @"mypassword": password
    } httpMethod:@"POST"];

    __weak MRLoginViewController *myself = self;
    [_operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSString *response = completedOperation.responseString;
        NSLog(@"Response is: %@", response);
        response = [response stringByReplacingOccurrencesOfString:@"</html>" withString:@""];
        NSDictionary *dictionary = [response objectFromJSONString];
        if ([dictionary[@"message"] isEqualToString:@"Successful"] && [dictionary[@"id"] length]) {
            if (myself.block) {
                myself.block(YES, dictionary);
            }
            return;
        }
        [myself restoreForm];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"An error was handled: %@", [error localizedDescription]);
        [myself restoreForm];
    }];

    NSLog(@"Operation is: %@", _operation);
    [engine enqueueOperation:_operation];
}

- (void)restoreForm {
    __weak MRLoginViewController *myself = self;
    self.activityView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        myself.tableView.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}
@end