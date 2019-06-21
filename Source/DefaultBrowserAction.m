//
//	DefaultBrowserAction.m
//	ControlPlaneX
//
//	Created by David Jennes on 03/09/11.
//	Copyright 2011. All rights reserved.
//

#import "DefaultBrowserAction.h"

@interface DefaultBrowserAction (Private)

+ (id) idToName: (NSString *) bundleID;

@end

@implementation DefaultBrowserAction

- (id) init {
	self = [super init];
	if (!self)
		return nil;
	
	app = [[NSString alloc] init];
    [self setControlPlaneXAsURLHandler];
	
	return self;
}

- (id) initWithDictionary: (NSDictionary *) dict {
	self = [super initWithDictionary: dict];
	if (!self)
		return nil;
	
	app = [[dict valueForKey: @"parameter"] copy];
    [self setControlPlaneXAsURLHandler];

	
	return self;
}

- (id) initWithOption: (NSString *) option {
	self = [super init];
	if (!self)
		return nil;
	
	app = [option copy];
    [self setControlPlaneXAsURLHandler];
	
	return self;
}

- (void) setControlPlaneXAsURLHandler {
    NSString *currentSystemBrowser = (__bridge_transfer NSString *)LSCopyDefaultHandlerForURLScheme((CFStringRef) @"http");
    
    if (![[currentSystemBrowser lowercaseString] isEqualToString:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"You are adding or have triggered a Default Browser Action but ControlPlaneX is not currently set as the system wide default web browser. For the Default Browser Action feature to work properly ControlPlaneX must be set as the system's default web browser. ControlPlaneX will take the URL and then pass it to the browser of your choice. You may be asked to confirm this choice if you are using OS X 10.10 (Yosemite) or higher. Please select 'Use ControlPlaneX' if prompted." , @"")];
        [alert runModal];
        
        LSSetDefaultHandlerForURLScheme((CFStringRef) @"https", (__bridge CFStringRef) [[NSBundle mainBundle] bundleIdentifier]);
        LSSetDefaultRoleHandlerForContentType(kUTTypeHTML, kLSRolesViewer, (__bridge CFStringRef) [[NSBundle mainBundle] bundleIdentifier]);
        LSSetDefaultRoleHandlerForContentType(kUTTypeURL, kLSRolesViewer, (__bridge CFStringRef) [[NSBundle mainBundle] bundleIdentifier]);
        LSSetDefaultRoleHandlerForContentType(kUTTypeFileURL, kLSRolesViewer, (__bridge CFStringRef) [[NSBundle mainBundle] bundleIdentifier]);
        LSSetDefaultRoleHandlerForContentType(kUTTypeText, kLSRolesViewer, (__bridge CFStringRef) [[NSBundle mainBundle] bundleIdentifier]);

    }
    LSSetDefaultHandlerForURLScheme((CFStringRef) @"http", (__bridge CFStringRef) [[NSBundle mainBundle] bundleIdentifier]);

}

- (NSMutableDictionary *) dictionary {
	NSMutableDictionary *dict = [super dictionary];
	
	[dict setObject:[app copy] forKey: @"parameter"];
	
	return dict;
}

- (NSString *) description {
	return [NSString stringWithFormat: NSLocalizedString(@"Setting default browser to %@", @""), app];
}

- (BOOL) execute: (NSString **) errorString {
    [[NSUserDefaults standardUserDefaults] setValue:app forKey:@"currentDefaultBrowser"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return YES;
    
}

+ (NSString *) helpText {
	return NSLocalizedString(@"The parameter for DefaultBrowser actions is the ID (bundle) "
							 "of the new default browser.", @"");
}

+ (NSString *) creationHelpText {
	return NSLocalizedString(@"Set default browser to:", @"");
}

+ (NSArray *) limitedOptions {
    NSArray *handlers = (__bridge_transfer NSArray *) LSCopyAllHandlersForURLScheme((CFStringRef) @"http");
	
	// no handlers
	if (!handlers)
		return [NSArray array];
	
	NSUInteger total = [handlers count];
	NSMutableArray *options = [NSMutableArray arrayWithCapacity: total];
	
	for (NSUInteger i = 0; i < total; ++i) {
		NSString *bundleID = [handlers objectAtIndex: i];
		
        if ([[bundleID lowercaseString] isEqualToString:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]])
            continue;
		[options addObject: [NSDictionary dictionaryWithObjectsAndKeys:
							 bundleID, @"option",
							 [self idToName: bundleID], @"description", nil]];
	}
	
	return options;
}

+ (NSString *) idToName: (NSString *) bundleID {
	NSString * path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier: bundleID];
	
	return [[NSFileManager defaultManager] displayNameAtPath: path];
}

+ (NSString *) friendlyName {
    return NSLocalizedString(@"Default Browser", @"");
}

+ (NSString *)menuCategory {
    return NSLocalizedString(@"Web", @"");
}

- (void)handleURL:(NSString *)url {
    NSString *browser = [[NSUserDefaults standardUserDefaults] valueForKey:@"currentDefaultBrowser"];

    
    if (!browser) {
        browser = @"com.apple.Safari";
    }
    
    NSString *decodedURL = [url stringByRemovingPercentEncoding];
    NSString *newURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                             NULL,
                                                                                             (CFStringRef)decodedURL,
                                                                                             (CFStringRef)@"#",
                                                                                             (CFStringRef)@" ",
                                                                                             kCFStringEncodingUTF8 ));
    NSArray *urls = [NSArray arrayWithObject:[NSURL URLWithString:newURL]];


    [[NSWorkspace sharedWorkspace] openURLs:urls withAppBundleIdentifier:browser options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:nil];
}



@end
