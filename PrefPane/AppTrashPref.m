//
//  AppTrashPref.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "AppTrashPref.h"

#import "LoginItemsManager.h"

@interface AppTrashPref ()

- (NSString *)appInstallationPath;

- (BOOL)isAppInstalled;
- (void)installApp;
- (void)uninstallApp;

- (BOOL)isAppRunning:(NSRunningApplication **)application;
- (void)launchApp;
- (void)terminateApp;

- (void)updateStatus;

@end


@implementation AppTrashPref

@synthesize installed, running, autoLaunch, statusView;

- (id)initWithBundle:(NSBundle *)bundle {
	self = [super initWithBundle:bundle];
	if (self) {
		loginManager = [LoginItemsManager sharedManager];
	}
	return self;
}

- (void)mainViewDidLoad {
	self.autoLaunch = [loginManager containsItemAtPath:[self appInstallationPath]
												  item:NULL];
	self.running = [self isAppRunning:nil];
	self.installed = [self isAppInstalled];
	
	[self updateStatus];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginItemsChanged:)
												 name:LoginItemsChangedNotification
											   object:nil];
}

- (void)setAutoLaunch:(BOOL)launch {
	if (autoLaunch != launch) {
		[self willChangeValueForKey:@"autoLaunch"];
		autoLaunch = launch;
		[self didChangeValueForKey:@"autoLaunch"];
		
		if (autoLaunch) {
			[loginManager addItemWithPath:[self appInstallationPath]];
		}
		else {
			[loginManager removeItemAtPath:[self appInstallationPath]];
		}
	}
}

- (NSString *)appInstallationPath {
	if (!installPath) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		
		if (![paths count]) {
			NSLog(@"Cannot find the Application Support directory");
			return nil;
		}
		
		installPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"AppTrash/AppTrash.app"] retain];
	}
	
	return installPath;
}

- (BOOL)isAppInstalled {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self appInstallationPath]];
}

- (void)installApp {
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"AppTrash"
																	  ofType:@"app"];
	
	NSError *error = nil;
	
	NSString *dirPath = [[self appInstallationPath] stringByDeletingLastPathComponent];
	
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dirPath
								   withIntermediateDirectories:YES
													attributes:nil
														 error:&error]) {
		
		NSLog(@"Cannot create AppTrash 'agent' directory. Error: %@", error);
		return;
	}
	
	if (![[NSFileManager defaultManager] copyItemAtPath:path
												 toPath:[self appInstallationPath]
												  error:&error]) {
		
		NSLog(@"Cannot install AppTrash 'agent'. Error: %@", error);
		return;
	}
	
	if (!self.autoLaunch) {
		self.autoLaunch = YES;
	}
	
	self.installed = YES;
}

- (void)uninstallApp {
	if (self.autoLaunch) {
		self.autoLaunch = NO;
	}
	
	NSError *error = nil;
	
	if (![[NSFileManager defaultManager] removeItemAtPath:[self appInstallationPath]
													error:&error]) {
		
		NSLog(@"Cannot uninstall AppTrash 'agent'. Error: %@", error);
	}
	
	self.installed = NO;
}

- (BOOL)isAppRunning:(NSRunningApplication **)application {
	NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.MattRajca.AppTrash"];
	
	if (![apps count])
		return NO;
	
	if (application) {
		*application = [apps objectAtIndex:0];
	}
	
	return YES;
}

- (void)launchApp {
	NSURL *url = [NSURL fileURLWithPath:[self appInstallationPath]];
	
	NSError *error = nil;
	
	if (![[NSWorkspace sharedWorkspace] launchApplicationAtURL:url
													   options:NSWorkspaceLaunchWithoutActivation
												 configuration:nil
														 error:&error]) {
		
		NSLog(@"Cannot start AppTrash 'agent'. Error: %@", error);
		return;
	}
	
	self.running = YES;
	[self updateStatus];
}

- (void)terminateApp {
	NSRunningApplication *app = nil;
	
	if ([self isAppRunning:&app]) {
		[app terminate];
		
		self.running = NO;
		[self updateStatus];
	}
}

- (void)updateStatus {
	if (self.installed) {
		if (self.running) {
			[statusView setStringValue:NSLocalizedString(@"Running", nil)];
		}
		else {
			[statusView setStringValue:NSLocalizedString(@"Installed", nil)];
		}
	}
	else {
		[statusView setStringValue:NSLocalizedString(@"Not installed", nil)];
	}
}

- (void)loginItemsChanged:(NSNotification *)aNotification {
	self.autoLaunch = [loginManager containsItemAtPath:[self appInstallationPath]
												  item:NULL];
}

- (IBAction)install:(id)sender {
	[self installApp];
	[self launchApp];
	
	[self updateStatus];
}

- (IBAction)uninstall:(id)sender {
	[self terminateApp];
	[self uninstallApp];
	
	[self updateStatus];
}

@end
