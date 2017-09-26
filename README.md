# CloudAppSDK
[![Version](https://img.shields.io/github/release/ParticleApps/CloudAppSDK.svg)](https://github.com/ParticleApps/CloudAppSDK/releases)
[![CocoaPods](https://img.shields.io/cocoapods/v/CloudAppSDK.svg)](https://cocoapods.org/pods/CloudAppSDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

CloudAppSDK is a 3rd party SDK for CloudApp that supports iOS & MacOS.

## Adding to Your Project
Simply add the following to your Podfile if you're using [CocoaPods](http://cocoapods.org):

``` ruby
pod 'CloudAppSDK'
```

or Cartfile if you're using [Carthage](https://github.com/Carthage/Carthage):

```
github "ParticleApps/CloudAppSDK"
```

## Usage

### User Management
``` objective-c
//Login with a new user
[[CAUserManager sharedInstance] loginWithEmail:@"user@example.com" password:@"password" success:^(CAUser *user) {
    //Handle Success
} failure:^(NSError *error) {
    //Handle Error
}];
```
`CAUserManager` is a singleton responsible for handling all user requests. CloudApp uses [HTTPDigest](https://en.wikipedia.org/wiki/Digest_access_authentication) to handle authentication. CloudAppSDK stores credentials in the keychain, but does not cache any user information. To validate the currently stored credentails and populate the `currentUser` object use `validateExistingCredentials`.
``` objective-c
[[CAUserManager sharedInstance] validateExistingCredentials:^(CAUser *user) {
    //Already Logged In
} failure:^(NSError *error) {
    //Requires Reauthentication
}];
```

### Data Model
All objects in the data model are read only. Any modifications should be made using either `CAUserManager` or `CAAPIManager`.
#### CAUser
``` objective-c
@property (nonatomic, readonly) NSInteger uniqueId;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *domain;
@property (nonatomic, readonly) NSString *domainHomePage;
@property (nonatomic, readonly) BOOL hasPrivateItems;
@property (nonatomic, readonly) BOOL isSubscribed;
@property (nonatomic, readonly) BOOL isAlpha;
@property (nonatomic, readonly) NSDate *subscriptionExpirationDate;
@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) NSInteger numberOfViews;
```
#### CAItem
``` objective-c
typedef NS_ENUM(NSInteger, CAItemType) {
    CAItemTypeAll      = 0,
    CAItemTypeImage    = 1,
    CAItemTypeText     = 2,
    CAItemTypeBookmark = 3,
    CAItemTypeVideo    = 4,
    CAItemTypeArchive  = 5,
    CAItemTypeAudio    = 6,
    CAItemTypeUnkown   = 7
};

@property (nonatomic, readonly) NSInteger uniqueId;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;
@property (nonatomic, readonly) NSNumber *contentSize;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *slug;
@property (nonatomic, readonly) NSURL *href;
@property (nonatomic, readonly) BOOL isPrivate;
@property (nonatomic, readonly) BOOL isFavorite;
@property (nonatomic, readonly) BOOL isSubscribed;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURL *contentURL;
@property (nonatomic, readonly) NSURL *downloadURL;
@property (nonatomic, readonly) CAItemType type;
@property (nonatomic, readonly) NSInteger views;
@property (nonatomic, readonly) NSURL *iconURL;
@property (nonatomic, readonly) NSURL *remoteURL;
@property (nonatomic, readonly) NSURL *redirectURL;
@property (nonatomic, readonly) NSString *source;
@property (nonatomic, readonly) NSDate *deteledAt;
@property (nonatomic, readonly) NSDate *expiresAt;
@property (nonatomic, readonly) NSInteger expiresAfter;
```

### API

The [new CloudApp API](http://developer.getcloudapp.com) is unfinished, and some calls are still only available via the [old CloudApp API](https://github.com/cloudapp/api#the-cloudapp-api). Below you can find a breakdown of which API each function in the SDK uses.

#### CAUserManager
``` objective-c
//https://github.com/cloudapp/api/blob/master/view-account-stats.md
- (void)fetchStatisticsWithSuccess:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/register.md
- (void)registerWithEmail:(NSString *)email password:(NSString *)password acceptsToS:(BOOL)tos success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#authentication
- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#authentication
- (void)validateExistingCredentials:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/forgot-password.md
- (void)requestPasswordReset:(NSString *)email success:(void (^)())success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/change-default-security.md
- (void)setHasPrivateItems:(BOOL)privateItems success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/set-custom-domain.md
- (void)setCustomDomain:(NSString *)domain homepage:(NSString *)homepage success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/change-password.md
- (void)setPassword:(NSString *)newPassword currentPassword:(NSString *)oldPassword success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/change-email.md
- (void)setEmail:(NSString *)email currentPassword:(NSString *)oldPassword success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;
```
#### CAAPIManager
``` objective-c
//http://developer.getcloudapp.com/#get-a-specific-item
- (void)fetchItemWithUniqueId:(NSInteger)uniqueId success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#get-items
- (void)fetchItemsAtPage:(NSInteger)page success:(void (^)(NSArray<CAItem *> *items))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#get-items
- (void)fetchItemsAtPage:(NSInteger)page
    numberOfItemsPerPage:(NSInteger)numberOfItems
                    type:(CAItemType)type
                 success:(void (^)())success
                 failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/list-items-by-source.md
- (void)fetchItemsAtPage:(NSInteger)page
    numberOfItemsPerPage:(NSInteger)numberOfItems
                  source:(NSString *)source
                 success:(void (^)())success
                 failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/list-items.md
- (void)fetchArchivedItemsAtPage:(NSInteger)page success:(void (^)(NSArray<CAItem *> *items))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/list-items.md
- (void)fetchArchievedItemsAtPage:(NSInteger)page
             numberOfItemsPerPage:(NSInteger)numberOfItems
                             type:(CAItemType)type
                          success:(void (^)(NSArray<CAItem *> *items))success
                          failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#show-favorite-for-item
- (void)fetchItemFavoriteStatus:(CAItem *)item success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/view-domain-details.md
- (void)fetchHomePageForDomain:(NSString *)domain success:(void (^)(NSString *homepage))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#add-item-upload-file
- (void)createNewItem:(NSString *)name filePath:(NSString *)path isPrivate:(BOOL)private success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#add-item-bookmark
- (void)createBookmarkWithName:(NSString *)name url:(NSURL *)url success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/bookmark-multiple-links.md
- (void)createBookmarks:(NSArray<NSDictionary *> *)bookmarks success:(void (^)(NSArray<CAItem *> *items))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#add-a-specific-item-to-favorites
- (void)setItemFavorite:(CAItem *)item isFavorite:(BOOL)favorite success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/change-security-of-item.md
- (void)setItemPrivate:(CAItem *)item isPrivate:(BOOL)private success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#add-change-expiration-for-item
- (void)setItemExpiration:(CAItem *)item expirationDate:(NSDate *)date success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#add-change-expiration-for-item
- (void)setItemExpiration:(CAItem *)item afterViews:(NSInteger)numberOfViews success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#share-item-via-email
- (void)shareItem:(CAItem *)item with:(NSArray<NSString *> *)recipients message:(NSString *)message success:(void (^)())success failure:(void (^)(NSError *error))failure;

//http://developer.getcloudapp.com/#delete-a-specific-item
- (void)deleteItem:(CAItem *)item success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/recover-deleted-item.md
- (void)recoverItem:(CAItem *)item success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

//https://github.com/cloudapp/api/blob/master/rename-item.md
- (void)renameItem:(CAItem *)item name:(NSString *)name success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;
```

## Support

Feel free to open an issue in this project, or drop a line to <rocco@particleapps.co>.
