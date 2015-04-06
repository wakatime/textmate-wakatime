//
//  NSWindow+KKSwizzle.mm
//
//

#import "JRSwizzle.h"
#import "WakaTime.h"


@implementation NSWindow (KKSwizzle)
+ (void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self class] jr_swizzleMethod:@selector(setRepresentedFilename:) withMethod:@selector(xxx_setRepresentedFilename:) error:nil];
        [[self class] jr_swizzleMethod:@selector(becomeMainWindow:) withMethod:@selector(xxx_becomeMainWindow:) error:nil];
        [[self class] jr_swizzleMethod:@selector(sendEvent:) withMethod:@selector(xxx_sendEvent:) error:nil];
        [[self class] jr_swizzleMethod:@selector(setDocumentEdited:) withMethod:@selector(xxx_setDocumentEdited:) error:nil];
    });
}

// called when the user switches tabs (or load files)
- (void)xxx_setRepresentedFilename:(NSString*)aPath {
    //NSLog(@"%s", _cmd);
    [WakaTime setFileForWindow:aPath forWindow:self.windowNumber];
    NSString *file = [WakaTime getFileForWindow:self.windowNumber];
    [WakaTime handleEditorAction:file isWrite:false];
    [self xxx_setRepresentedFilename:aPath];
}

// called when a window is focused
- (void)xxx_becomeMainWindow {
    //NSLog(@"%s", _cmd);
    NSString *file = [WakaTime getFileForWindow:self.windowNumber];
    [WakaTime handleEditorAction:file isWrite:false];
    [self xxx_becomeMainWindow];
}

// called when a key is pressed
- (void)xxx_sendEvent:(NSEvent *)event {
    if (event.type == NSKeyDown) {
        //NSLog(@"%s", _cmd);
        NSString *file = [WakaTime getFileForWindow:self.windowNumber];
        [WakaTime handleEditorAction:file isWrite:false];
    }
    [self xxx_sendEvent:event];
}

// called when a document change state (e.g. when saved to disk)
- (void)xxx_setDocumentEdited:(BOOL)flag {
    //NSLog(@"%s", _cmd);
    NSString *file = [WakaTime getFileForWindow:self.windowNumber];
    bool isWrite = !flag;
    [WakaTime handleEditorAction:file isWrite:isWrite];
    [self xxx_setDocumentEdited:flag];
}
@end
