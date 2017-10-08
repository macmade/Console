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

import Foundation
import asl

@objc class ASLMessage: NSObject
{
    @objc public private( set ) dynamic var pid:             UInt     = 0
    @objc public private( set ) dynamic var pidNumber:       NSNumber = 0
    @objc public private( set ) dynamic var uid:             UInt     = 0
    @objc public private( set ) dynamic var uidNumber:       NSNumber = 0
    @objc public private( set ) dynamic var gid:             UInt     = 0
    @objc public private( set ) dynamic var gidNumber:       NSNumber = 0
    @objc public private( set ) dynamic var facility:        String   = ""
    @objc public private( set ) dynamic var host:            String   = ""
    @objc public private( set ) dynamic var sender:          String   = ""
    @objc public private( set ) dynamic var senderUUID:      UUID     = UUID()
    @objc public private( set ) dynamic var time:            Date     = Date( timeIntervalSince1970: 0 )
    @objc public private( set ) dynamic var level:           UInt     = 0
    @objc public private( set ) dynamic var levelNumber:     NSNumber = 0
    @objc public private( set ) dynamic var levelString:     String   = ""
    @objc public private( set ) dynamic var message:         String   = ""
    @objc public private( set ) dynamic var messageID:       UInt     = 0
    @objc public private( set ) dynamic var messageIDNumber: NSNumber = 0
    
    static func ==( lhs: ASLMessage, rhs: ASLMessage ) -> Bool
    {
        return lhs.messageID == rhs.messageID
    }
    
    @objc public convenience override init()
    {
        self.init( ASLMessage: nil )
    }
    
    @objc public init( ASLMessage: aslmsg? )
    {
        super.init()
        
        guard let msg = ASLMessage else
        {
            return
        }
        
        self.pid             = self.valueToUnsignedInteger( asl_get( msg, ASL_KEY_PID ) )
        self.pidNumber       = NSNumber( value: self.pid )
        self.uid             = self.valueToUnsignedInteger( asl_get( msg, ASL_KEY_UID ) )
        self.uidNumber       = NSNumber( value: self.uid )
        self.gid             = self.valueToUnsignedInteger( asl_get( msg, ASL_KEY_GID ) )
        self.gidNumber       = NSNumber( value: self.gid )
        self.facility        = self.valueToString( asl_get( msg, ASL_KEY_FACILITY ) )
        self.host            = self.valueToString( asl_get( msg, ASL_KEY_HOST ) )
        self.sender          = self.valueToString( asl_get( msg, ASL_KEY_SENDER ) )
        self.senderUUID      = self.valueToUUID( asl_get( msg, ASL_KEY_SENDER_MACH_UUID ) )
        self.time            = self.valueToDate( asl_get( msg, ASL_KEY_TIME ) )
        self.level           = self.valueToUnsignedInteger( asl_get( msg, ASL_KEY_LEVEL ) )
        self.levelNumber     = NSNumber( value: self.level )
        self.message         = self.valueToString( asl_get( msg, ASL_KEY_MSG ) )
        self.messageID       = self.valueToUnsignedInteger( asl_get( msg, ASL_KEY_MSG_ID ) )
        self.messageIDNumber = NSNumber( value: self.messageID )
        
        switch( Int32( self.level ) )
        {
            case ASL_LEVEL_EMERG:   self.levelString = "Emergency"
            case ASL_LEVEL_ALERT:   self.levelString = "Alert"
            case ASL_LEVEL_CRIT:    self.levelString = "Critical"
            case ASL_LEVEL_ERR:     self.levelString = "Error";
            case ASL_LEVEL_WARNING: self.levelString = "Warning"
            case ASL_LEVEL_NOTICE:  self.levelString = "Notice"
            case ASL_LEVEL_INFO:    self.levelString = "Info"
            case ASL_LEVEL_DEBUG:   self.levelString = "Debug"
            default:                self.levelString = "Unknown"
        }
    }
    
    override func isEqual( _ object: Any? ) -> Bool
    {
        guard let o = object as? ASLMessage else
        {
            return false
        }
        
        if( o === self )
        {
            return true
        }
        
        return self == o
    }
    
    override func isEqual( to object: Any? ) -> Bool
    {
        return self.isEqual( object )
    }
    
    override public var hash: Int
    {
        get
        {
            return Int( self.messageID )
        }
    }
    
    public override var description: String
    {
        return String( format: "%@ %@[ %u ] - %@: %@", super.description, self.sender, self.pid, self.levelString, self.message )
    }
    
    private func valueToString( _ value: UnsafePointer< Int8 >! ) -> String
    {
        if( value == nil )
        {
            return ""
        }
        
        return NSString( utf8String: value ) as String? ?? ""
    }
    
    private func valueToDate( _ value: UnsafePointer< Int8 >! ) -> Date
    {
        return Date( timeIntervalSince1970: TimeInterval( self.valueToUnsignedInteger( value ) ) )
    }
    
    private func valueToUUID( _ value: UnsafePointer< Int8 >! ) -> UUID
    {
        return UUID( uuidString: self.valueToString( value ) ) ?? UUID()
    }
    
    private func valueToUnsignedInteger( _ value: UnsafePointer< Int8 >! ) -> UInt
    {
        if( value == nil )
        {
            return 0
        }
        
        return UInt( ( self.valueToString( value ) as NSString ).integerValue )
    }
}
