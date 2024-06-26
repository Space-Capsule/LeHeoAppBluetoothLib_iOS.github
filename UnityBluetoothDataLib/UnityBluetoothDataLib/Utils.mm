//
//  Utils.m
//  UnityBluetoothDataLib
//
//  Created by EthanLin on 2024/3/13.
//

#import "Utils.h"

static char base64EncodingTable[64] =
{
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};


@implementation Utils

/**
 取得id
 */
+ (NSString *)getBodyId:(NSData *)aData
{
    if ([[[self byteArrayToHexString:aData] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"E"])
    {
        if ([[[self byteArrayToHexString:aData] substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"A"])
        {
            return @"10";
        }
        else
        {
            return [[self byteArrayToHexString:aData] substringWithRange:NSMakeRange(1, 1)];
        }
    }
    else
    {
        return @"0";
    }
}


/* byte array to hex-string */
+ (NSString *)byteArrayToHexString:(NSData *)aData
{
    if (aData != nil && aData.length > 0)
    {
        NSMutableString *str = [NSMutableString stringWithCapacity:64];
        int length = (int)[aData length];
        char *bytes = (char *)malloc(sizeof(char) * length);

        [aData getBytes:bytes length:length];

        for (int i = 0; i < length; i++)
        {
            [str appendFormat:@"%02.2hhX", bytes[i]];
        }
        free(bytes);

        return str;
    }
    else
    {
        return @"";
    }
}


+ (float)hexString2float:(NSString *)aDataString
{
    float tempValue;
    const char *_char = [aDataString UTF8String];
    long l = strtol(_char, NULL, 16);
    tempValue = *((float *) &l);
    return tempValue;
}

+ (NSString *)byteArrayToBase64:(NSData *)aData length: (int)aLength
{
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [aData length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = (const unsigned char *)[aData bytes];
    ixtext = 0;
    
    while (true)
    {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining)
        {
            case 1:
                ctcopy = 2;
                break;
                
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((aLength > 0) && (charsonline >= aLength))
            charsonline = 0;
    }
    return result;
}

@end
