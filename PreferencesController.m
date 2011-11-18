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

#import "PreferencesController.h"

NSString *TAPWorkIntervalKey = @"WorkInterval";
NSString *TAPPauseIntervalKey = @"PauseInterval";
NSString *TAPPostponeEnabledKey = @"PostponeEnabled";
NSString *TAPPostponeIntervalKey = @"PostponeInterval";
NSString *TAPGiveUpEnabledKey = @"GiveUpEnabled";
NSString *TAPRestartIfIdleKey = @"RestartIfIdle";
NSString *TAPIdleIntervalKey = @"IdleInterval";
NSString *TAPMetalGradientLookKey = @"MetalGradientLook";

@implementation PreferencesController

- (id)init{
    self = [super init];
    
    if(self != nil) {
        NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
        [defaultValues setObject:[NSNumber numberWithInt:50] forKey:TAPWorkIntervalKey];
        [defaultValues setObject:[NSNumber numberWithInt:10] forKey:TAPPauseIntervalKey];
        [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TAPPostponeEnabledKey];
        [defaultValues setObject:[NSNumber numberWithInt:5] forKey:TAPPostponeIntervalKey];
        [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TAPGiveUpEnabledKey];
        [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TAPRestartIfIdleKey];
        [defaultValues setObject:[NSNumber numberWithInt:20] forKey:TAPIdleIntervalKey];   
        [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TAPMetalGradientLookKey];   
        
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults registerDefaults:defaultValues];
        
        itemsList = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)awakeFromNib
{
    toolbar = [[[NSToolbar alloc] initWithIdentifier:@"preferences"] autorelease];
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setAutosavesConfiguration: NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setDelegate:self];

    int i;
    
    for(i = 0; i < [tabView numberOfTabViewItems]; i++) {
        [itemsList setObject:[[tabView tabViewItemAtIndex:i] label]
                      forKey:[[tabView tabViewItemAtIndex:i] identifier]];
    }

    [[self window] setToolbar:toolbar];
    
    if([toolbar selectedItemIdentifier] == nil) {
        [toolbar setSelectedItemIdentifier:[[tabView tabViewItemAtIndex:0] identifier]];
    } 
    
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
    NSString *itemLabel = [itemsList objectForKey:itemIdentifier];
    
    if(itemLabel != nil) {
        [toolbarItem setLabel: itemLabel];
		[toolbarItem setPaletteLabel: itemLabel];
		[toolbarItem setTag:[tabView indexOfTabViewItemWithIdentifier:itemIdentifier]];
		[toolbarItem setToolTip: itemLabel];
		[toolbarItem setImage: [NSImage imageNamed:itemIdentifier]];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(select:)];
    }
	else
	{
		toolbarItem = nil;
    }
    
    return toolbarItem;
}

-(IBAction)select:(id)sender
{
    [tabView selectTabViewItemAtIndex:[sender tag]];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [itemsList allKeys];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    int i;
    NSMutableArray *itemIdentifiers = [NSMutableArray array];
    
    for(i = 0; i < [tabView numberOfTabViewItems]; i++){
        [itemIdentifiers addObject:[[tabView tabViewItemAtIndex:i] identifier]];
    }
    
    return itemIdentifiers;
}

-(NSArray*) toolbarSelectableItemIdentifiers: (NSToolbar*)toolbar
{
	return [itemsList allKeys];
}

- (void)dealloc
{
    [itemsList release];
    [super dealloc];
}

@end
