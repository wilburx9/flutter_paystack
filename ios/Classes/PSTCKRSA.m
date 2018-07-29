//
//  PSTCKRSA.m
//  Paystack
//
//  Created by Ibrahim Lawal on Feb/27/2016.
//  Copyright © 2016 Paystack, Inc. All rights reserved.
//

#import "PSTCKRSA.h"

extern OSStatus SecKeyEncrypt(
                              SecKeyRef           key,
                              SecPadding          padding,
                              const uint8_t        *plainText,
                              size_t              plainTextLen,
                              uint8_t             *cipherText,
                              size_t              *cipherTextLen)
__OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_2_0) __attribute__((weak_import));

@implementation PSTCKRSA

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key
{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx    = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}


+(NSString *)publicEncryptionKey{
    return @"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANIsL+RHqfkBiKGn/D1y1QnNrMkKzxWP"
    "2wkeSokw2OJrCI+d6YGJPrHHx+nmb/Qn885/R01Gw6d7M824qofmCvkCAwEAAQ==";
}

+(NSData *)decodedPublicEncryptionKey{
    NSString *s_key = [self publicEncryptionKey];
    
    // This will be base64 encoded, decode it.
    NSData *d_key = [[NSData alloc] initWithBase64EncodedString:s_key options:0];
    
    return [self stripPublicKeyHeader:d_key];
}

+(void)throwNotEntitledException{
    NSException *ex = [NSException exceptionWithName:@"Not entitled to Keychain Sharing" reason:NSLocalizedString(@"To use the Paystack SDK, you must add Keychain Sharing entitlements to your app", @"To use the Paystack SDK, you must add Keychain Sharing entitlements to your app") userInfo:nil];
    [ex raise];
}


+(NSString *)encryptRSA:(NSString *)plainTextString  {
    NSData *d_key = [self decodedPublicEncryptionKey];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(id) kSecClassKey forKey:(id)kSecClass];
    [publicKey setObject:(id) kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    //    [publicKey setObject:d_tag forKey:(id)kSecAttrApplicationTag];
    SecItemDelete((CFDictionaryRef)publicKey);
    
    CFTypeRef persistKey = nil;
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:d_key forKey:(id)kSecValueData];
    [publicKey setObject:(id) kSecAttrKeyClassPublic forKey:(id)
     kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)
     kSecReturnPersistentRef];
    
    OSStatus secStatus = SecItemAdd((CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil) CFRelease(persistKey);
    
    if (secStatus != noErr) {
        //        NSLog(@"THTHTHTH: %d", (int)secStatus);
        if(secStatus == -34018) {
            //            NSLog(@"THTHTHTH: Not entitled");
            [self throwNotEntitledException];
        }
        if(secStatus == errSecDuplicateItem) {
            // we don't mind if there was a duplication
            return(FALSE);
        }
    }
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    
    [publicKey removeObjectForKey:(id)kSecValueData];
    [publicKey removeObjectForKey:(id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef
     ];
    [publicKey setObject:(id) kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    secStatus = SecItemCopyMatching((CFDictionaryRef)publicKey,
                                    (CFTypeRef *)&keyRef);
    
    if (secStatus != noErr) {
        //        NSLog(@"THTHTHTH: %d", (int)secStatus);
        if(secStatus == -34018) {
            //            NSLog(@"THTHTHTH: Not entitled");
            [self throwNotEntitledException];
        }
        if(secStatus == errSecDuplicateItem) {
            // we don't mind if there was a duplication
            return(FALSE);
        }
    }
    // Fetch the SecKeyRef version of our public key
    // SecKeyRef keyRef = [self fetchKeyRef:publicKey andAddIfNotFound:true];
    
    if (keyRef == nil){
        //        NSLog(@"THTHTHTH: No key");
        return nil;
    }
    
    // Add to our pseudo keychain
    //    [keyRefs addObject:[NSValue valueWithBytes:&keyRef objCType:@encode(
    //                                                                        SecKeyRef)]];
    //
    
    size_t cipherBufferSize = SecKeyGetBlockSize(keyRef);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    uint8_t *nonce = (uint8_t *)[plainTextString UTF8String];
    
    SecKeyEncrypt(keyRef,
                  kSecPaddingPKCS1,
                  nonce,
                  strlen( (char*)nonce ),
                  &cipherBuffer[0],
                  &cipherBufferSize);
    //    NSLog(@"THTHTHTH: After s_k_e_");
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    //    NSLog(@"THTHTHTH: %@", [encryptedData base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0]);
    
    return [encryptedData base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
}

@end
