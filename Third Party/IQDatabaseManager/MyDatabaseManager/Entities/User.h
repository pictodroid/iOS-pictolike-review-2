//
//  User.h
//  Pictolike
//
//  Created by Emil Izgin on 12/10/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * gender;

@end
