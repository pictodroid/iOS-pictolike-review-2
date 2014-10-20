//
//  FeedTable.h
//  DatabaseManager

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FeedTable : NSManagedObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSNumber *likes;
@property (nonatomic, retain) NSString *user;

@end
