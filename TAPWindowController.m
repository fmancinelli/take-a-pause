/* Take A Pause!
 * Copyright (C) 2007, Fabio Mancinelli <fm@fabiomancinelli.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#import "TAPWindowController.h"

extern CGImageRef grabViaOpenGL(CGDirectDisplayID display, CGRect srcRect);

@interface TAPWindowController (Private)

- (void)updateTimer;
- (void)finishWithPostpone:(BOOL)postpone;
- (NSImage *)imageFromCGImageRef:(CGImageRef)img;
- (NSImage *)grabScreenshot;

@end

@implementation TAPWindowController

- init
{
    self = [super init];
    if(self != nil) {
        delegate = nil;
        timer = nil;
        
        /* This is the window associated with this window controller.
           It is a borderless window and we will use it to cover the full-screen area.
           The dimensions are not important here. They will be set correctly before displaying it in the
           showWindow method. */ 
        NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 800.0, 600.0) 
                                                       styleMask:NSBorderlessWindowMask
                                                         backing:NSBackingStoreBuffered 
                                                           defer:NO 
                                                          screen:[NSScreen mainScreen]];
        [self setWindow:window];
        
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [[self window] setContentView:tapMessageView];
}

- (void)setDelegate:(id)aDelegate
{
    delegate = aDelegate;
}

- (void)showWindow:(id)sender
{
    
    if([standardUserDefaults boolForKey:TAPMetalGradientLookKey] == YES) {
        [tapMessageView setBackgroundImage:nil];
    }
    else {
        NSImage *screenshot = [self grabScreenshot];
        [tapMessageView setBackgroundImage:screenshot];
    }
    
    if (CGDisplayCapture( kCGDirectMainDisplay ) != kCGErrorSuccess) {
        NSLog( @"Couldn't capture the main display!" );
    }
    
    int windowLevel = CGShieldingWindowLevel();
    NSRect screenRect = [[NSScreen mainScreen] frame];

    
    
    [postponeButton setEnabled:[standardUserDefaults boolForKey:TAPPostponeEnabledKey]];
    [giveUpButton setEnabled:[standardUserDefaults boolForKey:TAPGiveUpEnabledKey]];
    
    [[self window] setFrame:screenRect display:YES];
    [[self window] setLevel:windowLevel];
    [[self window] setBackgroundColor:[NSColor grayColor]];
    [[self window] makeKeyAndOrderFront:nil];
    
    
    
    secondsToPauseEnd = [standardUserDefaults integerForKey:TAPPauseIntervalKey] * 60;
    timer = [[NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self 
                                           selector:@selector(timeout:)
                                           userInfo:nil 
                                            repeats:YES] retain];
    [self updateTimer];
    
}

- (void)updateTimer
{
    NSString *timerString = [NSString stringWithFormat:@"%02d:%02d", (secondsToPauseEnd / 60), (secondsToPauseEnd % 60)];
    [timerTextField setStringValue:timerString];    
}

- (IBAction)postpone:(id)sender
{
    [self finishWithPostpone:YES];
}

- (IBAction)giveUp:(id)sender
{
    [self finishWithPostpone:NO];
}

- (void)finishWithPostpone:(BOOL)postpone
{
    [timer invalidate];
    [timer release];
    
    // Release the display(s)
    if (CGDisplayRelease( kCGDirectMainDisplay ) != kCGErrorSuccess) {
        NSLog( @"Couldn't release the display(s)!" );
        // Note: if you display an error dialog here, make sure you set
        // its window level to the same one as the shield window level,
        // or the user won't see anything.
    }
    
    [[self window] orderOut:self];
    
    if([delegate respondsToSelector:@selector(tapPauseFinishedWithPostpone:)]) {
        [delegate tapPauseFinishedWithPostpone:postpone];
    }
    
}

- (void)timeout:(NSTimer *)aTimer
{
    secondsToPauseEnd--;
    
    if(secondsToPauseEnd > 0) {
        [self updateTimer];
    }
    else {
        [self finishWithPostpone:NO];
    }
}

- (NSImage *)grabScreenshot
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    
    CGRect grabRect;
    grabRect.origin.x = screenRect.origin.x;
    grabRect.origin.y = screenRect.origin.y;
    grabRect.size.width = screenRect.size.width;
    grabRect.size.height = screenRect.size.height;
    
    NSImage *screenshot = [self imageFromCGImageRef:grabViaOpenGL(kCGDirectMainDisplay, grabRect)];
    
    return screenshot;
    
}

// Taken from http://developer.apple.com/documentation/Cocoa/Conceptual/CocoaDrawingGuide/Images/chapter_7_section_6.html
- (NSImage *)imageFromCGImageRef:(CGImageRef)img
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage *newImage = nil;
    
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(img);
    imageRect.size.width = CGImageGetWidth(img);
    
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size]; 
    [newImage lockFocus];
    
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, img);
    [newImage unlockFocus];
    
    return newImage;
}

@end
