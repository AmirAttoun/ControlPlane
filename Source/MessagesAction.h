//
//  MessagesAction.h
//  ControlPlaneX
//
//  Created by Dustin Rue on 6/23/12.
//
//

#import "Action.h"

@interface MessagesAction : Action <ActionWithString> {
    NSString *status;
}

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSMutableDictionary *)dictionary;

- (NSString *)description;
- (BOOL)execute:(NSString **)errorString;
+ (NSString *)helpText;
+ (NSString *)creationHelpText;

@end
