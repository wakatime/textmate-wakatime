//
//  WakaTime.h
//
//

@protocol TMPlugInController
- (float)version;
@end

@interface WakaTime : NSObject {
    NSMutableDictionary* _windows;
    NSString *_lastFile;
    CFAbsoluteTime _lastTime;
}

- (id)initWithPlugInController:(id <TMPlugInController>)aController;
- (void)dealloc;
+ (void)setFileForWindow:(NSString *)filePath forWindow:(int)windowNumber;
+ (NSString*)getFileForWindow:(int)windowNumber;
+ (int)totalWindows;
@end