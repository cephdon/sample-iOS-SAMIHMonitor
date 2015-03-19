//
//  DataTableViewController.h
//  SAMIHMonitor
//
//  Copyright (c) 2015 SSIC. All rights reserved.
//

#import "SamiNormalizedMessage.h"
#import "SamiDevice.h"

@interface DataTableViewController : UITableViewController
- (void)setDevice:(SamiDevice *)device;
@end
