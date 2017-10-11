//
//  CANetworkManager.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#include <dlfcn.h>

#import "CANetworkManager.h"

NSString *const accountExtension       = @"account";
NSString *const statisticsExtension    = @"account/stats";
NSString *const registerExtension      = @"register";
NSString *const resetPasswordExtension = @"reset";
NSString *const itemsExtension         = @"items";
NSString *const newItemExtension       = @"v3/items";
NSString *const favoriteExtension      = @"favorite";
NSString *const shareExtension         = @"share";
NSString *const expirationExtension    = @"expiration";

static NSString *const secureRootURL = @"https://my.cl.ly/";
static NSString *const rootURL = @"http://my.cl.ly/";

@interface CANetworkManager () <NSURLSessionDelegate>
@end

@implementation CANetworkManager

#pragma mark - Initializers

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CANetworkManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Class Methods

+ (NSURLProtectionSpace *)protectionSpace {
    NSURL *url = [CANetworkManager secureUrlWithExtension:accountExtension];
    return [[NSURLProtectionSpace alloc] initWithHost:url.host port:url.port.integerValue protocol:url.scheme realm:nil authenticationMethod:NSURLAuthenticationMethodHTTPDigest];
}

+ (NSURLCredential *)credentialForEmail:(NSString *)email password:(NSString *)password {
    return [NSURLCredential credentialWithUser:email password:password persistence:NSURLCredentialPersistenceForSession];
}

+ (NSURL *)urlWithExtension:(NSString *)extension {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/", rootURL, extension]];
}

+ (NSURL *)urlWithExtension:(NSString *)extension parameters:(NSDictionary *)parameters {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[CANetworkManager urlWithExtension:extension] resolvingAgainstBaseURL:NO];
    NSMutableArray *queryItems  = [NSMutableArray arrayWithArray:components.queryItems];
    for (id parameter in parameters.allKeys) {
        id key   = parameter;
        id value = parameters[key];
        
        if (![key isKindOfClass:[NSString class]]) {
            key = [key stringValue];
        }
        if (![value isKindOfClass:[NSString class]]) {
            value = [value stringValue];
        }
        
        NSURLQueryItem *queryItem = [[NSURLQueryItem alloc] initWithName:key value:value];
        [queryItems addObject:queryItem];
    }
    [components setQueryItems:queryItems];
    
    return components.URL;
}

+ (NSURL *)secureUrlWithExtension:(NSString *)extension {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/", secureRootURL, extension]];
}

+ (NSURL *)secureUrlWithExtension:(NSString *)extension parameters:(NSDictionary *)parameters {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[CANetworkManager secureUrlWithExtension:extension] resolvingAgainstBaseURL:NO];
    NSMutableArray *queryItems  = [NSMutableArray arrayWithArray:components.queryItems];
    for (id parameter in parameters.allKeys) {
        id key   = parameter;
        id value = parameters[key];
        
        if (![key isKindOfClass:[NSString class]]) {
            key = [key stringValue];
        }
        if (![value isKindOfClass:[NSString class]]) {
            value = [value stringValue];
        }
        
        NSURLQueryItem *queryItem = [[NSURLQueryItem alloc] initWithName:key value:value];
        [queryItems addObject:queryItem];
    }
    [components setQueryItems:queryItems];
    
    return components.URL;
}

+ (NSURLRequest *)requestForURL:(NSURL *)url body:(NSDictionary *)jsonBody method:(NSString *)method {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:method];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if (jsonBody) {
        NSError *error = nil;
        NSData *body   = [NSJSONSerialization dataWithJSONObject:jsonBody options:(NSJSONWritingOptions)0 error:&error];
        [request setHTTPBody:body];
    }
    
    return request;
}

+ (NSURLSession *)sessionWithDelegate:(id<NSURLSessionDelegate>)delegate {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session                    = [NSURLSession sessionWithConfiguration:configuration delegate:delegate delegateQueue:nil];
    return session;
}

#pragma mark - Modifiers

