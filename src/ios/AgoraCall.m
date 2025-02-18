#import <Cordova/CDV.h>

@interface WidgetSettings : CDVPlugin

- (void)saveData:(CDVInvokedUrlCommand*)command;
- (void)getData:(CDVInvokedUrlCommand*)command;

@end

@implementation WidgetSettings

- (void)saveData:(CDVInvokedUrlCommand*)command {
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *type = [options objectForKey:@"type"];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.askipo.patient"];
    
    if ([type isEqualToString:@"fasting"]) {
        NSNumber *value = [options objectForKey:@"value"];
        [defaults setObject:value forKey:@"fastingTime"];
    }
    else if ([type isEqualToString:@"calories"]) {
        NSNumber *remainingCalories = [options objectForKey:@"remainingCalories"];
        NSNumber *calorieGoal = [options objectForKey:@"calorieGoal"];
        NSNumber *caloriesTaken = [options objectForKey:@"caloriesTaken"];
        NSNumber *caloriesBurned = [options objectForKey:@"caloriesBurned"];
        
        [defaults setObject:remainingCalories forKey:@"remainingCalories"];
        [defaults setObject:calorieGoal forKey:@"calorieGoal"];
        [defaults setObject:caloriesTaken forKey:@"caloriesTaken"];
        [defaults setObject:caloriesBurned forKey:@"caloriesBurned"];
    }
    
    [defaults synchronize];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getData:(CDVInvokedUrlCommand*)command {
    NSDictionary *options = [command.arguments objectAtIndex:0];
    NSString *type = [options objectForKey:@"type"];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.askipo.patient"];
    id value = nil;
    
    if ([type isEqualToString:@"fasting"]) {
        value = [defaults objectForKey:@"fastingTime"];
    }
    else if ([type isEqualToString:@"calories"]) {
        NSNumber *remainingCalories = [defaults objectForKey:@"remainingCalories"];
        NSNumber *calorieGoal = [defaults objectForKey:@"calorieGoal"];
        NSNumber *caloriesTaken = [defaults objectForKey:@"caloriesTaken"];
        NSNumber *caloriesBurned = [defaults objectForKey:@"caloriesBurned"];
        
        value = @{
            @"remainingCalories": remainingCalories ? remainingCalories : @0,
            @"calorieGoal": calorieGoal ? calorieGoal : @0,
            @"caloriesTaken": caloriesTaken ? caloriesTaken : @0,
            @"caloriesBurned": caloriesBurned ? caloriesBurned : @0
        };
    }
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                               messageAsDictionary:@{@"value": value ? value : [NSNull null]}];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
