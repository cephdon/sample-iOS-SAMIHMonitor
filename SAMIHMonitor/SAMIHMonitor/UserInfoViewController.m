//
//  UserInfoViewController.m
//
//  Copyright (c) 2014 SSIC. All rights reserved.
//

#import "SamiDevicesApi.h"
#import "SamiDeviceTypesApi.h"
#import "LoginViewController.h"
#import "SamiUsersApi.h"
#import "UserSession.h"
#import "UserInfoViewController.h"

@interface UserInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifiedLabel;

@end

@implementation UserInfoViewController {
    SamiDevice *withingsDevice_;
    SamiDevice *calorieTracker_;

    IBOutlet UIButton *weightButton_;
    IBOutlet UIButton *calorieButton_;
}

- (void) validateAccessToken {
    [self setWithingsDevice:nil];

    NSString* authorizationHeader = [UserSession sharedInstance].bearerToken;

    SamiUsersApi * usersApi = [[SamiUsersApi alloc] init];
    [usersApi addHeader:authorizationHeader forKey:kOAUTHAuthorizationHeader];
    
    [usersApi selfWithCompletionBlock:^(SamiUserEnvelope *output, NSError *error) {
        
        NSLog(@"%@", error);
        if (error) {
            self.fullnameLabel.text = error.localizedFailureReason;
        } else {
            UserSession *session = [UserSession sharedInstance];
            session.user = output.data;
            
            self.idLabel.text = output.data._id;
            self.nameLabel.text = output.data.name;
            self.fullnameLabel.text = output.data.fullName;
            self.emailLabel.text = output.data.email;
            
            NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMM dd, yyyy HH:mm"];
            
            NSDate *created = [NSDate dateWithTimeIntervalSince1970:([output.data.createdOn doubleValue])];
            self.createdLabel.text = [dateFormat stringFromDate:created];
            
            NSDate *modified = [NSDate dateWithTimeIntervalSince1970:([output.data.modifiedOn doubleValue])];
            self.modifiedLabel.text = [dateFormat stringFromDate:modified];
            
            [self resetDevices];
            [self processDevices];
        }        
    }];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showWithingsData"] && (withingsDevice_ == nil)) {
        return NO;
    }
    if([identifier isEqualToString:@"showCalorieData"] && (calorieTracker_ == nil)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Register"
                                                    message:@"You do not have a calorie tracker device yet. Do you want to register your phone as the device to track your calorie data?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAuth"]) {
        NSLog(@"showAuth");
        UserSession *session = [UserSession sharedInstance];
        [session logout];
    } else if ([segue.identifier isEqualToString:@"showWithingsData"]) {
        NSLog(@"showWithingsData");
        [segue.destinationViewController performSelector:@selector(setDevice:) withObject:withingsDevice_];
    } else if ([segue.identifier isEqualToString:@"showCalorieData"]) {
        NSLog(@"showCalorieData");
        [segue.destinationViewController performSelector:@selector(setDevice:) withObject:calorieTracker_];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UserSession *session = [UserSession sharedInstance];
    if (!session.user) {
        [self validateAccessToken];
    }
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UserSession *session = [UserSession sharedInstance];
    if (!session.accessToken) {
        [self performSegueWithIdentifier:@"showAuth" sender:self];
    }
    
    self.idLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.fullnameLabel.adjustsFontSizeToFitWidth = YES;
    self.emailLabel.adjustsFontSizeToFitWidth = YES;
}

#pragma mark - handle devices: Withings and CalorieTracker
- (void)processDevices {
    if (![UserSession sharedInstance].withingsDeviceTypeId) {
        [self getWithingsDeviceTypeId];
    } else if(![UserSession sharedInstance].calorieTrackerDeviceTypeId) {
        [self getCalorieTrackerDeviceTypeId];
    } else {
        [self getDeviceList];
    }
}

- (void)resetDevices {
    [self setWithingsDevice:nil];
    [self setCalorieTracker:nil];
}

- (void)getDeviceList {
    SamiUsersApi * api = [[SamiUsersApi alloc] init];
    NSString* authorizationHeader = [UserSession sharedInstance].bearerToken;
    [api addHeader:authorizationHeader forKey:kOAUTHAuthorizationHeader];
    
    [api getUserDevicesWithCompletionBlock:@(0) count:@(100) includeProperties:@(YES) userId:[UserSession sharedInstance].user._id completionHandler:^(SamiDevicesEnvelope *output, NSError *error) {
        NSLog(@"%@", output.data.devices);
        [self parseDeviceList:output.data.devices];
    }];
}

