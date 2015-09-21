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

#import "ASLMessage.h"

@interface ASLMessage()

@property( atomic, readwrite, assign ) NSUInteger pid;
@property( atomic, readwrite, assign ) NSUInteger uid;
@property( atomic, readwrite, assign ) NSUInteger gid;
@property( atomic, readwrite, strong ) NSString * facility;
@property( atomic, readwrite, strong ) NSString * host;
@property( atomic, readwrite, strong ) NSString * sender;
@property( atomic, readwrite, strong ) NSUUID   * senderUUID;
@property( atomic, readwrite, strong ) NSDate   * time;
@property( atomic, readwrite, assign ) NSUInteger level;
@property( atomic, readwrite, strong ) NSString * levelString;
@property( atomic, readwrite, strong ) NSString * message;
@property( atomic, readwrite, assign ) NSUInteger messageID;

- ( NSString * )valueToString:          ( const char * )value;
- ( NSDate   * )valueToDate:            ( const char * )value;
- ( NSUUID   * )valueToUUID:            ( const char * )value;
- ( NSUInteger )valueToUnsignedInteger: ( const char * )value;

@end

@implementation ASLMessage

- ( instancetype )init
{
    return [ self initWithASLMessage: NULL ];
}

- ( instancetype )initWithASLMessage: ( nullable aslmsg )message
{
    if( ( self = [ super init ] ) )
    {
        if( message != NULL )
        {
            self.pid        = [ self valueToUnsignedInteger: asl_get( message, ASL_KEY_PID ) ];
            self.uid        = [ self valueToUnsignedInteger: asl_get( message, ASL_KEY_UID ) ];
            self.gid        = [ self valueToUnsignedInteger: asl_get( message, ASL_KEY_GID ) ];
            self.facility   = [ self valueToString:          asl_get( message, ASL_KEY_FACILITY ) ];
            self.host       = [ self valueToString:          asl_get( message, ASL_KEY_HOST ) ];
            self.sender     = [ self valueToString:          asl_get( message, ASL_KEY_SENDER ) ];
            self.senderUUID = [ self valueToUUID:            asl_get( message, ASL_KEY_SENDER_MACH_UUID ) ];
            self.time       = [ self valueToDate:            asl_get( message, ASL_KEY_TIME ) ];
            self.level      = [ self valueToUnsignedInteger: asl_get( message, ASL_KEY_LEVEL ) ];
            self.message    = [ self valueToString:          asl_get( message, ASL_KEY_MSG ) ];
            self.messageID  = [ self valueToUnsignedInteger: asl_get( message, ASL_KEY_MSG_ID ) ];
            
            switch( self.level )
            {
                case ASL_LEVEL_EMERG:   self.levelString = @"Emergency"; break;
                case ASL_LEVEL_ALERT:   self.levelString = @"Alert";     break;
                case ASL_LEVEL_CRIT:    self.levelString = @"Critical";  break;
                case ASL_LEVEL_ERR:     self.levelString = @"Error";     break;
                case ASL_LEVEL_WARNING: self.levelString = @"Warning";   break;
                case ASL_LEVEL_NOTICE:  self.levelString = @"Notice";    break;
                case ASL_LEVEL_INFO:    self.levelString = @"Info";      break;
                case ASL_LEVEL_DEBUG:   self.levelString = @"Debug";     break;
                default:                self.levelString = @"Unknown";   break;
            }
        }
    }
    
    return self;
}

- ( NSString * )description
{
    NSString * description;
    
    description = [ super description ];
    
    return [ description stringByAppendingFormat: @" %@[ %lu ] - %@: %@", self.sender, self.pid, self.levelString, self.message ];
}

- ( NSString * )valueToString: ( const char * )value
{
    if( value == NULL )
    {
        return @"";
    }
    
    return [ NSString stringWithUTF8String: value ];
}

- ( NSDate * )valueToDate: ( const char * )value
{
    if( value == NULL )
    {
        return nil;
    }
    
    return [ NSDate dateWithTimeIntervalSince1970: ( NSTimeInterval )[ self valueToUnsignedInteger: value ] ];
}

- ( NSUUID * )valueToUUID: ( const char * )value
{
    if( value == NULL )
    {
        return nil;
    }
    
    return [ [ NSUUID alloc ] initWithUUIDString: [ self valueToString: value ] ];
}

- ( NSUInteger )valueToUnsignedInteger: ( const char * )value
{
    if( value == NULL )
    {
        return 0;
    }
    
    return ( NSUInteger )[ NSString stringWithUTF8String: value ].integerValue;
}

@end
