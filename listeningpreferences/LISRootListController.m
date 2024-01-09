#import <Foundation/Foundation.h>
#import "LISRootListController.h"

@implementation LISRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)openGithub {
	[[UIApplication sharedApplication]
	openURL:[NSURL URLWithString:@"https://github.com/ivanhrabcak/Listening"]
	options:@{}
	completionHandler:nil];
}

@end
