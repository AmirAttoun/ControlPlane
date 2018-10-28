//
//	MailIntervalAction.h
//	ControlPlane
//
//	Created by David Jennes on 02/09/11.
//	Copyright 2011. All rights reserved.
//

#import "Action.h"


@interface MailIntervalAction : Action <ActionWithLimitedOptions> {
	NSNumber *time;
}

- (id) initWithDictionary: (NSDictionary *) dict;
- (NSMutableDictionary *) dictionary;

- (NSString *) description;
- (BOOL) execute: (NSString **) errorString;
+ (NSString *) helpText;
+ (NSString *) creationHelpText;

+ (NSArray *) limitedOptions;
- (id) initWithOption: (NSString *) option;

@end
