#import "MRProjectCustomerViewController.h"
#import "MRCustomersDao.h"
#import "MRCustomerCell.h"
#import "MRCustomer.h"
#import "MREditCustomerViewController.h"
#import "MRProjectsDao.h"
#import "MRConstants.h"


@implementation MRProjectCustomerViewController {
    __weak IBOutlet UITableView *_tableView;
    __strong NSArray *_customers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [MRViewController barButtonItemWithTitle:NSLocalizedString(@"Новый", nil) style:MRBarButtonTypeCommon target:self action:@selector(didNewCustomerButtonTouch:)];

}

- (void)didNewCustomerButtonTouch:(id)sender {
    MREditCustomerViewController *editController = [self editController];
    [self.navigationController pushViewController:editController animated:YES];
}

- (MREditCustomerViewController *)editController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(MRCustomer.class) bundle:nil];
    MREditCustomerViewController *editController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(MREditCustomerViewController.class)];
    return editController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadCustomers];
}

- (void)reloadCustomers {
    _customers = [[MRCustomersDao sharedInstance] customers];
    [_tableView reloadData];

    if (self.project.customer) {
        MRCustomer *customer = [[MRCustomersDao sharedInstance] customerByProject:self.project];
        NSInteger index = [_customers indexOfObject:customer];
        if (index != NSNotFound) {
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _customers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRCustomerCell *cell = [MRCustomerCell cellForTableView:tableView];
    MRCustomer *customer = _customers[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    [cell updateFromVO:customer];
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    MREditCustomerViewController *editController = [self editController];
    editController.customer = _customers[indexPath.row];
    [self.navigationController pushViewController:editController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRCustomer *customer = _customers[indexPath.row];
    self.project.customer = customer;
    [[MRProjectsDao sharedInstance] updateProject:self.project];

    [[NSNotificationCenter defaultCenter] postNotificationName:kMRProjectSettingsWereChanged object:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MRCustomer *customer = _customers[indexPath.row];

        [MRCustomersDao.sharedInstance deleteCustomerWithDate:customer.creationDate];
        [self reloadCustomers];

        if (!_tableView.indexPathForSelectedRow) {
            self.project.customer = nil;
            [[MRProjectsDao sharedInstance] updateProject:self.project];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self reloadCustomers];
}

@end