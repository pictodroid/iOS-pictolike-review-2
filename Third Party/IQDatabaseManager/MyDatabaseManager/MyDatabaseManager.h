//
//  MyDatabaseManager.h
//  DatabaseManager

#import "IQDatabaseManager.h"

#import "FeedTable.h"
#import "Settings.h"
#import "User.h"
#import "Picto.h"

@interface MyDatabaseManager : IQDatabaseManager

- (NSArray *)allFeeds;
//- (NSArray *)allRecordsSortByAttribute:(NSString*)attribute where:(NSString*)key contains:(id)value;

- (FeedTable*) insertRecordInFeedTable:(NSDictionary*)recordAttributes;
//- (FeedTable*) insertUpdateRecordInFeedTable:(NSDictionary*)recordAttributes;
- (FeedTable*) updateRecord:(FeedTable*)record inFeedTable:(NSDictionary*)recordAttributes;
- (BOOL) deleteTableRecord:(FeedTable*)record;

//- (BOOL) deleteAllTableRecord;

- (Settings*) settings;
- (Settings*) saveSettings:(NSDictionary*)settings;

- (User*) insertRecordInUser:(NSDictionary*)recordAttributes;

- (Picto*) insertRecordInPicto:(NSDictionary*)recordAttributes;

- (NSArray*)allPictos;

@end
