@class MIMEAddress, Source;

@interface Package : NSObject

@property (nonatomic, retain, readonly) NSString *id;
@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) MIMEAddress *author;
@property (nonatomic, retain, readonly) Source *source;

@end
