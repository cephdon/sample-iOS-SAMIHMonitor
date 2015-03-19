//
//  UserSession.h
//  SAMIHMonitor
//
//  Copyright (c) 2014 SSIC. All rights reserved.
//

#import "SamiUser.h"

@interface UserSession : NSObject

+ (UserSession *) sharedInstance;

@property (nonatomic, weak) NSString *accessToken;
@property (nonatomic, weak) NSString *withingsDeviceTypeId;
@property (nonatomic, weak) NSString *calorieTrackerDeviceTypeId;
@property (readonly, nonatomic, strong) NSString *bearerToken;
@property (nonatomic, strong) SamiUser *user;

- (void) addAuthorizationHeader: (id) api;
- (void) logout;

@end
