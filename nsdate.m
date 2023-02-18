#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = @"";
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    for (int i = 1; i < argc; i++) {
        if ([dateFormat length] != 0) {
            dateFormat = [dateFormat stringByAppendingString:@" "];
        }
        dateFormat = [dateFormat stringByAppendingString:@(argv[i])];
    } 
    if ([dateFormat length] != 0) {
        dateFormatter.dateFormat = dateFormat;
    }
    NSDate *date = [NSDate date];
    printf("%s\n", [[dateFormatter stringFromDate:date] UTF8String]);
    [pool drain];
    return 0;
}