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
 * @file        MainWindowController.m
 * @copyright   (c) 2016, Jean-David Gadina - www.xs-labs.com
 */

#import "MainWindowController.h"
#import "ASL.h"
#import "ASLSender.h"
#import "Preferences.h"

@interface MainWindowController() < NSTableViewDataSource >

@property( atomic, readwrite, strong ) IBOutlet NSArrayController  * sendersArrayController;
@property( atomic, readwrite, strong ) IBOutlet NSArrayController  * messagesArrayController;
@property( atomic, readwrite, strong ) IBOutlet NSTextView         * textView;
@property( atomic, readwrite, strong ) IBOutlet NSView             * textViewContainer;
@property( atomic, readwrite, strong )          ASL                * asl;
@property( atomic, readwrite, strong )          NSLayoutConstraint * textViewContainerHiddenConstraint;
@property( atomic, readwrite, strong )          NSLayoutConstraint * textViewContainerVisibleConstraint;

- ( void )updateDisplaySettings;
- ( IBAction )clearAllMessages: ( nullable id )sender;

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

- ( void )dealloc
{
    [ self.sendersArrayController  removeObserver: self forKeyPath: NSStringFromSelector( @selector( selection ) ) ];
    [ self.messagesArrayController removeObserver: self forKeyPath: NSStringFromSelector( @selector( selection ) ) ];
    
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( fontName ) ) ];
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( fontSize ) ) ];
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( backgroundColorR ) ) ];
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( backgroundColorG ) ) ];
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( backgroundColorB ) ) ];
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( foregroundColorR ) ) ];
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( foregroundColorG ) ) ];
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( foregroundColorB ) ) ];
}

