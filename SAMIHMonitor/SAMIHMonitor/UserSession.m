//
//  UserSession.m
//  SAMIHMonitor
//
//  Copyright (c) 2014 SSIC. All rights reserved.
//

#import "UserSession.h"

@interface UserSession()
@end

@implementation UserSession

NSString *const kWithingsDeviceTypeIdKey = @"WithingsDeviceTypeIdKey";
NSString *const kCalorieTrackerDeviceTypeIdKey = @"CalorieTrackerDeviceTypeIdKey";

static UserSession *sharedInstance = nil;

+ (UserSession *) sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id) init {
    self = [super init];
    return self;
}

- (void)setAccessToken:(NSString *)accessToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:kAccessToken];
    [defaults synchronize];
}

- (NSString *)accessToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kAccessToken];
}

- (void)setWithingsDeviceTypeId:(NSString *)dtid {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dtid forKey:kWithingsDeviceTypeIdKey];
    [defaults synchronize];
}

- (NSString *)withingsDeviceTypeId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kWithingsDeviceTypeIdKey];
}

- (void)setCalorieTrackerDeviceTypeId:(NSString *)dtid {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dtid forKey:kCalorieTrackerDeviceTypeIdKey];
    [defaults synchronize];
}

- (NSString *)calorieTrackerDeviceTypeId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kCalorieTrackerDeviceTypeIdKey];
}

- (NSString *)bearerToken {
    return [NSString stringWithFormat:kOAUTHBearerTokenFormat, self.accessToken ];
}

- (void)addAuthorizationHeader:(id)api {
    SEL addHeaderSelector = sel_registerName("addHeader:forKey:");
 
    if ([api respondsToSelector:addHeaderSelector]) {
        [api performSelector:addHeaderSelector withObject:self.bearerToken withObject:kOAUTHAuthorizationHeader];
    }
}

- (void)logout {
    // Explicitly logout
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kAccessToken];
    [defaults synchronize];
    
    self.user = nil;
}

@end
