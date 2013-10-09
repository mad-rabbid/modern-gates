#import <Foundation/Foundation.h>
#import "MRPopupViewController.h"
#import "MRProjectPopupViewController.h"

typedef void (^MRProjectCalculationsMessagesBlock)(NSDictionary *);
@interface MRProjectCalculationsViewController : MRProjectPopupViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) MRProjectCalculationsMessagesBlock messagesBlock;

@end