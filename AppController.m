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

#import "AppController.h"

extern double CGSSecondsSinceLastInputEvent(unsigned long eventType);

@interface AppController (Private)
- (void)displayMinutesToNextPause;
- (void)startTimerWithInterval:(int)minutes;
- (void)stopTimer;

@end

@implementation AppController

- (id)init
{
    self = [super init];
    if(self != nil) {
        timer = nil; 
        minutesToNextPause = 0;
        enabled = YES;
        [tapWindowController setDelegate:self];
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)awakeFromNib
{    
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    [statusItem setHighlightMode:YES];
    
    icon = [NSImage imageNamed:@"TAPStatusItemIcon"];
    
    [statusItem setImage:icon];
    
    [statusItem setMenu:menu];
    [statusItem setEnabled:YES];
    
    [minutesToNextPauseMenuItem setEnabled:FALSE];
    
    [self startTimerWithInterval:[standardUserDefaults integerForKey:TAPWorkIntervalKey]];
}

- (IBAction)about:(id)sender
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
    [aboutPanel makeKeyAndOrderFront:nil];
}

- (IBAction)enable:(id)sender
{
    if(enabled == YES) {
        enabled = NO;
        [self stopTimer];
        [enableMenuItem setTitle:@"Enable"];
    }
    else {
        enabled = YES;
        [self startTimerWithInterval:minutesToNextPause];
        [enableMenuItem setTitle:@"Disable"];
    }
    
    [self displayMinutesToNextPause];
}

- (IBAction)preferences:(id)sender
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
    [preferencesController showWindow:self];
}

- (void)startTimerWithInterval:(int)minutes
{
    minutesToNextPause = minutes;
    [self displayMinutesToNextPause];
    timer = [[NSTimer scheduledTimerWithTimeInterval:60
                                             target:self 
                                           selector:@selector(timeout:)
                                           userInfo:nil 
                                            repeats:YES] retain];
}

- (void)stopTimer
{
    [timer invalidate];
    [timer release];
    timer = nil;    
}

- (void)displayMinutesToNextPause
{
    NSString *message;
    
    if(enabled) {
        if(minutesToNextPause == 1) {
            message = [NSString stringWithFormat:@"%d minute to next pause", minutesToNextPause];
        }
        else {
            message = [NSString stringWithFormat:@"%d minutes to next pause", minutesToNextPause];
        }
    }
    else {
        message = @"Take A Pause! is disabled";
    }
    
    [minutesToNextPauseMenuItem setTitle:message];
}

- (void)timeout:(NSTimer *)aTimer
{
    [self setMinutesToNextPause:([self minutesToNextPause] - 1)];
    if([self minutesToNextPause] <= 0) {
        [timer invalidate];
        [timer release];
        timer = nil;
        
        [tapWindowController showWindow:self];
    }
    else {
        int idleTimeInMinutes = (int)(CGSSecondsSinceLastInputEvent(-1) / (double)60.0);
        if(idleTimeInMinutes > ([standardUserDefaults integerForKey:TAPIdleIntervalKey])) {
            if([standardUserDefaults boolForKey:TAPRestartIfIdleKey] == YES) {
                [self setMinutesToNextPause: [standardUserDefaults integerForKey:TAPWorkIntervalKey]];
            }
        }
    }
}

- (void)tapPauseFinishedWithPostpone:(BOOL)postpone
{
    if(postpone == YES) {
        [self startTimerWithInterval:[standardUserDefaults integerForKey:TAPPostponeIntervalKey]];
    }
    else {
        [self startTimerWithInterval:[standardUserDefaults integerForKey:TAPWorkIntervalKey]];
    }
}

- (IBAction)quit:(id)sender
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSApplication sharedApplication] terminate:self];
}

- (int)minutesToNextPause
{
    return minutesToNextPause;
}

- (void)setMinutesToNextPause:(int)minutes
{
    minutesToNextPause = minutes;
    [self displayMinutesToNextPause];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [timer release];
}

- (IBAction)startPauseWithScreenshot:(id)sender
{
    [tapWindowController showWindow:self];
}

@end



