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

@objc class ASLSender: NSObject, NSCopying
{
    @objc public private( set ) dynamic var name:            String         = ""
    @objc public private( set ) dynamic var facility:        String         = ""
    @objc public private( set ) dynamic var messages:        NSArray        = NSArray()
    @objc public private( set ) dynamic var messagesMutable: NSMutableArray = NSMutableArray()
    @objc public private( set ) dynamic var icon:            NSImage?
    
    static func ==( lhs: ASLSender, rhs: ASLSender ) -> Bool
    {
        if( lhs.name != rhs.name )
        {
            return false
        }
        
        if( lhs.facility != rhs.facility )
        {
            return false
        }
        
        return true
    }
    
    @objc convenience override init()
    {
        self.init( name: "", facility: "" )
    }
    
    @objc init( name: String, facility: String )
    {
        super.init()
        
        self.name     = name
        self.facility = facility
        
        var paths = [ String ]()
        
        let apps     = NSSearchPathForDirectoriesInDomains( .applicationDirectory, .localDomainMask, true ).first
        let userApps = NSSearchPathForDirectoriesInDomains( .applicationDirectory, .userDomainMask,  true ).first
        
        if( apps != nil )
        {
            paths.append( ( apps! as NSString ).appendingPathComponent( String( format: "%@.app", self.name ) ) )
        }
        
        if( userApps != nil )
        {
            paths.append( ( userApps! as NSString ).appendingPathComponent( String( format: "%@.app", self.name ) ) )
        }
        
        paths.append( String( format: "/bin/%@",               self.name ) )
        paths.append( String( format: "/sbin/%@",              self.name ) )
        paths.append( String( format: "/usr/bin/%@",           self.name ) )
        paths.append( String( format: "/usr/sbin/%@",          self.name ) )
        paths.append( String( format: "/usr/libexec/%@",       self.name ) )
        paths.append( String( format: "/usr/local/bin/%@",     self.name ) )
        paths.append( String( format: "/usr/local/sbin/%@",    self.name ) )
        paths.append( String( format: "/usr/local/libexec/%@", self.name ) )
        
        for path in paths
        {
            if( FileManager.default.fileExists(atPath: path ) )
            {
                self.icon = NSWorkspace.shared.icon( forFile: path )
                
                break
            }
        }
        
        if( self.icon == nil )
        {
            self.icon = NSWorkspace.shared.icon( forFile: "/bin/ls" )
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
            return ( self.name + self.facility ).hash
        }
    }
    
    func copy( with zone: NSZone? = nil ) -> Any
    {
        return ASLSender( name: self.name, facility: self.facility )
    }
    
    @objc public func addMessage( _ message: ASLMessage )
    {
        self.messagesMutable.add( message )
        
        self.messages = self.messagesMutable
    }
    
    @objc public func clear()
    {
        self.messagesMutable = NSMutableArray()
        self.messages        = self.messagesMutable
    }
}
