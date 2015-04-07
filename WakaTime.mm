//
//  WakaTime.mm
//
//

#import "WakaTime.h"
#import "NSWindow+KKSwizzle.h"

static NSString *VERSION = @"1.0.1";
static NSString *TEXTMATE_VERSION = nil;
static NSString *TEXTMATE_BUILD = nil;
static NSString *WAKATIME_INSTALL_SCRIPT = @"Library/Application Support/TextMate/PlugIns/WakaTime.tmplugin/Contents/Resources/install_dependencies.sh";
static NSString *WAKATIME_CLI = @"Library/Application Support/TextMate/PlugIns/WakaTime.tmplugin/Contents/Resources/wakatime-master/wakatime/cli.py";
static NSString *CONFIG_FILE = @".wakatime.cfg";
static int FREQUENCY = 2;  // minutes


@implementation WakaTime

static NSMutableDictionary *_windows;
static NSString *_lastFile;
static CFAbsoluteTime _lastTime;

+ (void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        _windows = [[ NSMutableDictionary alloc] init];
    }
}

- (id)initWithPlugInController:(id <TMPlugInController>)aController {

    NSApp = [NSApplication sharedApplication];
    if(self = [super init]) {
        NSLog(@"Initializing WakaTime plugin v%@ (http://wakatime.com)", VERSION);
        
        // Set runtime constants
        CONFIG_FILE = [NSHomeDirectory() stringByAppendingPathComponent:CONFIG_FILE];
        TEXTMATE_VERSION = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        TEXTMATE_BUILD = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        // check for wakatime cli
        NSString *cli = [NSHomeDirectory() stringByAppendingPathComponent:WAKATIME_CLI];
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if (![filemgr fileExistsAtPath:cli]) {
            [self installCLI];
        }
        
        NSString *api_key = [[self getApiKey] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (api_key == NULL || [api_key length] == 0) {
            [self promptForApiKey];
        }
        
    }
    
    return self;
}

- (void)installCLI {
    NSLog(@"Installing wakatime cli...");
    NSString *script = [NSHomeDirectory() stringByAppendingPathComponent:WAKATIME_INSTALL_SCRIPT];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:script];
    [task setArguments: arguments];
    [task launch];
}

// Read api key from config file
- (NSString *)getApiKey {
    NSString *contents = [NSString stringWithContentsOfFile:CONFIG_FILE encoding:NSUTF8StringEncoding error:nil];[NSString stringWithContentsOfFile:CONFIG_FILE encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\n"];
    for (NSString *s in lines) {
        NSArray *line = [s componentsSeparatedByString:@"="];
        if ([line count] == 2) {
            NSString *key = [[line objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([key isEqualToString:@"api_key"]) {
                NSString *value = [[line objectAtIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@""];
                return value;
            }
        }
    }
    return NULL;
}

// Write api key to config file
- (void)saveApiKey:(NSString *)api_key {
    NSString *contents = [NSString stringWithContentsOfFile:CONFIG_FILE encoding:NSUTF8StringEncoding error:nil];[NSString stringWithContentsOfFile:CONFIG_FILE encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\n"];
    NSMutableArray *new_contents = [NSMutableArray array];
    BOOL found = false;
    for (NSString *s in lines) {
        NSArray *line = [[s stringByReplacingOccurrencesOfString:@" = " withString:@"="] componentsSeparatedByString:@"="];
        if ([line count] == 2) {
            NSString *key = [line objectAtIndex:0];
            if ([key isEqualToString:@"api_key"]) {
                found = true;
                line = @[@"api_key", api_key];
            }
        }
        [new_contents addObject:[line componentsJoinedByString:@" = "]];
    }
    if ([new_contents count] == 0 || !found) {
        [new_contents removeAllObjects];
        [new_contents addObject:@"[settings]"];
        [new_contents addObject:[NSString stringWithFormat:@"api_key = %@", api_key]];
    }
    NSError *error = nil;
    NSString *to_write = [new_contents componentsJoinedByString:@"\n"];
    [to_write writeToFile:CONFIG_FILE atomically:YES encoding:NSASCIIStringEncoding error:&error];
    if (error) {
        NSLog(@"Fail: %@", [error localizedDescription]);
    }
}

// Prompt for api key
- (void)promptForApiKey {
    NSString *api_key = [self getApiKey];
    NSAlert *alert = [NSAlert alertWithMessageText:@"Enter your api key from wakatime.com" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
    if (api_key != NULL) {
        [input setStringValue:api_key];
    }
    [alert setAccessoryView:input];
    [alert runModal];
    api_key = [input stringValue];
    [self saveApiKey:api_key];
}

- (void)dealloc {
    [super dealloc];
}

+ (void)setFileForWindow:(NSString *)filePath forWindow:(int)windowNumber {
    if (filePath != nil) {
        [_windows setObject:filePath forKey:[NSNumber numberWithInt:windowNumber]];
    }
}

+ (NSString*)getFileForWindow:(int)windowNumber {
    return _windows[[NSNumber numberWithInt:windowNumber]];
}

+ (int)totalWindows {
    return [_windows count];
}

+ (void)handleEditorAction:(NSString*)currentFile isWrite:(bool)isWrite {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    if (currentFile && (isWrite || ![_lastFile isEqualToString:currentFile] || _lastTime + FREQUENCY * 60 < currentTime)) {
        _lastFile = currentFile;
        _lastTime = currentTime;
        [self sendHeartbeat:isWrite];
    }
}

+ (void)sendHeartbeat:(bool)isWrite {
    //NSLog(@"%@", _lastFile);
    NSString *cli = [NSHomeDirectory() stringByAppendingPathComponent:WAKATIME_CLI];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/python"];
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:cli];
    //[arguments addObject:@"--verbose"];
    [arguments addObject:@"--file"];
    [arguments addObject:_lastFile];
    [arguments addObject:@"--plugin"];
    [arguments addObject:[NSString stringWithFormat:@"textmate/%@-%@ textmate-wakatime/%@", TEXTMATE_VERSION, TEXTMATE_BUILD, VERSION]];
    if (isWrite)
        [arguments addObject:@"--write"];
    [task setArguments: arguments];
    [task launch];
}
@end
