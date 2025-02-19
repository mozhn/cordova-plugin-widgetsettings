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
        NSString *startDateString = [options objectForKey:@"fastingStartDate"];
        NSString *endDateString = [options objectForKey:@"fastingEndDate"];
        
        // ISO8601 formatı: "yyyy-MM-dd'T'HH:mm:ssZ"
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        
        NSDate *startDate = [formatter dateFromString:startDateString];
        NSDate *endDate = [formatter dateFromString:endDateString];
        
        if (startDate && endDate) {
            [defaults setObject:startDate forKey:@"fastingStartDate"];
            [defaults setObject:endDate forKey:@"fastingEndDate"];
        } else {
            NSLog(@"[WidgetSettings] Hata: Tarih formatı hatalı veya eksik.");
        }
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
    else if ([type isEqualToString:@"water"]) {
        NSNumber *waterConsumed = [options objectForKey:@"waterConsumed"];
        NSNumber *totalWaterGoal = [options objectForKey:@"totalWaterGoal"];
        NSNumber *waterIncrement = [options objectForKey:@"waterIncrement"];
        
        [defaults setObject:waterConsumed forKey:@"waterConsumed"];
        [defaults setObject:totalWaterGoal forKey:@"totalWaterGoal"];
        [defaults setObject:waterIncrement forKey:@"waterIncrement"];
    }
    else if ([type isEqualToString:@"ai"]) {
        NSString *text = [options objectForKey:@"text"];
        if (text) {
            [defaults setObject:text forKey:@"aiText"];
        } else {
            NSLog(@"[WidgetSettings] Error.");
        }
    }
    else if ([type isEqualToString:@"period"]) {
        NSNumber *daysUntilEvent = [options objectForKey:@"daysUntilEvent"];
        NSString *eventType = [options objectForKey:@"eventType"];
        
        if (daysUntilEvent && eventType) {
            [defaults setObject:daysUntilEvent forKey:@"periodDaysUntilEvent"];
            [defaults setObject:eventType forKey:@"periodEventType"];
        } else {
            NSLog(@"[WidgetSettings] Hata: Periyot verisi eksik veya hatalı.");
        }
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
        NSDate *startDate = [defaults objectForKey:@"fastingStartDate"];
        NSDate *endDate = [defaults objectForKey:@"fastingEndDate"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        
        NSString *startDateString = startDate ? [formatter stringFromDate:startDate] : @"";
        NSString *endDateString = endDate ? [formatter stringFromDate:endDate] : @"";
        
        value = @{
            @"fastingStartDate": startDateString,
            @"fastingEndDate": endDateString
        };
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
    else if ([type isEqualToString:@"water"]) {
        NSNumber *waterConsumed = [defaults objectForKey:@"waterConsumed"];
        NSNumber *totalWaterGoal = [defaults objectForKey:@"totalWaterGoal"];
        NSNumber *waterIncrement = [defaults objectForKey:@"waterIncrement"];
        
        value = @{
            @"waterConsumed": waterConsumed ? waterConsumed : @0,
            @"totalWaterGoal": totalWaterGoal ? totalWaterGoal : @0,
            @"waterIncrement": waterIncrement ? waterIncrement : @0
        };
    }
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                               messageAsDictionary:@{@"value": value ? value : [NSNull null]}];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
