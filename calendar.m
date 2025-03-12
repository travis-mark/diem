#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

// Original inspiration - https://terokarvinen.com/2021/calendar-txt/
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        void (^calendarAccessCompletionBlock)(BOOL, NSError *) = ^(BOOL granted, NSError *error) {
            if (!granted) {
                NSLog(@"Access to calendar was denied: %@", error);
                exit(1);
            }
            NSDate *startDate = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.day = 7; // One week
            NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
            NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
            NSArray *events = [eventStore eventsMatchingPredicate:predicate];
            if ([events count] > 0) {
                NSDateFormatter *eventDateFormatter = [[NSDateFormatter alloc] init];
                [eventDateFormatter setDateFormat:@"YYYY-MM-dd 'w'ww EEE"];
                NSDateFormatter *eventTimeFormatter = [[NSDateFormatter alloc] init];
                [eventTimeFormatter setDateFormat:@"HH:mm"];
                NSString *currentDate = nil;
                NSString *eventList = @"";
                for (EKEvent *event in events) {
                    NSString *eventDateString = [eventDateFormatter stringFromDate:event.startDate];
                    if (currentDate == nil) {
                        currentDate = eventDateString;
                    }
                    if (![currentDate isEqualToString: eventDateString]) {
                        printf("\x1b[0m %s -- %s\n", [currentDate UTF8String], [eventList UTF8String]);
                        currentDate = eventDateString;
                        eventList = @"";
                    }
                    if (event.isAllDay) {
                        eventList = [eventList stringByAppendingFormat: @"%@.  ", event.title];
                    } else {
                        NSString *eventStartTimeString = [eventTimeFormatter stringFromDate:event.startDate];
                        NSString *eventEndTimeString = [eventTimeFormatter stringFromDate:event.endDate];
                        eventList = [eventList stringByAppendingFormat: @"\x1b[32m%@-%@\x1b[0m %@.  ", eventStartTimeString, eventEndTimeString, event.title];
                    }
                    
                }
                printf("\x1b[0m %s -- %s\n", [currentDate UTF8String], [eventList UTF8String]);
            }
            exit(0);
        };
        if (@available(macOS 14.0, *)) {
            [eventStore requestFullAccessToEventsWithCompletion:calendarAccessCompletionBlock];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:calendarAccessCompletionBlock];
#pragma clang diagnostic pop
        }
        // Allow the asynchronous request to complete - block uses exit/1 to terminate
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
