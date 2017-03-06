/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2015 Jean-David Gadina - www.xs-labs.com
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

#import "Preferences.h"

@import ObjectiveC.runtime;

NS_ASSUME_NONNULL_BEGIN

@interface Preferences()

@property( atomic, readwrite, assign ) BOOL                    inited;
@property( atomic, readwrite, strong ) NSArray< NSString * > * properties;

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
            instance = [ [ super allocWithZone: nil ] init ];
        }
    );
    
    return instance;
}

+ ( instancetype )allocWithZone: ( struct _NSZone * )zone
{
    ( void )zone;
    
    return [ self sharedInstance ];
}

- ( instancetype )init
{
    if( self.inited )
    {
        return self;
    }
    
    if( ( self = [ super init ] ) )
    {
        self.inited = YES;
        
        [ [ NSUserDefaults standardUserDefaults ] registerDefaults: [ NSDictionary dictionaryWithContentsOfFile: [ [ NSBundle mainBundle ] pathForResource: @"Defaults" ofType: @"plist" ] ] ];
        
        {
            unsigned int                   i;
            objc_property_t              * list;
            NSString                     * name;
            NSMutableArray< NSString * > * properties;
            
            properties = [ NSMutableArray new ];
            list       = class_copyPropertyList( self.class, &i );
            
            if( list )
            {
                while( i )
                {
                    name = [ NSString stringWithUTF8String: property_getName( list[ --i ] ) ];
                    
                    if( name == nil || name.length == 0 )
                    {
                        continue;
                    }
                    
                    if( [ name isEqualToString: @"inited" ] || [ name isEqualToString: @"properties" ] )
                    {
                        continue;
                    }
                    
                    [ properties addObject: name ];
                    [ self setValue: [ [ NSUserDefaults standardUserDefaults ] objectForKey: name ] forKey: name ];
                    [ self addObserver: self forKeyPath: name options: NSKeyValueObservingOptionNew context: NULL ];
                }
            }
            
            self.properties = [ NSArray arrayWithArray: properties ];
            
            free( list );
        }
    }
    
    return self;
}

- ( void )dealloc
{
    for( NSString * p in self.properties )
    {
        [ self removeObserver: self forKeyPath: p ];
    }
}

- ( void )observeValueForKeyPath: ( NSString * )keyPath ofObject: ( id )object change: ( NSDictionary * )change context: ( void * )context
{
    if( object == self && [ self.properties containsObject: keyPath ] )
    {
        [ [ NSUserDefaults standardUserDefaults ] setObject: [ self valueForKey: keyPath ] forKey: keyPath ];
        [ [ NSUserDefaults standardUserDefaults ] synchronize ];
    }
    else
    {
        [ super observeValueForKeyPath: keyPath ofObject: object change: change context: context ];
    }
}

@end
