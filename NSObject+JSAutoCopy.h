#import <Foundation/Foundation.h>

/**
 *  Block used as a callback when auto copying an object with a block
 *
 *  @param propertyName The name of the property that is being copied
 *  @param autoCopiedValue The value that was automatically copied
 *
 *  @return The value that should be assigned to the property of the copy
 */
typedef id(^JSAutoCopyBlock)(NSString *propertyName, id autoCopiedValue);

/**
 *  Delegate protocol to be able to intercept the copy of an object and
 *  override the auto copied value
 */
@protocol JSAutoCopyDelegate <NSObject>

/**
 *  Sent to the delegate when a property is about to be auto copied
 *
 *  @param object The object that is being copied
 *  @param propertyName The name of the property that is being copied
 *  @param autoCopiedValue The value that was automatically copied
 *
 *  @discussion Use this method to override the auto copied value of
 *  specific properties. Useful when copying objects that has a deep
 *  data structure, or when certain properties should be ignored.
 *
 *  @return The value that should be assigned to the property of the copy.
 *  When this method returns nil, the property is not assigned.
 */
- (id)autoCopiedValueForObject:(id)object
                  propertyName:(NSString *)propertyName
               autoCopiedValue:(id)autoCopiedValue;

@end

/**
 *  A category that allows for automatic copying of any Objective-C object
 */
@interface NSObject (JSAutoCopy)

/**
 *  Automatically copy the object
 *
 *  @discussion The object will be copied by iterating through its properties
 *  (both those declared in its public API and in any class extensions).
 *  Each property which value conforms to <NSCopying> will be copied and assigned
 *  to the same property of the copied object.
 *
 *  If the object conforms to <NSCopying> this method simply returns [self copy].
 */
- (instancetype)autoCopy;

/**
 *  Automatically copy the object, ignoring certain properties
 *
 *  @param ignoredPropertyNames An array of NSString instances representing
 *  property names that should be ignored when copying.
 *
 *  @see -autoCopy for more information about how auto copy works.
 */
- (instancetype)autoCopyIgnoringProperties:(NSArray *)ignoredPropertyNames;

/**
 *  Automatically copy the object, invoking a block for each property
 *
 *  @param block The block that should be invoked for each property
 *  that is copied. If the block returns a non-nil value, that value will
 *  be assigned to the property of the copy, instead of the auto-copied one.
 *
 *  @see -autoCopy for more information about how auto copy works.
 *  JSAutoCopyBlock for documentation of the parameters of the block.
 */
- (instancetype)autoCopyWithBlock:(JSAutoCopyBlock)block;

/**
 *  Automatically copy the object, calling back to a delegate for each property
 *
 *  @param delegate The delegate that should be called for each property that
 *  is copied. The delegate will be sent the -autoCopiedValueForObject:propertyName:
 *  autoCopiedValue:-message, and if that call returns a non-nil value, that value
 *  will be assigned to the property of the copy, instead of the auto-copied one.
 *
 *  @see -autoCopy for more information about how auto copy works.
 *  JSAutoCopyDelegate for documentation of the delegate protocol.
 */
- (instancetype)autoCopyWithDelegate:(id<JSAutoCopyDelegate>)delegate;

@end