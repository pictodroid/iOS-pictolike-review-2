//
//  Picto.h
//  Pictolike
//
//  Created by Emil Izgin on 12/10/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Picto : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSData * imageobj;
@property (nonatomic, retain) NSDate * datecreated;
@property (nonatomic, retain) NSNumber * locationcreated;
@property (nonatomic, retain) NSNumber * noOfLikes;
@property (nonatomic, retain) NSNumber * noOfViews;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * reportedStatus;

@end
