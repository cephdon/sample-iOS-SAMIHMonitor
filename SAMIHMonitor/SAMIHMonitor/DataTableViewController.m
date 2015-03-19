//
//  DataTableViewController.m
//  SAMIHMonitor
//
//  Copyright (c) 2015 SSIC. All rights reserved.
//

#import "DataTableViewController.h"
#import "SamiMessagesApi.h"
#import "UserSession.h"
#import "SamiDeviceTypesApi.h"

NSString *const kWeightKey = @"weight";
NSString *const kCaloriesKey = @"calories";

@interface DataTableViewController ()
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSArray * messages;
@end

@implementation DataTableViewController
{
    SamiNormalizedMessage *normalizedMessage_;
    SamiDevice *device_;
    NSString *unit_;
    IBOutlet UIButton *addDataButton_;
}

- (void)setDevice:(SamiDevice *)device
{
    device_ = device;
    NSLog(@"Set Device with sid %@", device_._id);
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![device_.dtid isEqualToString:[[UserSession sharedInstance] calorieTrackerDeviceTypeId]]) {
        addDataButton_.hidden = YES;
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshMessages) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self parseManifestSetUnit];
    [self refreshMessages];
}

- (void)refreshMessages {
    NSString *authorizationHeader = [UserSession sharedInstance].bearerToken;
    int messageCount = 20;

    SamiMessagesApi * api2 = [SamiMessagesApi apiWithHeader:authorizationHeader key:kOAUTHAuthorizationHeader];
    [api2 getLastNormalizedMessagesWithCompletionBlock:@(messageCount) sdids:device_._id fieldPresence:nil completionHandler:^(SamiNormalizedMessagesEnvelope *output, NSError *error) {
        if (error) {
            NSLog(@"getLastNormalizedMessagesWithCompletionBlock ran into error: %@", error);
            return;
        }
        self.messages = output.data;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addCalorieData"]) {
        NSLog(@"addCalorieData");
        [segue.destinationViewController performSelector:@selector(setDevice:) withObject:device_];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCell"];
    }
    SamiNormalizedMessage *message = (SamiNormalizedMessage *)[self.messages objectAtIndex:indexPath.row];
    [self configCellDisp:cell withMsg:message];
    
    return cell;
}

#pragma mark - Misc

- (void)parseManifestSetUnit {
    NSString* authorizationHeader = [UserSession sharedInstance].bearerToken;
    
    SamiDeviceTypesApi * api = [[SamiDeviceTypesApi alloc] init];
    [api addHeader:authorizationHeader forKey:kOAUTHAuthorizationHeader];
    
    [api getLatestManifestPropertiesWithCompletionBlock:device_.dtid completionHandler:^(SamiManifestPropertiesEnvelope *output, NSError *error) {
        NSLog(@"output: %@, error: %@", output, error);
        
        unit_ = @"";//reset unit
        if (error) {
            return;
        }
    
        NSDictionary *dict = [output.data.properties objectForKey:@"fields"];
        NSString *key = [self getDataKey];
        if (key) {
            NSDictionary *fieldInfo = [dict objectForKey:key];
            unit_ = [fieldInfo objectForKey:@"unit"];
        }
        self.navigationItem.title = [self getTitle:key];
    }];
}

- (void)configCellDisp:(UITableViewCell*)cell withMsg:(SamiNormalizedMessage*)message {
    if (!message) {
        return;
    }
    NSDictionary *dict = message.data;
    NSString *key = [self getDataKey];
    if (key) {
        id value = [dict objectForKey:key];
        cell.textLabel.text = [value description];
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:([message.ts doubleValue]/1000)];
    cell.detailTextLabel.text = [[self getDateFormatter] stringFromDate:date];
}

- (NSString *)getDataKey {
    NSString *keyStr;

    if ([device_.dtid isEqualToString:[UserSession sharedInstance].withingsDeviceTypeId]) {
        keyStr = kWeightKey;
    } else if ([device_.dtid isEqualToString:[UserSession sharedInstance].calorieTrackerDeviceTypeId]) {
        keyStr = kCaloriesKey;
    }

    return keyStr;
}

- (NSDateFormatter *)getDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([device_.dtid isEqualToString:[UserSession sharedInstance].calorieTrackerDeviceTypeId]) {
        [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    } else {
        [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm"];
    }
    return dateFormatter;
}

- (NSString *)getTitle:(NSString*)dataKey {
    NSString *title = dataKey;
    
    if ([dataKey isEqualToString:kCaloriesKey]) {
        // This is a workaround for calorie, which unit is "J*4.184"
        // Do not show this unit.
        return title;
    }

    title = [title stringByAppendingString:@" in "];
    title = [title stringByAppendingString:unit_];
    return title;
}

@end