- ( void )windowDidLoad
{
    [ super windowDidLoad ];
    
    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility            = NSWindowTitleHidden;
    
    [ self.asl start ];
    
    self.sendersArrayController.sortDescriptors  = @[ [ NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES selector: @selector( localizedCaseInsensitiveCompare: ) ] ];
    self.messagesArrayController.sortDescriptors = @[ [ NSSortDescriptor sortDescriptorWithKey: @"time" ascending: NO  ] ];
    
    [ self.asl                     addObserver: self forKeyPath: NSStringFromSelector( @selector( messages ) )  options: NSKeyValueObservingOptionNew context: NULL ];
    [ self.sendersArrayController  addObserver: self forKeyPath: NSStringFromSelector( @selector( selection ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    [ self.messagesArrayController addObserver: self forKeyPath: NSStringFromSelector( @selector( selection ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    
    self.messagesArrayController.content = self.asl.messages;
    self.textView.textContainerInset     = NSMakeSize( 10.0, 15.0 );
    
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( fontName ) )         options: NSKeyValueObservingOptionNew context: NULL ];
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( fontSize ) )         options: NSKeyValueObservingOptionNew context: NULL ];
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( backgroundColorR ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( backgroundColorG ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( backgroundColorB ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( foregroundColorR ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( foregroundColorG ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( foregroundColorB ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    
    [ self updateDisplaySettings ];
    
    {
        NSPredicate        * predicate;
        NSArray            * constraints;
        NSLayoutConstraint * constraint;
        
        predicate                               = [ NSPredicate predicateWithFormat: @"firstAttribute = %d", NSLayoutAttributeHeight ];
        constraints                             = [ self.textViewContainer.constraints filteredArrayUsingPredicate: predicate ];
        constraint                              = constraints.firstObject;
        constraint.active                       = NO;
        self.textViewContainerVisibleConstraint = constraint;
        
        if( constraint )
        {
            self.textViewContainerHiddenConstraint = [ NSLayoutConstraint constraintWithItem: self.textViewContainer attribute: NSLayoutAttributeHeight relatedBy: NSLayoutRelationEqual toItem: nil attribute: NSLayoutAttributeHeight multiplier: 0.0 constant: 0.0 ];
            
            [ self.textViewContainer addConstraint: self.textViewContainerHiddenConstraint ];
        }
    }
}

- ( void )observeValueForKeyPath: ( NSString * )keyPath ofObject: ( id )object change: ( NSDictionary< NSString *, id > * )change context: ( void * )context
{
    if
    (
        object == [ Preferences sharedInstance ]
        &&
        (
               [ keyPath isEqualToString: NSStringFromSelector( @selector( fontName ) ) ]
            || [ keyPath isEqualToString: NSStringFromSelector( @selector( fontSize ) ) ]
            || [ keyPath isEqualToString: NSStringFromSelector( @selector( backgroundColorR ) ) ]
            || [ keyPath isEqualToString: NSStringFromSelector( @selector( backgroundColorG ) ) ]
            || [ keyPath isEqualToString: NSStringFromSelector( @selector( backgroundColorB ) ) ]
            || [ keyPath isEqualToString: NSStringFromSelector( @selector( foregroundColorR ) ) ]
            || [ keyPath isEqualToString: NSStringFromSelector( @selector( foregroundColorG ) ) ]
            || [ keyPath isEqualToString: NSStringFromSelector( @selector( foregroundColorB ) ) ]
        )
    )
    {
        [ self updateDisplaySettings ];
    }
    else if( object == self.sendersArrayController && [ keyPath isEqualToString: NSStringFromSelector( @selector( selection ) ) ] )
    {
        if( self.sendersArrayController.selectionIndexes.count == 0 )
        {
            self.messagesArrayController.content = self.asl.messages;
        }
        else
        {
            self.messagesArrayController.content = [ self.sendersArrayController valueForKeyPath: @"selection.@unionOfArrays.messages" ];
        }
    }
    else if( object == self.messagesArrayController && [ keyPath isEqualToString: NSStringFromSelector( @selector( selection ) ) ] )
    {
        if( self.messagesArrayController.selectionIndexes.count != 1 )
        {
            self.textViewContainerVisibleConstraint.active = NO;
            self.textViewContainerHiddenConstraint.active  = YES;
        }
        else
        {
            self.textViewContainerHiddenConstraint.active  = NO;
            self.textViewContainerVisibleConstraint.active = YES;
        }
    }
    else if( object == self.asl && [ keyPath isEqualToString: NSStringFromSelector( @selector( messages ) ) ] )
    {
        if( self.sendersArrayController.selectedObjects.count == 0 )
        {
            self.messagesArrayController.content = self.asl.messages;
        }
        else
        {
            self.messagesArrayController.content = [ self.sendersArrayController valueForKeyPath: @"selection.@unionOfArrays.messages" ];
        }
    }
    else
    {
        [ super observeValueForKeyPath: keyPath ofObject: object change: change context: context ];
    }
}

- ( IBAction )clearAllMessages: ( nullable id )sender
{
    NSArray< ASLSender * > * senders;
    ASLSender              * s;
    
    ( void )sender;
    
    if( self.sendersArrayController.selectedObjects.count )
    {
        senders = self.sendersArrayController.selectedObjects;
    }
    else
    {
        senders = self.sendersArrayController.arrangedObjects;
    }
    
    for( s in senders )
    {
        [ s clear ];
    }
}

- ( void )updateDisplaySettings
{
    NSString * fontName;
    NSFont   * font;
    NSColor  * background;
    NSColor  * foreground;
    
    fontName = [ Preferences sharedInstance ].fontName;
    font     = nil;
    
    if( fontName.length > 0 )
    {
        font = [ NSFont fontWithName: fontName size: [ Preferences sharedInstance ].fontSize ];
    }
    
    if( font == nil )
    {
        font = [ NSFont fontWithName: @"Consolas" size: [ Preferences sharedInstance ].fontSize ];
    }
    
    if( font == nil )
    {
        font = [ NSFont fontWithName: @"Menlo" size: [ Preferences sharedInstance ].fontSize ];
    }
    
    if( font == nil )
    {
        font = [ NSFont fontWithName: @"Monaco" size: [ Preferences sharedInstance ].fontSize ];
    }
    
    if( font == nil )
    {
        font = [ NSFont systemFontOfSize: [ Preferences sharedInstance ].fontSize ];
    }
    
    if( font != nil )
    {
        self.textView.font = font;
    }
    
    background = [ NSColor colorWithDeviceRed: [ Preferences sharedInstance ].backgroundColorR green: [ Preferences sharedInstance ].backgroundColorG blue: [ Preferences sharedInstance ].backgroundColorB alpha: 1.0 ];
    foreground = [ NSColor colorWithDeviceRed: [ Preferences sharedInstance ].foregroundColorR green: [ Preferences sharedInstance ].foregroundColorG blue: [ Preferences sharedInstance ].foregroundColorB alpha: 1.0 ];
    
    self.textView.backgroundColor = background;
    self.textView.textColor       = foreground;
}

#pragma mark - NSTableViewDataSource

- ( BOOL )tableView: ( NSTableView * )tableView writeRowsWithIndexes: ( NSIndexSet * )rowIndexes toPasteboard: ( NSPasteboard * )pasteboard
{
    ASLMessage                   * message;
    NSArray< ASLMessage * >      * messages;
    NSMutableArray< NSString * > * contents;
    
    [ tableView setDraggingSourceOperationMask: NSDragOperationCopy forLocal: NO ];
    
    messages = [ self.messagesArrayController.arrangedObjects objectsAtIndexes: rowIndexes ];
    contents = [ NSMutableArray new ];
    
    for( message in messages )
    {
        [ contents addObject: message.message ];
    }
    
    if( contents.count )
    {
        [ pasteboard setString: [ contents componentsJoinedByString: @"\n\n--------------------------------------------------------------------------------\n\n" ] forType: NSStringPboardType ];
        
        return YES;
    }
    
    return NO;
}

@end
