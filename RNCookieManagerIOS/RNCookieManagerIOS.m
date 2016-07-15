#import "RNCookieManagerIOS.h"
#import "RCTConvert.h"

#define kCookieArchive @"RNCookieManagerIOS"

@implementation RNCookieManagerIOS

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(set:(NSDictionary *)props callback:(RCTResponseSenderBlock)callback) {
    NSString *name = [RCTConvert NSString:props[@"name"]];
    NSString *value = [RCTConvert NSString:props[@"value"]];
    NSString *domain = [RCTConvert NSString:props[@"domain"]];
    NSString *origin = [RCTConvert NSString:props[@"origin"]];
    NSString *path = [RCTConvert NSString:props[@"path"]];
    NSString *version = [RCTConvert NSString:props[@"version"]];
    NSDate *expiration = [RCTConvert NSDate:props[@"expiration"]];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:origin forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:path forKey:NSHTTPCookiePath];
    [cookieProperties setObject:version forKey:NSHTTPCookieVersion];
    [cookieProperties setObject:expiration forKey:NSHTTPCookieExpires];

    NSLog(@"SETTING COOKIE");
    NSLog(@"%@", cookieProperties);

    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];

    callback(@[[NSNull null]]);
}

RCT_EXPORT_METHOD(setFromResponse:(NSURL *)url value:(NSDictionary *)value callback:(RCTResponseSenderBlock)callback) {
  NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:value forURL:url];
  [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:NULL];
    callback(@[[NSNull null]]);
}


RCT_EXPORT_METHOD(get:(NSURL *)url callback:(RCTResponseSenderBlock)callback) {
    NSMutableDictionary *cookies = [NSMutableDictionary dictionary];
    for (NSHTTPCookie *c in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url]) {
        [cookies setObject:c.value forKey:c.name];
    }
    callback(@[[NSNull null], cookies]);
}

RCT_EXPORT_METHOD(clearAll:(RCTResponseSenderBlock)callback) {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCookieArchive];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *c in cookieStorage.cookies) {
        [cookieStorage deleteCookie:c];
    }
    callback(@[[NSNull null]]);
}

// TODO: return a better formatted list of cookies per domain
RCT_EXPORT_METHOD(getAll:(RCTResponseSenderBlock)callback) {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableDictionary *cookies = [NSMutableDictionary dictionary];
    for (NSHTTPCookie *c in cookieStorage.cookies) {
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:c.value forKey:@"value"];
        [d setObject:c.name forKey:@"name"];
        [d setObject:c.domain forKey:@"domain"];
        [d setObject:c.path forKey:@"path"];
        [cookies setObject:d forKey:c.name];
    }
    callback(@[[NSNull null], cookies]);
}

RCT_EXPORT_METHOD(save:(RCTResponseSenderBlock)callback) {
    NSData *archivedCookies = [NSKeyedArchiver archivedDataWithRootObject:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    [[NSUserDefaults standardUserDefaults] setObject:archivedCookies forKey:kCookieArchive];
    callback(@[[NSNull null]]);
}

RCT_EXPORT_METHOD(load:(RCTResponseSenderBlock)callback) {
    NSData *archivedCookies = [[NSUserDefaults standardUserDefaults] objectForKey:kCookieArchive];
    if (archivedCookies) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:archivedCookies];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    callback(@[[NSNull null]]);
}

@end
