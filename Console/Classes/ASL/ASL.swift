/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2017 Jean-David Gadina - www.xs-labs.com
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

import Cocoa
import asl

@objc class ASL: NSObject
{
    @objc public private( set ) dynamic var messages: [ ASLMessage ] = []
    @objc public private( set ) dynamic var senders:  [ ASLSender ]  = []
    
    @objc private dynamic var sender: String = ""
    @objc private dynamic var run:    Bool   = false
    @objc private dynamic var runing: Bool   = false
    @objc private dynamic var exit:   Bool   = false
    @objc private dynamic var inited: Bool   = false
    
    @objc convenience override init()
    {
        self.init( sender: nil )
    }
    
    @objc init( sender: String? )
    {
        super.init()
        
        self.sender = sender ?? ""
        
        Thread.detachNewThreadSelector( #selector( processMessages ), toTarget: self, with: nil )
    }
    
    deinit
    {
        for sender in self.senders
        {
            sender.removeObserver( self, forKeyPath: "messages" )
        }
        
        self.exit = true
        
        while self.runing
        {}
    }
    
    override func observeValue( forKeyPath keyPath: String?, of object: Any?, change: [ NSKeyValueChangeKey : Any ]?, context: UnsafeMutableRawPointer? )
    {
        if( keyPath == "messages" && object is ASLSender )
        {
            DispatchQueue.main.async
            {
                if( self.senders.contains( object as! ASLSender ) )
                {
                    var allMessages = [ ASLMessage ]()
                    
                    for sender in self.senders
                    {
                        allMessages.append( contentsOf: sender.messages as! [ ASLMessage ] )
                    }
                    
                    self.messages = allMessages
                }
            }
        }
        else
        {
            super.observeValue( forKeyPath: keyPath, of: object, change: change, context: context )
        }
    }
    
    @objc public func start()
    {
        self.run = true
    }
    
    @objc public func stop()
    {
        self.run = false
    }
    
    @objc private func processMessages()
    {
        var lastID = self.messages.last?.messageID ?? 0
        let client = asl_open( nil, nil, 0 )
        
        while( self.exit == false )
        {
            self.runing = true
            
            let query = asl_new( UInt32( ASL_TYPE_QUERY ) )
            
            if( self.sender.count > 0 )
            {
                asl_set_query( query, ASL_KEY_MSG, ( self.sender as NSString ).utf8String, UInt32( ASL_QUERY_OP_EQUAL ) )
            }
            
            asl_set_query( query, ASL_KEY_MSG, nil, UInt32( ASL_QUERY_OP_NOT_EQUAL ) )
            asl_set_query( query, ASL_KEY_MSG_ID, ( String( format: "%lu", lastID ) as NSString ).utf8String, UInt32( ASL_QUERY_OP_GREATER ) )
            
            let response = asl_search( client, query )
            
            asl_free( query )
            
            var msg = asl_next( response )
            
            if( msg != nil )
            {
                var newMessages = [ ASLMessage ]()
                
                while( msg != nil )
                {
                    let message = ASLMessage( msg )
                    
                    if( message.messageID <= lastID )
                    {
                        continue
                    }
                    
                    lastID = ( message.messageID > lastID ) ? message.messageID : lastID
                    
                    newMessages.append( message )
                    
                    msg = asl_next( response )
                }
                
                var senders = [ ASLSender ]( self.senders )
                
                for message in newMessages
                {
                    var sender: ASLSender?
                    
                    for s in senders
                    {
                        if( s.name == message.sender && s.facility == message.facility )
                        {
                            sender = s
                            
                            break
                        }
                    }
                    
                    if( sender == nil )
                    {
                        sender = ASLSender( name: message.sender, facility: message.facility )
                        
                        senders.append( sender! )
                        sender?.addObserver( self, forKeyPath: "messages", options: .new, context: nil )
                    }
                    
                    sender?.addMessage( message )
                }
                
                var allMessages: [ ASLMessage ]?
                
                if( newMessages.count == 0 )
                {
                    allMessages = nil
                }
                else
                {
                    allMessages = []
                    
                    for sender in senders
                    {
                        allMessages?.append( contentsOf: sender.messages as! [ ASLMessage ] )
                    }
                }
                
                DispatchQueue.main.sync
                {
                    if( allMessages != nil )
                    {
                        self.messages = allMessages!
                    }
                    
                    self.senders = senders
                }
            }
        }
    }
    
    private func sender( with name: String, facility: String ) -> ASLSender
    {
        for sender in self.senders
        {
            if( sender.name == name && sender.facility == facility )
            {
                return sender
            }
        }
        
        let sender  = ASLSender( name: name, facility: facility )
        var senders = [ ASLSender ]( self.senders )
        
        senders.append( sender )
        
        DispatchQueue.main.sync
        {
            self.senders = senders
        }
        
        return sender
    }
}
