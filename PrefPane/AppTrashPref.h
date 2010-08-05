//
//  AppTrashPref.h
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import "LoginItemsManager.h"

@interface AppTrashPref : NSPreferencePane {
  @private
	NSTextField *statusView;
	LoginItemsManager *loginManager;
	NSString *installPath;
	BOOL installed;
	BOOL running;
	BOOL autoLaunch;
}

@property (nonatomic, assign, getter=isInstalled) BOOL installed;
@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=shouldAutoLaunch) BOOL autoLaunch;

@property (nonatomic, assign) IBOutlet NSTextField *statusView;

- (IBAction)install:(id)sender;
- (IBAction)uninstall:(id)sender;

@end
