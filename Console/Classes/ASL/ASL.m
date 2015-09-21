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

#import "ASL.h"
#import "ASLMessage.h"
#import "ASLSender.h"
#import <asl.h>

@interface ASL()

@property( atomic, readwrite, strong ) NSArray< ASLMessage * >                                * messages;
@property( atomic, readwrite, strong ) NSDictionary< ASLSender *, NSArray< ASLMessage * > * > * senders;

@property( atomic, readwrite, strong ) NSString * sender;
@property( atomic, readwrite, assign ) BOOL       run;
@property( atomic, readwrite, assign ) BOOL       runing;
@property( atomic, readwrite, assign ) BOOL       exit;

- ( void )processMessages;

@end

@implementation ASL

- ( instancetype )init
{
    return [ self initWithSender: nil ];
}

- ( instancetype )initWithSender: ( nullable NSString * )sender
{
    if( ( self = [ super init ] ) )
    {
        self.sender   = sender;
        self.messages = @[];
        self.senders  = @{};
        
        [ NSThread detachNewThreadSelector: @selector( processMessages ) toTarget: self withObject: nil ];
    }
    
    return self;
}

- ( void )dealloc
{
    self.exit = YES;
    
    while( self.runing );
}

- ( void )start
{
    self.run = YES;
}

- ( void )stop
{
    self.run = NO;
}

- ( void )processMessages
{
    NSUInteger            lastID;
    aslclient             client;
    NSMutableArray      * messages;
    NSMutableDictionary * senders;
    
    @autoreleasepool
    {
        lastID = self.messages.lastObject.messageID;
        client = asl_open( NULL, NULL, 0 );
        
        while( self.exit == NO )
        {
            self.runing = YES;
            
            {
                aslmsg       query;
                aslresponse  response;
                aslmsg       msg;
                ASLMessage * message;
                ASLSender  * sender;
                
                query = asl_new( ASL_TYPE_QUERY );
                
                if( self.sender )
                {
                    asl_set_query( query, ASL_KEY_MSG, self.sender.UTF8String, ASL_QUERY_OP_EQUAL );
                }
                
                asl_set_query( query, ASL_KEY_MSG, NULL, ASL_QUERY_OP_NOT_EQUAL );
                asl_set_query( query, ASL_KEY_MSG_ID, [ NSString stringWithFormat: @"%lu", lastID ].UTF8String, ASL_QUERY_OP_GREATER );
                
                response = asl_search( client, query );
                
                asl_free( query );
                
                msg = aslresponse_next( response );
                
                if( msg != NULL )
                {
                    messages = [ self.messages mutableCopy ];
                    senders  = [ self.senders  mutableCopy ];
                    
                    while( msg )
                    {
                        message = [ [ ASLMessage alloc ] initWithASLMessage: msg ];
                        sender  = [ [ ASLSender alloc ] initWithName: message.sender facility: message.facility ];
                        lastID  = message.messageID;
                        
                        [ messages addObject: message ];
                        
                        if( senders[ message.sender ] == nil )
                        {
                            [ senders setObject: [ NSMutableArray new ] forKey: sender ];
                        }
                        
                        [ ( NSMutableArray * )( senders[ sender ] ) addObject: message ];
                        
                        msg = aslresponse_next( response );
                    }
                    
                    dispatch_sync
                    (
                        dispatch_get_main_queue(),
                        ^( void )
                        {
                            self.messages = [ NSArray arrayWithArray: messages ];
                            self.senders  = [ NSDictionary dictionaryWithDictionary: senders ];
                        }
                    );
                }
                
                aslresponse_free( response );
                
                [ NSThread sleepForTimeInterval: 1 ];
            }
        }
        
        asl_close( client );
        
        self.runing = NO;
    }
}

@end