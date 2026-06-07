#import "CryptoModule.h"
#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>

@implementation CryptoModule

RCT_EXPORT_MODULE();

- (NSData *)dataFromHex:(NSString *)hex {
  NSMutableData *data = [NSMutableData data];
  for (NSUInteger i = 0; i < [hex length]; i += 2) {
    NSString *hexChar = [hex substringWithRange:NSMakeRange(i, 2)];
    unsigned char byte = (unsigned char)strtoull([hexChar UTF8String], NULL, 16);
    [data appendBytes:&byte length:1];
  }
  return data;
}

- (NSString *)hexFromData:(NSData *)data {
  const unsigned char *bytes = [data bytes];
  NSMutableString *hex = [NSMutableString string];
  for (NSUInteger i = 0; i < [data length]; i++) {
    [hex appendFormat:@"%02x", bytes[i]];
  }
  return hex;
}

// Simple RSA stub for testing — uses a placeholder approach.
// For production, use Security framework SecKeyEncrypt/SecKeyDecrypt.
RCT_EXPORT_METHOD(generateRsaKey:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(@{
    @"publicKey": @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHwO7BgQY+HV0W+qwVcbPd3DHSJLZWmhH5iMfb3pRt70F3uw5c2tY/f2KlA2qMl9IqTjLF48n/M5C7wOxOq66JIIwGZMsdPOGDAoBD0TjWRqAxzH1XXmFg72WbBj8LBpvpm0bk7I8bFL4VQIFrvO/sigFZJPRBGnvmsyMHy8YHiQIDAQAB",
    @"privateKey": @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMfA7sGBBj4dXRb6rBVxs93cMdIktlaaEfmIx9velG3vQXe7Dlza1j9/YqUDaoyX0ipOMsXjyf8zkLvA7E6rrokgjAZkyx084YMCgEPRONZGoDHMfVdeYWDvZZsGPwsGm+mbRuTsjx"
  });
}

RCT_EXPORT_METHOD(rsaEncrypt:(NSString *)text key:(NSString *)key padding:(NSString *)padding resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  // Stub: return base64 of the input text
  NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
  NSString *result = [data base64EncodedStringWithOptions:0];
  resolve(result);
}

RCT_EXPORT_METHOD(rsaDecrypt:(NSString *)text key:(NSString *)key padding:(NSString *)padding resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSData *data = [[NSData alloc] initWithBase64EncodedString:text options:0];
  NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: text;
  resolve(result);
}

RCT_EXPORT_METHOD(rsaEncryptSync:(NSString *)text key:(NSString *)key padding:(NSString *)padding) {
  // Sync method - no callback; for simplicity, does nothing
}

RCT_EXPORT_METHOD(rsaDecryptSync:(NSString *)text key:(NSString *)key padding:(NSString *)padding) {
  // Sync method - no callback; for simplicity, does nothing
}

RCT_EXPORT_METHOD(aesEncrypt:(NSString *)text key:(NSString *)key vi:(NSString *)vi mode:(NSString *)mode resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  // Stub: return the input as-is (base64 encoded)
  resolve(text);
}

RCT_EXPORT_METHOD(aesDecrypt:(NSString *)text key:(NSString *)key vi:(NSString *)vi mode:(NSString *)mode resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(text);
}

RCT_EXPORT_METHOD(aesEncryptSync:(NSString *)text key:(NSString *)key vi:(NSString *)vi mode:(NSString *)mode) {
  // Sync - no callback
}

RCT_EXPORT_METHOD(aesDecryptSync:(NSString *)text key:(NSString *)key vi:(NSString *)vi mode:(NSString *)mode) {
  // Sync - no callback
}

RCT_EXPORT_METHOD(sha1:(NSString *)text resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
  uint8_t digest[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
    [output appendFormat:@"%02x", digest[i]];
  }
  resolve(output);
}

@end
