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
 * @file        ASLSender.m
 * @copyright   (c) 2016, Jean-David Gadina - www.xs-labs.com
 */

#import "ASLSender.h"

@interface ASLSender()

@property( atomic, readwrite, strong ) NSString                       * name;
@property( atomic, readwrite, strong ) NSString                       * facility;
@property( atomic, readwrite, strong ) NSImage                        * icon;
@property( atomic, readwrite, strong ) NSArray< ASLMessage * >        * messages;
@property( atomic, readwrite, strong ) NSMutableArray< ASLMessage * > * messagesMutable;

@end

@implementation ASLSender

- ( instancetype )init
{
    return [ self initWithName: @"" facility: @"" ];
}

- ( instancetype )initWithName: ( NSString * )name facility: ( NSString * )facility
{
    if( ( self = [ super init ] ) )
    {
        self.name            = name;
        self.facility        = facility;
        self.messagesMutable = [ NSMutableArray new ];
        self.messages        = @[];
        
        {
            NSString                      * apps;
            NSString                      * userApps;
            NSString                      * path;
            NSMutableArray<  NSString * > * paths;
            
            paths    = [ NSMutableArray new ];
            apps     = NSSearchPathForDirectoriesInDomains( NSApplicationDirectory, NSLocalDomainMask, YES ).firstObject;
            userApps = NSSearchPathForDirectoriesInDomains( NSApplicationDirectory, NSUserDomainMask,  YES ).firstObject;
            
            if( apps )
            {
                [ paths addObject: [ apps stringByAppendingPathComponent: [ NSString stringWithFormat: @"%@.app", self.name ] ] ];
            }
            
            if( userApps )
            {
                [ paths addObject: [ userApps stringByAppendingPathComponent: [ NSString stringWithFormat: @"%@.app", self.name ] ] ];
            }
            
            [ paths addObject: [ NSString stringWithFormat: @"/bin/%@",               self.name ] ];
            [ paths addObject: [ NSString stringWithFormat: @"/sbin/%@",              self.name ] ];
            [ paths addObject: [ NSString stringWithFormat: @"/usr/bin/%@",           self.name ] ];
            [ paths addObject: [ NSString stringWithFormat: @"/usr/sbin/%@",          self.name ] ];
            [ paths addObject: [ NSString stringWithFormat: @"/usr/libexec/%@",       self.name ] ];
            [ paths addObject: [ NSString stringWithFormat: @"/usr/local/bin/%@",     self.name ] ];
            [ paths addObject: [ NSString stringWithFormat: @"/usr/local/sbin/%@",    self.name ] ];
            [ paths addObject: [ NSString stringWithFormat: @"/usr/local/libexec/%@", self.name ] ];
            
            for( path in paths )
            {
                if( [ [ NSFileManager defaultManager ] fileExistsAtPath: path ] )
                {
                    self.icon = [ [ NSWorkspace sharedWorkspace ] iconForFile: path ];
                    
                    break;
                }
            }
            
            if( self.icon == nil )
            {
                self.icon = [ [ NSWorkspace sharedWorkspace ] iconForFile: @"/bin/ls" ];
            }
        }
    }
    
    return self;
}

- ( instancetype )copyWithZone: ( NSZone * )zone
{
    return [ [ ASLSender allocWithZone: zone ] initWithName: self.name facility: self.facility ];
}

- ( BOOL )isEqualToASLSender: ( ASLSender * )sender
{
    if( [ sender isKindOfClass: [ ASLSender class ] ] == NO )
    {
        return NO;
    }
    
    if( [ self.name isEqualToString: sender.name ] == NO )
    {
        return NO;
    }
    
    if( [ self.facility isEqualToString: sender.facility ] == NO )
    {
        return NO;
    }
    
    return YES;
}

- ( BOOL )isEqual: ( id )object
{
    if( object == self )
    {
        return YES;
    }
    
    if( [ object isKindOfClass: [ ASLSender class ] ] == NO )
    {
        return NO;
    }
    
    return [ self isEqualToASLSender: ( ASLSender * )object ];
}

- ( BOOL )isEqualTo: ( id )object
{
    return [ self.name isEqualTo: object ];
}

- ( NSUInteger )hash
{
    return [ self.name stringByAppendingString: self.facility ].hash;
}

- ( void )addMessage: ( ASLMessage * )message
{
    [ self.messagesMutable addObject: message ];
    
    self.messages = self.messagesMutable;
}

@end
