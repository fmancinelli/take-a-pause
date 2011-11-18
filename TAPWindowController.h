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
#import "PreferencesController.h"
#import "TAPView.h"

@class PreferencesController;

@interface TAPWindowController : NSWindowController
{
    IBOutlet id delegate;
    NSTimer *timer;
    int secondsToPauseEnd;
    IBOutlet TAPView *tapMessageView;
    IBOutlet NSTextField *timerTextField;
    IBOutlet NSButton *postponeButton;
    IBOutlet NSButton *giveUpButton;
    IBOutlet PreferencesController *preferencesController;
    NSUserDefaults *standardUserDefaults;
}

- (id)init;
- (void)setDelegate:(id)aDelegate;
- (IBAction)showWindow:(id)sender;
- (IBAction)postpone:(id)sender;
- (IBAction)giveUp:(id)sender;

@end
