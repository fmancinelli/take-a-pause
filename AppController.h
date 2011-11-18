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

#import <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>
#import "TAPWindowController.h"
#import "PreferencesController.h"

@class PreferencesController;
@class TAPWindowController;

@interface AppController : NSObject
{
	NSStatusItem *statusItem;
	NSImage *icon;
	IBOutlet NSMenu *menu;
	IBOutlet NSMenuItem *enableMenuItem;
    NSTimer *timer;
    IBOutlet TAPWindowController *tapWindowController;
    IBOutlet NSPanel *aboutPanel;
    IBOutlet PreferencesController *preferencesController;
    IBOutlet NSMenuItem *minutesToNextPauseMenuItem;
    int minutesToNextPause;
    BOOL enabled;
    NSUserDefaults *standardUserDefaults;
}

- (IBAction)about:(id)sender;
- (IBAction)enable:(id)sender;
- (IBAction)preferences:(id)sender;
- (IBAction)quit:(id)sender;
- (int)minutesToNextPause;
- (void)setMinutesToNextPause:(int)minutes;
- (void)tapPauseFinishedWithPostpone:(BOOL)postpone;

/* Testing methods */
- (IBAction)startPauseWithScreenshot:(id)sender;
@end
