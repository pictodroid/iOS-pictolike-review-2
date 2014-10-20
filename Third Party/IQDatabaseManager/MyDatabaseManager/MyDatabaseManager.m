//
//  MyDatabaseManager.m
//  DatabaseManager

#import "MyDatabaseManager.h"
#import "IQDatabaseManagerSubclass.h"
#import "User.h"
#import "Picto.h"

@implementation MyDatabaseManager

+(NSURL*)modelURL
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyDatabase" withExtension:IQ_MODEL_EXTENSION_momd];
    
    if (modelURL == nil)    modelURL = [[NSBundle mainBundle] URLForResource:@"MyDatabase" withExtension:IQ_MODEL_EXTENSION_mom];

    return modelURL;
}

#pragma mark - RecordTable
- (NSArray *)allFeeds
{
    return [self allObjectsFromTable:NSStringFromClass([FeedTable class])];
}

//- (NSArray *)allRecordsSortByAttribute:(NSString*)attribute where:(NSString*)key contains:(id)value
//{
//    NSSortDescriptor *sortDescriptor = nil;
//    
//    if ([attribute length]) sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];
//
//    return [self allObjectsFromTable:NSStringFromClass([FeedTable class]) where:key contains:value sortDescriptor:sortDescriptor];
//}

- (FeedTable*) insertRecordInFeedTable:(NSDictionary*)recordAttributes
{
    return (FeedTable*)[self insertRecordInTable:NSStringFromClass([FeedTable class]) withAttribute:recordAttributes];
}

//- (FeedTable*) insertUpdateRecordInRecordTable:(NSDictionary*)recordAttribute
//{
//    return (FeedTable*)[self insertRecordInTable:NSStringFromClass([FeedTable class]) withAttribute:recordAttribute updateOnExistKey:kEmail equals:[recordAttribute objectForKey:kEmail]];
//}

- (FeedTable*) updateRecord:(FeedTable*)record inFeedTable:(NSDictionary*)recordAttributes
{
    return (FeedTable*)[self updateRecord:record withAttribute:recordAttributes];
}

- (BOOL) deleteTableRecord:(FeedTable*)record
{
    return [self deleteRecord:record];
}

//-(BOOL) deleteAllTableRecord
//{
//    return [self flushTable:NSStringFromClass([FeedTable class])];
//}

#pragma mark - User

- (NSArray *)allUsers
{
    return [self allObjectsFromTable:NSStringFromClass([User class])];
}


- (User*) insertRecordInUser:(NSDictionary*)recordAttributes
{
    return (User*)[self insertRecordInTable:NSStringFromClass([User class]) withAttribute:recordAttributes];
}

//- (User*) insertUpdateRecordInRecordTable:(NSDictionary*)recordAttribute
//{
//    return (User*)[self insertRecordInTable:NSStringFromClass([User class]) withAttribute:recordAttribute updateOnExistKey:kEmail equals:[recordAttribute objectForKey:kEmail]];
//}

- (User*) updateRecord:(User*)record inUser:(NSDictionary*)recordAttributes
{
    return (User*)[self updateRecord:record withAttribute:recordAttributes];
}

- (BOOL) deleteUserRecord:(User*)record
{
    return [self deleteRecord:record];
}


#pragma mark - Picto

- (NSArray *)allPictos
{
    return [self allObjectsFromTable:NSStringFromClass([Picto class])];
}

- (Picto*) insertRecordInPicto:(NSDictionary*)recordAttributes
{
    return (Picto*)[self insertRecordInTable:NSStringFromClass([Picto class]) withAttribute:recordAttributes];
}

//- (Picto*) insertUpdateRecordInRecordTable:(NSDictionary*)recordAttribute
//{
//    return (Picto*)[self insertRecordInTable:NSStringFromClass([Picto class]) withAttribute:recordAttribute updateOnExistKey:kEmail equals:[recordAttribute objectForKey:kEmail]];
//}

- (Picto*) updateRecord:(Picto*)record inPicto:(NSDictionary*)recordAttributes
{
    return (Picto*)[self updateRecord:record withAttribute:recordAttributes];
}

- (BOOL) deletePictoRecord:(Picto*)record
{
    return [self deleteRecord:record];
}


#pragma mark - Settings
- (Settings*) settings
{
    Settings *settings = (Settings*)[self firstObjectFromTable:NSStringFromClass([Settings class])];
    
    //No settings
    if (settings == nil)
    {
        //Inserting default settings
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kPassword, nil];
        
//        settings = (Settings*)[self insertRecordInTable:NSStringFromClass([Settings class]) withAttribute:dict];
        settings = (Settings*)[self insertRecordInTable:NSStringFromClass([Settings class]) withAttribute:nil];
    }

    return settings;
}

- (Settings*) saveSettings:(NSDictionary*)settings
{
    Settings *mySettings = (Settings*)[self firstObjectFromTable:NSStringFromClass([Settings class]) createIfNotExist:YES];
    return (Settings*)[self updateRecord:mySettings withAttribute:settings];
}

@end
