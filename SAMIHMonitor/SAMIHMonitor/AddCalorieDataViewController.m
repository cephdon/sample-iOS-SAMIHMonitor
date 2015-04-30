//
//  SamiAddMessageViewController.m
//  SAMIClient
//
//  Created by Maneesh Sahu-SSI on 9/23/14.
//  Copyright (c) 2014 SSIC. All rights reserved.
//

#import "AddCalorieDataViewController.h"
#import "UserSession.h"
#import "SamiMessagesApi.h"

@interface AddCalorieDataViewController()
@property (weak, nonatomic) IBOutlet UITextField *caloriesField;
@property (weak, nonatomic) IBOutlet UITextField *commentsField;
@property (weak, nonatomic) IBOutlet UITextField *dateMMField;
@property (weak, nonatomic) IBOutlet UITextField *dateDDField;
@property (weak, nonatomic) IBOutlet UITextField *dateYYYYField;

@end

@implementation AddCalorieDataViewController
{
    SamiDevice *device_;
}

- (void)setDevice:(SamiDevice *)device
{
    device_ = device;
}

- (IBAction)addMessage:(id)sender {
    NSString* authorizationHeader = [UserSession sharedInstance].bearerToken;
    
    SamiMessagesApi * api2 = [SamiMessagesApi apiWithHeader:authorizationHeader key:kOAUTHAuthorizationHeader];
    
    SamiMessage *message = [[SamiMessage alloc] init];
    message.sdid = device_._id;
    message.data = @{ @"calories": @([self.caloriesField.text integerValue]),
                      @"comments": self.commentsField.text};
    BOOL succeed = [self setMessageTimestamp:message];
    if (!succeed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You entered an incorrect date. Please correct it."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [api2 postMessageWithCompletionBlock:message completionHandler:^(SamiMessageIDEnvelope *output, NSError *error) {
        NSLog(@"[api postMessageWithCompletionBlock] output: %@ \n error: %@", output, error);
        if (!error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:[@"Message added " stringByAppendingString:output.data.mid]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            NSLog(@"%@", error);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (BOOL)setMessageTimestamp:(SamiMessage *)msg {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    NSString* inputString = [NSString stringWithFormat:@"%04ld%02ld%02ld",
                             (long)[self.dateYYYYField.text integerValue],
                             (long)[self.dateMMField.text integerValue],
                             (long)[self.dateDDField.text integerValue]];
    NSDate *date = [dateFormatter dateFromString:inputString];
    if (!date) {
        return NO;//invalid date
    }
    
    msg.ts = [NSNumber numberWithDouble:date.timeIntervalSince1970*1000];// millisecond
    return YES;
}

@end
