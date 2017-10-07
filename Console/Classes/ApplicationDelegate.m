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

/*!
 * @file        ApplicationDelegate.m
 * @copyright   (c) 2016, Jean-David Gadina - www.xs-labs.com
 */

#import "ApplicationDelegate.h"
#import "Console-Swift.h"
#import "MainWindowController.h"
#import "Preferences.h"
#import "PreferencesWindowController.h"

@interface ApplicationDelegate()

@property( atomic, readwrite, strong ) NSMutableArray              * mainWindowControllers;
@property( atomic, readwrite, strong ) AboutWindowController       * aboutWindowController;
@property( atomic, readwrite, strong ) PreferencesWindowController * preferencesWindowController;

- ( IBAction )newDocument: ( id )sender;

@end

@implementation ApplicationDelegate

- ( void )applicationDidFinishLaunching: ( NSNotification * )notification
{
    ( void )notification;
    
    self.mainWindowControllers = [ NSMutableArray new ];
    
    [ self newDocument: nil ];
    [ Preferences sharedInstance ].lastStart = [ NSDate date ];
}

- ( void )applicationWillTerminate: ( NSNotification * )notification
{
    ( void )notification;
}

- ( BOOL )applicationShouldTerminateAfterLastWindowClosed: ( NSApplication * )sender
{
    ( void )sender;
    
    return NO;
}

- ( IBAction )newDocument: ( nullable id )sender
{
    MainWindowController * controller;
    
    ( void )sender;
    
    controller = [ MainWindowController new ];
    
    if( [ Preferences sharedInstance ].lastStart == nil )
    {
        [ controller.window center ];
    }
    
    [ self.mainWindowControllers addObject: controller ];
    [ controller.window makeKeyAndOrderFront: nil ];
}

- ( IBAction )showAboutWindow: ( id )sender
{
    if( self.aboutWindowController == nil )
    {
        self.aboutWindowController = [ AboutWindowController new ];
        
        [ self.aboutWindowController.window center ];
    }
    
    [ self.aboutWindowController.window makeKeyAndOrderFront: sender ];
}

- ( IBAction )showPreferencesWindow: ( id )sender
{
    if( self.preferencesWindowController == nil )
    {
        self.preferencesWindowController = [ PreferencesWindowController new ];
        
        [ self.preferencesWindowController.window center ];
    }
    
    [ self.preferencesWindowController.window makeKeyAndOrderFront: sender ];
}

@end
