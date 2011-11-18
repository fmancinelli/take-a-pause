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

#import "TAPView.h"
#import "CTGradient.h"

@implementation TAPView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        backgroundImage = nil;
    }
    return self;
}

- (void)setBackgroundImage:(NSImage *)image
{
    if(image == nil) {
        [backgroundImage release];
        backgroundImage = nil;
    }
    else {
        if(image != backgroundImage) {
            [backgroundImage release];
            backgroundImage = [image retain];
        }
    }
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
    if(backgroundImage == nil) {
        NSColor *beginColor = [NSColor whiteColor];
        NSColor *endColor = [NSColor grayColor];
        CTGradient *gradient = [CTGradient gradientWithBeginningColor:beginColor
                                                          endingColor:endColor];
        [gradient fillRect:[self bounds] angle:270];
    }
    else {                
        [backgroundImage drawInRect:rect 
                           fromRect:rect
                          operation:NSCompositeCopy 
                           fraction:0.7];
    }
}

@end
