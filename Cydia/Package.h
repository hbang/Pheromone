@class MIMEAddress;

@interface Package : NSObject

@property (nonatomic, retain, readonly) NSString *id;
@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) MIMEAddress *author;

@end
