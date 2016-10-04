/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2016 Jean-David Gadina - www.xs-labs.com
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
 * @file        Preferences.m
 * @copyright   (c) 2016, Jean-David Gadina - www.xs-labs.com
 */

#import "Preferences.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const PreferencesNotificationDefaultsChanged = @"PreferencesNotificationDefaultsChanged";
NSString * const PreferencesKeyFirstLaunch              = @"FirstLaunch";

@interface Preferences()

@property( atomic, readwrite, strong ) NSUserDefaults * defaults;

- ( void )synchronizeDefaultsAndNotifyForKey: ( NSString * )key;
- ( NSString * )propertyNameFromSetter: ( SEL )setter;

@end

NS_ASSUME_NONNULL_END

@implementation Preferences

+ ( instancetype )sharedInstance
{
    static dispatch_once_t once;
    static id              instance = nil;
    
    dispatch_once
    (
        &once,
        ^( void )
        {
            instance = [ self new ];
        }
    );
    
    return instance;
}

- ( instancetype )init
{
    NSString     * path;
    NSDictionary * defaults;
    
    if( ( self = [ super init ] ) )
    {
        path          = [ [ NSBundle mainBundle ] pathForResource: @"Defaults" ofType: @"plist" ];
        defaults      = [ NSDictionary dictionaryWithContentsOfFile: path ];
        self.defaults = [ NSUserDefaults standardUserDefaults ];
        
        [ self.defaults registerDefaults: defaults ];
    }
    
    return self;
}

- ( instancetype )initWithCoder: ( NSCoder * )coder
{
    ( void )coder;
    
    /*
     * Because we use the Preferences object in XIB files, so we can use bindings.
     * This way, even when instanciated through an XIB file, we provide the
     * same unique instance.
     */
    return [ [ self class ] sharedInstance ];
}

- ( void )synchronizeDefaultsAndNotifyForKey: ( NSString * )key
{
    [ self.defaults synchronize ];
    [ [ NSNotificationCenter defaultCenter ] postNotificationName: PreferencesNotificationDefaultsChanged object: key userInfo: nil ];
}

- ( NSString * )propertyNameFromSetter: ( SEL )setter
{
    NSString * set;
    NSString * name;
    
    if( setter == nil )
    {
        return @"";
    }
    
    set = NSStringFromSelector( setter );
    
    if( [ set hasPrefix: @"set" ] && [ set hasSuffix: @":" ] )
    {
        name = [ set substringFromIndex: 4 ];
        name = [ name substringToIndex: name.length - 1 ];
        name = [ [ set substringWithRange: NSMakeRange( 3, 1 ) ].lowercaseString stringByAppendingString: name ];
    }
    
    if( name == nil )
    {
        return @"";
    }
    
    return name;
}

- ( BOOL )firstLaunch
{
    @synchronized( self )
    {
        return [ self.defaults boolForKey: PreferencesKeyFirstLaunch ];
    }
}

- ( void )setFirstLaunch: ( BOOL )value
{
    @synchronized( self )
    {
        [ self willChangeValueForKey: [ self propertyNameFromSetter: _cmd ] ];
        [ self.defaults setBool: value forKey: PreferencesKeyFirstLaunch ];
        [ self synchronizeDefaultsAndNotifyForKey: PreferencesKeyFirstLaunch ];
        [ self didChangeValueForKey: [ self propertyNameFromSetter: _cmd ] ];
    }
}

@end
