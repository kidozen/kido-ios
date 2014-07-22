#import "NSData+Conversion.h"

@implementation NSData (Conversion)
#pragma mark - String Conversion
- (NSString *)hexadecimalString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02x", (unsigned int)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

- (NSString *)KZ_UTF8String
{
    NSError *errorResponse;
    NSString *typedResponse = [NSJSONSerialization JSONObjectWithData:self options:0 error:&errorResponse];
    
    if (typedResponse == nil) {
        typedResponse = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
        if (typedResponse == nil) {
            typedResponse = [NSString stringWithUTF8String:[self bytes]];
        }
    }
    
    return typedResponse;

}

@end
