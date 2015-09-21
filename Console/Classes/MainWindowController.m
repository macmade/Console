/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2015 Jean-David Gadina - www-xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

#import "MainWindowController.h"
#import "ASL.h"

@interface MainWindowController()

@property( atomic, readwrite, strong ) IBOutlet NSArrayController * sendersArrayController;
@property( atomic, readwrite, strong )          ASL               * asl;

@end

@implementation MainWindowController

- ( instancetype )init
{
    return [ self initWithSender: nil ];
}

- ( instancetype )initWithSender: ( NSString * )sender
{
    if( ( self = [ self initWithWindowNibName: NSStringFromClass( self.class ) ] ) )
    {
        self.asl = [ [ ASL alloc ] initWithSender: sender ];
    }
    
    return self;
}

- ( void )windowDidLoad
{
    [ super windowDidLoad ];
    
    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility            = NSWindowTitleHidden;
    
    [ self.asl start ];
    
    self.sendersArrayController.sortDescriptors = @[ [ NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES ] ];
}

@end
