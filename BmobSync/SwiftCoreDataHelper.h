//
//  CoreDataHelper.h
//  CoreDataExample1
//
//  Created by Training on 21.05.14.
//  Copyright (c) 2014 Training. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SwiftCoreDataHelper : NSObject

+(NSString*)directoryForDatabaseFilename;
+(NSString*)databaseFilename;

+(NSManagedObjectContext*)managedObjectContext;

+(id)insertManagedObjectOfClass:(NSString*)ClassName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+(BOOL)saveManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+(NSArray*)fetchEntitiesForClass:(NSString*)ClassName withPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
