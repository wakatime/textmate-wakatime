//
//  NSWindow+KKSwizzle.h
//
//

@interface NSWindow (KKSwizzle)

+ (void) load;

// called when the user switches tabs (or load files)
- (void)xxx_setRepresentedFilename:(NSString*)aPath;

// called when a window is focused
- (void)xxx_becomeMainWindow;

// called when a key is pressed
- (void)xxx_sendEvent:(NSEvent *)event;

// called when a document change state (e.g. when saved to disk)
- (void)xxx_setDocumentEdited:(BOOL)flag;

@end
