#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateFormat:@"D"];
   NSDate *date = [NSDate date];
   printf("Day %s\n", [[dateFormatter stringFromDate:date] UTF8String]);
   [pool drain];
   return 0;
}