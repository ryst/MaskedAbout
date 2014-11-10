
@interface PSSpecifier : NSObject
- (id)properties;
@end

static bool hookedUsageSettings = NO;
static bool enabled = NO;
static NSMutableDictionary* strings;

static void loadOverrideStringFromSettings(NSString* key, NSDictionary* settings) {
	id object = [settings objectForKey:key];
	if (object != nil) {
		[strings setObject:object forKey:key];
	}
}

static void loadSettings() {
	NSString* settingsPlist = @"/var/mobile/Library/Preferences/com.ryst.maskedabout.plist";
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:settingsPlist];

	enabled = [settings objectForKey:@"enabled"] ? [[settings objectForKey:@"enabled"] boolValue] : NO;

	[strings removeAllObjects];

	// Get each object and add it to the dictionary of strings
	loadOverrideStringFromSettings(@"about-network", settings);
	loadOverrideStringFromSettings(@"about-songs", settings);
	loadOverrideStringFromSettings(@"about-videos", settings);
	loadOverrideStringFromSettings(@"about-photos", settings);
	loadOverrideStringFromSettings(@"about-applications", settings);
	loadOverrideStringFromSettings(@"about-capacity", settings);
	loadOverrideStringFromSettings(@"about-available", settings);
	loadOverrideStringFromSettings(@"about-productversion", settings);
	loadOverrideStringFromSettings(@"about-carrierversion", settings);
	loadOverrideStringFromSettings(@"about-productmodel", settings);
	loadOverrideStringFromSettings(@"about-serialnumber", settings);
	loadOverrideStringFromSettings(@"about-macaddress", settings);
	loadOverrideStringFromSettings(@"about-btmacaddress", settings);
	loadOverrideStringFromSettings(@"about-modemimei", settings);
	loadOverrideStringFromSettings(@"about-iccid", settings);
	loadOverrideStringFromSettings(@"about-modemversion", settings);

	loadOverrideStringFromSettings(@"usage-storageavailable", settings);
	loadOverrideStringFromSettings(@"usage-storageused", settings);

	// If there are no overrides, turn off the enable flag.
	if ([strings count] == 0) {
		enabled = NO;
	}
}

static void receivedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	loadSettings();
}

static NSString* getOverrideString(NSString* key) {
	if (!enabled) {
		return nil;
	}

	id override = [strings objectForKey:key];
	if (override != nil && ![override isEqualToString:@""]) {
		return override;
	}

	return nil;
}

%group UsageSettingsHook
%hook UsageTotalUsedHeader
-(void)setUsed:(id)used {
	used = getOverrideString(@"usage-storageused") ?: used;
	%orig;
}

-(void)setAvailable:(id)available {
	available = getOverrideString(@"usage-storageavailable") ?: available;
	%orig;
}
%end
%end //group UsageSettingsHook

%hook AboutController
-(id)_photos:(id)photos {
	id r = getOverrideString(@"about-photos") ?: %orig;
	return r;
}

-(id)_videos:(id)videos {
	id r = getOverrideString(@"about-videos") ?: %orig;
	return r;
}

-(id)_songs:(id)songs {
	id r = getOverrideString(@"about-songs") ?: %orig;
	return r;
}

-(id)_carrierVersion:(id)version {
	id r = getOverrideString(@"about-carrierversion") ?: %orig;
	return r;
}
-(void)_addKey:(id)key value:(id)value array:(id)array isCopyable:(BOOL)copyable {
	if ([key isEqualToString:@"NETWORK"]) {
		value = getOverrideString(@"about-network") ?: value;
	} else if ([key isEqualToString:@"APPLICATIONS"]) {
		value = getOverrideString(@"about-applications") ?: value;
	} else if ([key isEqualToString:@"User Data Capacity"]) {
		value = getOverrideString(@"about-capacity") ?: value;
	} else if ([key isEqualToString:@"User Data Available"]) {
		value = getOverrideString(@"about-available") ?: value;
	} else if ([key isEqualToString:@"ProductVersion"]) {
		value = getOverrideString(@"about-productversion") ?: value;
	} else if ([key isEqualToString:@"ProductModel"]) {
		value = getOverrideString(@"about-productmodel") ?: value;
	} else if ([key isEqualToString:@"SerialNumber"]) {
		value = getOverrideString(@"about-serialnumber") ?: value;
	} else if ([key isEqualToString:@"MACAddress"]) {
		value = getOverrideString(@"about-macaddress") ?: value;
	} else if ([key isEqualToString:@"BTMACAddress"]) {
		value = getOverrideString(@"about-btmacaddress") ?: value;
	} else if ([key isEqualToString:@"ModemIMEI"]) {
		value = getOverrideString(@"about-modemimei") ?: value;
	} else if ([key isEqualToString:@"ICCID"]) {
		value = getOverrideString(@"about-iccid") ?: value;
	} else if ([key isEqualToString:@"ModemVersion"]) {
		value = getOverrideString(@"about-modemversion") ?: value;
	}

	%orig;
}
%end

%hook PSViewController
-(void)setSpecifier:(id)specifier {
	%orig;

	if (!hookedUsageSettings && [%c(UsageStorageMonitor) class] != nil) {
		%init(UsageSettingsHook);
		hookedUsageSettings = YES;
	}
}
%end

%ctor {
	%init;

	strings = [NSMutableDictionary dictionaryWithCapacity:20];

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		receivedNotification,
		CFSTR("com.ryst.maskedabout.settingsChanged"),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce);

	loadSettings();
}

