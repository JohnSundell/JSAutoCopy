#import "NSObject+JSAutoCopy.h"
#import <objc/runtime.h>

@implementation NSObject (JSAutoCopy)

#pragma mark - Public API

- (instancetype)autoCopy
{
    return [self autoCopyIgnoringProperties:nil block:nil];
}

- (instancetype)autoCopyIgnoringProperties:(NSArray *)ignoredPropertyNames
{
    return [self autoCopyIgnoringProperties:ignoredPropertyNames block:nil];
}

- (instancetype)autoCopyWithBlock:(JSAutoCopyBlock)block
{
    return [self autoCopyIgnoringProperties:nil block:block];
}

- (instancetype)autoCopyWithDelegate:(id<JSAutoCopyDelegate>)delegate
{
    return [self autoCopyIgnoringProperties:nil block:^id(NSString *propertyName, id autoCopiedValue) {
        return [delegate autoCopiedValueForObject:self
                                     propertyName:propertyName
                                  autoCopiedValue:autoCopiedValue];
    }];
}

#pragma mark - Private

- (instancetype)autoCopyIgnoringProperties:(NSArray *)ignoredPropertyNames block:(JSAutoCopyBlock)block
{
    if ([self conformsToProtocol:@protocol(NSMutableCopying)]) {
        typeof(self) copy = [self mutableCopy];
        
        if ([self conformsToProtocol:@protocol(NSFastEnumeration)]) {
            if ([copy respondsToSelector:@selector(removeAllObjects)]) {
                [copy performSelector:@selector(removeAllObjects)];
            } else {
                return copy;
            }
            
            for (id item in (id<NSFastEnumeration>)self) {
                if ([copy respondsToSelector:@selector(addObject:)]) {
                    id itemCopy = [item autoCopyIgnoringProperties:nil block:block];
                    
                    [copy performSelector:@selector(addObject:) withObject:itemCopy];
                    
                    continue;
                }
                
                if ([copy respondsToSelector:@selector(objectForKey:)] && [copy respondsToSelector:@selector(setObject:forKey:)]) {
                    id itemForKey = [self performSelector:@selector(objectForKey:) withObject:item];
                    id itemCopy = [itemForKey autoCopyIgnoringProperties:nil block:block];
                    
                    [copy performSelector:@selector(setObject:forKey:) withObject:itemCopy withObject:item];
                }
            }
        }
            
        return copy;
    }
    
    if ([self conformsToProtocol:@protocol(NSCopying)]) {
        return [self copy];
    }
    
    typeof(self) copy = [[self class] new];
    NSMutableSet *copiedProperties = [NSMutableSet new];
    Class currentClass = [self class];
    
    while (currentClass && currentClass != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyCount);
        
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = propertyList[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            
            if ([ignoredPropertyNames containsObject:propertyName]) {
                continue;
            }
            
            if (![copiedProperties containsObject:propertyName]) {
                id propertyValue = [self valueForKey:propertyName];
                id copiedValue = nil;
                
                if ([propertyValue conformsToProtocol:@protocol(NSCopying)]) {
                    copiedValue = [propertyValue copy];
                }
                
                if (copiedValue && block) {
                    copiedValue = block(propertyName, copiedValue);
                }
                
                if (copiedValue) {
                    [copy setValue:copiedValue forKey:propertyName];
                }
                
                [copiedProperties addObject:propertyName];
            }
        }
        
        free(propertyList);
        
        currentClass = [currentClass superclass];
    }
    
    return copy;
}

@end