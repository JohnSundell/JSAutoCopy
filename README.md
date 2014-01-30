JSAutoCopy
===================

#### Automatically copy any Objective-C object

* No need to write manual NSCopying implementations, just use the methods provided by NSObject+JSAutoCopy to automatically copy your objects.
* Manual -copyWithZone: implementations can quickly become outdated as your class' interface is changed, and can therefor cause hard-to-find bugs & issues.
* Provides several override points for custom copying on a property basis.

#### Here's how to use JSAutoCopy:

##### 1. Import NSObject+JSAutoCopy

```objective-c
#import "NSObject+JSAutoCopy.h"
```

##### 2. Use any of the category's public methods to create an automatic copy of an object

```objective-c
// Copy all properties of an object
MyClass *myCopy = [myObject autoCopy];

// Ignore certain properties when copying
NSArray *ignoredPropertyNames = @[@"ignoredPropertyName"];
MyClass *myOtherCopy = [myObject autoCopyIgnoringProperties:ignoredPropertyNames];

// Invoke a block for each property when copying
MyClass *myThirdCopy = [myObject autoCopyWithBlock:^id(NSString *propertyName, id autoCopiedValue) {
	if ([propertyName isEqualToString:@"mySpecialProperty"]) {
		return [autoCopiedValue doSomethingBeforeCopying];
	}

	return autoCopiedValue;
}];

// Call back to a delegate for each property when copying
MyClass *myForthCopy = [myObject autoCopyWithDelegate:self];

- (id)autoCopiedValueForObject:(id)object propertyName:(NSString *)propertyName autoCopiedValue:(id)autoCopiedValue
{
	if ([propertyName isEqualToString:@"mySpecialProperty"]) {
		return [autoCopiedValue doSomethingBeforeCopying];
	}

	return autoCopiedValue;
}
```

#### Hope that you'll enjoy using JSAutoCopy!

Why not give me a shout on Twitter: [@johnsundell](https://twitter.com/johnsundell)