- (void)parseDeviceList:(NSArray *)devices {
    [self resetDevices];

    if (!devices) {
        NSLog(@"Own zero device");
        return;
    }

    NSString *deviceTypeId = [UserSession sharedInstance].withingsDeviceTypeId;
    if (deviceTypeId) {
        NSPredicate *predicateMatch = [NSPredicate predicateWithFormat:@"dtid == %@", deviceTypeId];
        NSArray *withingsDevice = [devices filteredArrayUsingPredicate:predicateMatch];
        if ([withingsDevice count] >0) {
            NSLog(@"Found %lu Withings devices", (unsigned long)[withingsDevice count]);
            //For simplicity, always use the first on if there are multiple such devices
            [self setWithingsDevice:((SamiDevice *)withingsDevice[0])];
        } else {
            NSLog(@"Found 0 Withings devices");
        }
    }
    
    deviceTypeId = [UserSession sharedInstance].calorieTrackerDeviceTypeId;
    if (deviceTypeId) {
        NSPredicate *predicateMatch = [NSPredicate predicateWithFormat:@"dtid == %@", deviceTypeId];
        NSArray *matchedDevices = [devices filteredArrayUsingPredicate:predicateMatch];
        if ([matchedDevices count] >0) {
            NSLog(@"Found %lu CalorieTracker devices", (unsigned long)[matchedDevices count]);
            //For simplicity, always use the first on if there are multiple such devices
            [self setCalorieTracker:((SamiDevice *)matchedDevices[0])];
        } else {
            NSLog(@"Found 0 CalorieTracker devices");
        }
    }
}

#pragma mark - handle Withings device

- (void)getWithingsDeviceTypeId {
    SamiDeviceTypesApi *api = [[SamiDeviceTypesApi alloc] init];
    NSString* authorizationHeader = [UserSession sharedInstance].bearerToken;
    [api addHeader:authorizationHeader forKey:kOAUTHAuthorizationHeader];
    [api getDeviceTypesWithCompletionBlock:kDeviceTypeNameWithings offset:@(0) count:@(1) completionHandler:^(SamiDeviceTypesEnvelope *output, NSError *error) {
        [UserSession sharedInstance].withingsDeviceTypeId = ((SamiDeviceType *)[output.data.deviceTypes objectAtIndex:0])._id;
        NSLog(@"Store Withings Device Type %@", [UserSession sharedInstance].withingsDeviceTypeId);
        [self processDevices];
    }];
}

- (void)setWithingsDevice:(SamiDevice *)device {
    if (device != nil) {
        withingsDevice_ = device;
        weightButton_.enabled = YES;
    } else {
        withingsDevice_ = nil;
        weightButton_.enabled = NO;
    }
}

#pragma mark - handle calories

- (void)setCalorieTracker:(SamiDevice *)device {
    if (device != nil) {
        calorieTracker_ = device;
    } else {
        calorieTracker_ = nil;
    }
}

- (void)getCalorieTrackerDeviceTypeId {
    SamiDeviceTypesApi *api = [[SamiDeviceTypesApi alloc] init];
    NSString* authorizationHeader = [UserSession sharedInstance].bearerToken;
    [api addHeader:authorizationHeader forKey:kOAUTHAuthorizationHeader];
    [api getDeviceTypesWithCompletionBlock:kDeviceTypeNameCalorieTracker offset:@(0) count:@(1) completionHandler:^(SamiDeviceTypesEnvelope *output, NSError *error) {
        NSLog(@"output.data:%@, error:%@", output.data, error);
        if (error) {
            NSLog(@"Failed to get calorie tracker device type. Error:%@", error);
            return;
        }
        [UserSession sharedInstance].CalorieTrackerDeviceTypeId = ((SamiDeviceType *)[output.data.deviceTypes objectAtIndex:0])._id;
        NSLog(@"Store CalorieTracker Device Type %@", [UserSession sharedInstance].calorieTrackerDeviceTypeId);
        [self processDevices];
    }];
}

- (void)registerPhoneAsCalorieTracker {
    UserSession *session = [UserSession sharedInstance];
    NSString* authorizationHeader = session.bearerToken;
    
    SamiDevicesApi * api = [[SamiDevicesApi alloc] init];
    [api addHeader:authorizationHeader forKey:kOAUTHAuthorizationHeader];
    
    SamiDevice* deviceToRegister = [[SamiDevice alloc] init];
    deviceToRegister.name = kDeviceNameCalorieTracker;
    deviceToRegister.uid = session.user._id;
    deviceToRegister.dtid = session.calorieTrackerDeviceTypeId;
    
    [api addDeviceWithCompletionBlock:deviceToRegister completionHandler:^(SamiDeviceEnvelope *output, NSError *error) {
        if (!error) {
            calorieTracker_ = (SamiDevice*)output.data;
            NSLog(@"Registed Calorie Track with device id %@", calorieTracker_._id);
        } else {
            NSLog(@"Adding device failed with error %@", error);
        }
    }];
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"The %@ button was tapped.", [alertView buttonTitleAtIndex:buttonIndex]);
    
    if (buttonIndex == 1) {
        NSLog(@"Registering the phone as calorieTracker device");
        [self registerPhoneAsCalorieTracker];
        return;
    }
}

@end
