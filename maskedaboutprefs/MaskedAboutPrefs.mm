#import <Preferences/Preferences.h>
#import <Preferences/PSEditableTableCell.h>

@interface MaskedAboutPrefsListController: PSListController
@end

@implementation MaskedAboutPrefsListController
-(id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"MaskedAboutPrefs" target:self] retain];
	}
	return _specifiers;
}

-(void)donate {
	NSURL* url = [[NSURL alloc] initWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=8PGP9PY65ZRX8&lc=US&item_name=ryst%20tweaks&currency_code=USD"];
	[[UIApplication sharedApplication] openURL:url];
}
@end

@interface RightAlignEditableTableCell : PSEditableTableCell
@end

@implementation RightAlignEditableTableCell
-(id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
	if (self) {
		UITextField* textField = [self textField];
		textField.textAlignment = NSTextAlignmentRight;
	}
	return self;
}
@end

// vim:ft=objc
