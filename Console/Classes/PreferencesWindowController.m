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

#import "PreferencesWindowController.h"
#import "Preferences.h"

#define HEXCOLOR( c, a ) [ NSColor colorWithDeviceRed: ( ( CGFloat )( ( c >> 16 ) & 0x0000FF ) ) / ( CGFloat )255  \
                                   green:              ( ( CGFloat )( ( c >>  8 ) & 0x0000FF ) ) / ( CGFloat )255  \
                                   blue:               ( ( CGFloat )( ( c       ) & 0x0000FF ) ) / ( CGFloat )255  \
                                   alpha:              ( CGFloat )a                                                \
                         ]

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesWindowController()

@property( atomic, readwrite, strong ) NSString * fontDescription;
@property( atomic, readwrite, strong ) NSColor  * backgroundColor;
@property( atomic, readwrite, strong ) NSColor  * foregroundColor;
@property( atomic, readwrite, assign ) NSInteger  selectedTheme;

- ( IBAction )chooseFont: ( id )sender;
- ( void )changeFont: ( id )sender;

@end

NS_ASSUME_NONNULL_END

@implementation PreferencesWindowController

- ( instancetype )init
{
    return [ self initWithWindowNibName: NSStringFromClass( self.class ) ];
}

- ( void )windowDidLoad
{
    [ super windowDidLoad ];
    
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( fontName ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    [ [ Preferences sharedInstance ] addObserver: self forKeyPath: NSStringFromSelector( @selector( fontSize ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    
    [ self addObserver: self forKeyPath: NSStringFromSelector( @selector( backgroundColor ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    [ self addObserver: self forKeyPath: NSStringFromSelector( @selector( foregroundColor ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    [ self addObserver: self forKeyPath: NSStringFromSelector( @selector( selectedTheme   ) ) options: NSKeyValueObservingOptionNew context: NULL ];
    
    self.fontDescription = [ NSString stringWithFormat: @"%@ %.0f", [ Preferences sharedInstance ].fontName, [ Preferences sharedInstance ].fontSize ];
    self.backgroundColor = [ NSColor colorWithDeviceRed: [ Preferences sharedInstance ].backgroundColorR green: [ Preferences sharedInstance ].backgroundColorG blue: [ Preferences sharedInstance ].backgroundColorB alpha: 1.0 ];
    self.foregroundColor = [ NSColor colorWithDeviceRed: [ Preferences sharedInstance ].foregroundColorR green: [ Preferences sharedInstance ].foregroundColorG blue: [ Preferences sharedInstance ].foregroundColorB alpha: 1.0 ];
}

- ( void )dealloc
{
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( fontName ) ) ];
    [ [ Preferences sharedInstance ] removeObserver: self forKeyPath: NSStringFromSelector( @selector( fontSize ) ) ];
    
    [ self removeObserver: self forKeyPath: NSStringFromSelector( @selector( backgroundColor ) ) ];
    [ self removeObserver: self forKeyPath: NSStringFromSelector( @selector( foregroundColor ) ) ];
    [ self removeObserver: self forKeyPath: NSStringFromSelector( @selector( selectedTheme ) ) ];
}

- ( void )observeValueForKeyPath: ( NSString * )keyPath ofObject: ( id )object change: ( NSDictionary * )change context: ( void * )context
{
    if
    (
        object == [ Preferences sharedInstance ]
        &&
        (
               [ keyPath isEqualToString: NSStringFromSelector( @selector( fontName ) ) ]
            || [ keyPath isEqualToString: NSStringFromSelector( @selector( fontSize ) ) ]
        )
    )
    {
        self.fontDescription = [ NSString stringWithFormat: @"%@ %.0f", [ Preferences sharedInstance ].fontName, [ Preferences sharedInstance ].fontSize ];
    }
    else if( object == self && [ keyPath isEqualToString: NSStringFromSelector( @selector( selectedTheme ) ) ] )
    {
        switch( self.selectedTheme )
        {
            case 1:
                
                self.backgroundColor = HEXCOLOR( 0xFFFFFF, 1.0 );
                self.foregroundColor = HEXCOLOR( 0x000000, 1.0 );
                
                break;
                
            case 2:
                
                self.backgroundColor = HEXCOLOR( 0x000000, 1.0 );
                self.foregroundColor = HEXCOLOR( 0xFFFFFF, 1.0 );
                
                break;
                
            case 3:
                
                self.backgroundColor = HEXCOLOR( 0xFFFCE5, 1.0 );
                self.foregroundColor = HEXCOLOR( 0xC3741C, 1.0 );
                
                break;
                
            case 4:
                
                self.backgroundColor = HEXCOLOR( 0x161A1D, 1.0 );
                self.foregroundColor = HEXCOLOR( 0xBFBFBF, 1.0 );
                
                break;
                
            default:
                
                break;
        }
    }
    else if( object == self && [ keyPath isEqualToString: NSStringFromSelector( @selector( backgroundColor ) ) ] )
    {
        {
            CGFloat r;
            CGFloat g;
            CGFloat b;
            
            [ [ self.backgroundColor colorUsingColorSpaceName: NSDeviceRGBColorSpace ] getRed: &r green: &g blue: &b alpha: NULL ];
            
            [ Preferences sharedInstance ].backgroundColorR = r;
            [ Preferences sharedInstance ].backgroundColorG = g;
            [ Preferences sharedInstance ].backgroundColorB = b;
        }
    }
    else if( object == self && [ keyPath isEqualToString: NSStringFromSelector( @selector( foregroundColor ) ) ] )
    {
        {
            CGFloat r;
            CGFloat g;
            CGFloat b;
            
            [ [ self.foregroundColor colorUsingColorSpaceName: NSDeviceRGBColorSpace ] getRed: &r green: &g blue: &b alpha: NULL ];
            
            [ Preferences sharedInstance ].foregroundColorR = r;
            [ Preferences sharedInstance ].foregroundColorG = g;
            [ Preferences sharedInstance ].foregroundColorB = b;
        }
    }
    else
    {
        [ super observeValueForKeyPath: keyPath ofObject: object change: change context: context ];
    }
}

- ( IBAction )chooseFont: ( id )sender
{
    NSFontManager * manager;
    NSFontPanel   * panel;
    NSFont        * font;
    
    font    = [ NSFont fontWithName: [ Preferences sharedInstance ].fontName size: [ Preferences sharedInstance ].fontSize ];
    manager = [ NSFontManager sharedFontManager ];
    panel   = [ manager fontPanel: YES ];
    
    [ manager setSelectedFont: font isMultiple: NO ];
    [ panel makeKeyAndOrderFront: sender ];
}

- ( void )changeFont: ( id )sender
{
    NSFontManager * manager;
    NSFont        * font;
    
    if( [ sender isKindOfClass: [ NSFontManager class ] ] == NO )
    {
        return;
    }
    
    manager = ( NSFontManager * )sender;
    font    = [ manager convertFont: [ manager selectedFont ] ];
    
    [ Preferences sharedInstance ].fontName = font.fontName;
    [ Preferences sharedInstance ].fontSize = font.pointSize;
}

@end
