//
//  CoreDataHelper.m
//  CoreDataExample1
//
//  Created by Training on 21.05.14.
//  Copyright (c) 2014 Training. All rights reserved.
//

#import "SwiftCoreDataHelper.h"

@implementation SwiftCoreDataHelper


+ (NSString *)directoryForDatabaseFilename
{
     return [NSHomeDirectory() stringByAppendingString:@"/Library/Private Documents"];
}


+(NSString*) databaseFilename{
    
    return @"database.sqlite";
}

+(NSManagedObjectContext*)managedObjectContext{
    
    NSError* error;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[SwiftCoreDataHelper directoryForDatabaseFilename] withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error){
        NSLog(@"%@",[error localizedDescription]);
        return nil;
    }
    
    NSString* path = [NSString stringWithFormat:@"%@/%@",[SwiftCoreDataHelper directoryForDatabaseFilename], [SwiftCoreDataHelper databaseFilename]];
    
    NSURL* url = [NSURL fileURLWithPath:path];
    
    
    NSManagedObjectModel* managedModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator* storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedModel];
    
    if (![storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]){
        NSLog(@"%@",[error localizedDescription]);
        return nil;
    }
    
    NSManagedObjectContext* managedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [managedContext setPersistentStoreCoordinator:storeCoordinator];
    
    return managedContext;
}


+(id) insertManagedObjectOfClass:(NSString*)ClassName inManagedObjectContext:(NSManagedObjectContext*) managedObjectContext{
    
    NSManagedObject* managedObject = [NSEntityDescription insertNewObjectForEntityForName:ClassName inManagedObjectContext:managedObjectContext];
    
    
    return managedObject;
}

+(BOOL) saveManagedObjectContext:(NSManagedObjectContext*) managedObjectContext{
    NSError* error;
    
    if (![managedObjectContext save:&error]){
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

+(NSArray*) fetchEntitiesForClass:(NSString*)ClassName withPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext{
    
    NSError* error;
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:ClassName inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setPredicate:predicate];
    
    NSArray* items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error){
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    
    return items;
}


@end