- (void)setUserCredential:(NSURLCredential *)userCredential {
    //Set Variables
    NSURLProtectionSpace *protectionSpace = [CANetworkManager protectionSpace];
    NSDictionary *credentials             = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace];
    NSURLCredential *credential           = [credentials.objectEnumerator nextObject];
    
    //Clean Previous Credentials
    if (credential) {
        [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:credential forProtectionSpace:protectionSpace];
    }
    
    //Set New Credentials
    _userCredential = userCredential;
    if (userCredential) {
        [[NSURLCredentialStorage sharedCredentialStorage] setCredential:userCredential forProtectionSpace:protectionSpace];
    }
}

#pragma mark - Actions

- (void)getRequestWithURL:(NSURL *)url completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    [self getRequestWithURL:url delegate:self completion:completion];
}

- (void)getRequestWithURL:(NSURL *)url delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURLSession *session      = [CANetworkManager sessionWithDelegate:delegate];
    NSURLRequest *request      = [CANetworkManager requestForURL:url body:nil method:@"GET"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completion];
    [task resume];
}

- (void)putRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    [self putRequestWithURL:url body:jsonBody delegate:self completion:completion];
}

- (void)putRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURLSession *session      = [CANetworkManager sessionWithDelegate:delegate];
    NSURLRequest *request      = [CANetworkManager requestForURL:url body:jsonBody method:@"PUT"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completion];
    [task resume];
}

- (void)postRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    [self postRequestWithURL:url body:jsonBody delegate:self completion:completion];
}

- (void)postRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURLSession *session      = [CANetworkManager sessionWithDelegate:delegate];
    NSURLRequest *request      = [CANetworkManager requestForURL:url body:jsonBody method:@"POST"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completion];
    [task resume];
}

- (void)deleteRequestWithURL:(NSURL *)url delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURLSession *session      = [CANetworkManager sessionWithDelegate:delegate];
    NSURLRequest *request      = [CANetworkManager requestForURL:url body:nil method:@"DELETE"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completion];
    [task resume];
}

- (void)deleteRequestWithURL:(NSURL *)url completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    [self deleteRequestWithURL:url delegate:self completion:completion];
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge previousFailureCount] == 0) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, self.userCredential);
    }
    else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    if ([challenge previousFailureCount] == 0) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, self.userCredential);
    }
    else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark - Multipart Requests

- (NSString *)mimeTypeForPath:(NSString *)path {
    CFStringRef (*identifierForTag)(CFStringRef, CFStringRef, void *) = dlsym(RTLD_DEFAULT, "UTTypeCreatePreferredIdentifierForTag");
    CFStringRef (*preferredTagWithClass)(CFStringRef, CFStringRef)    = dlsym(RTLD_DEFAULT, "UTTypeCopyPreferredTagWithClass");
    
    CFStringRef kUTTagClassFilenameExtension = CFSTR("public.filename-extension");
    CFStringRef kUTTagClassMIMEType          = CFSTR("public.mime-type");
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI       = identifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(preferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName {
    NSMutableData *httpBody = [NSMutableData data];
    
    //Add params
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    //Add file data
    for (NSString *path in paths) {
        NSString *filename  = [path lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        NSString *mimetype  = [self mimeTypeForPath:path];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

- (void)multiPartPostRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody path:(NSString *)path completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    //Check for valid file
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"Error: no file exists at path, %@", path);
        completion(nil,nil,nil);
        return;
    }
    
    //Create Varaibles
    NSString *boundary           = [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
    NSString *contentType        = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    NSData *httpBody             = [self createBodyWithBoundary:boundary parameters:jsonBody paths:@[path] fieldName:@"file"];
    NSURLSession *session        = [CANetworkManager sessionWithDelegate:self];
    NSMutableURLRequest *request = [[CANetworkManager requestForURL:url body:nil method:@"POST"] mutableCopy];
    
    //Set properties
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody:httpBody];
    
    //Execute Request
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completion];
    [task resume];
}

+ (void (^)(NSData *data, NSURLResponse *response, NSError *error))completionBlockForEmptyResponse:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    return ^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && success) {
                success();
            }
            else if (error && failure) {
                failure(error);
            }
        });
    };
}

@end
