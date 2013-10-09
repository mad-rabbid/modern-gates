#import "MRProjectCalculationsViewController.h"
#import "MRProject.h"
#import "MRCalculationCell.h"
#import "MRCalculation.h"
#import "MRCalculationsDao.h"
#import "MRProjectNewCalculationViewController.h"
#import "MRCalculationHelper.h"
#import "MRJSONHelper.h"
#import "MRPriceHelper.h"
#import "MRProjectCalculationDetailsViewController.h"
#import "MRProjectsDao.h"
#import "MRConstants.h"


@implementation MRProjectCalculationsViewController {
    __weak IBOutlet UITableView *_tableView;
    __strong NSArray *_calculations;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDecimalNumber *payedAmount = self.project.payedAmount;
    NSString *factoryId = self.project.factoryId;

//    if (([payedAmount compare:NSDecimalNumber.zero] == NSOrderedSame) &&
//            !factoryId.length) {
        self.navigationItem.leftBarButtonItem = [MRViewController barButtonItemWithTitle:NSLocalizedString(@"Новый", nil) style:MRBarButtonTypeCommon target:self action:@selector(didTouchNewCalculationButton:)];
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self update];
    [_tableView reloadData];
}

- (void)update {
    _calculations = [[MRCalculationsDao sharedInstance] calculationsForProject:self.project];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _calculations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRCalculationCell *cell = [MRCalculationCell cellForTableView:tableView];
    MRCalculation *calculation = _calculations[indexPath.row];
    [cell updateFromVO:calculation];

    cell.accessoryType = (cell.selectionStyle == UITableViewCellSelectionStyleBlue) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MRCalculation *calculation = _calculations[indexPath.row];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MRCalculations" bundle:nil];
    MRProjectCalculationDetailsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(MRProjectCalculationDetailsViewController.class)];
    controller.calculation = calculation;
    controller.project = self.project;
    controller.title = NSLocalizedString(@"Детализация расчета", nil);
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MRCalculation *calculation = _calculations[indexPath.row];
        [[MRCalculationsDao sharedInstance] deleteCalculationWithDate:calculation.date];
        [self update];
        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMRProjectSettingsWereChanged object:nil];
    }
}

- (void)handleCalculationResult:(BOOL)isSuccess result:(NSDictionary *)result {
    if (_messagesBlock) {
        _messagesBlock(result[@"messages"]);
    }

    if (!isSuccess || !result) {
        return;
    }

    NSDate *priceDate = [MRPriceHelper priceDateForEngineWithName:self.project.type];

    MRCalculation *calculation = [MRCalculationsDao.sharedInstance createCalculationForProject:self.project];
    calculation.priceDate = priceDate;
    NSDictionary *calculationDictionary = [MRCalculationHelper prepareCalculationResultDataWithForm:self.form calculationResult:result[@"prices"] priceDate:priceDate];
    calculation.data = [MRJSONHelper jsonDataFromObject:calculationDictionary];
    [[MRCalculationsDao sharedInstance] updateCalculation:calculation];

    NSString *orderId = result[@"order"];
    if (orderId.length) {
        self.project.factoryId = orderId;
        self.project.factoryDate = [NSDate new];
        self.project.factoryStatus = NSLocalizedString(@"Заявка принята", nil);

        [[MRProjectsDao sharedInstance] updateProject:self.project];
    }

    [self update];
    [_tableView reloadData];

    [[NSNotificationCenter defaultCenter] postNotificationName:kMRProjectSettingsWereChanged object:nil];
}

- (void)didTouchNewCalculationButton:(UIButton *)button {
    MRProjectNewCalculationViewController *controller = [MRProjectNewCalculationViewController new];
    controller.projectType = self.project.type;
    controller.form = self.form;
    controller.title = NSLocalizedString(@"Статус расчета", nil);

    __block MRProjectCalculationsViewController *myself = self;
    controller.block = ^(BOOL isSuccess, NSDictionary *result) {
        [myself handleCalculationResult:isSuccess result:result];
        myself = nil;
    };
    [self.navigationController pushViewController:controller animated:YES];
}

@end