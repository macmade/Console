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

@objc class MainWindowController: NSWindowController, NSTableViewDataSource
{
    @objc private dynamic var asl:                                ASL?
    @objc private dynamic var observations:                       [ NSKeyValueObservation ] = []
    @objc private dynamic var textViewContainerHiddenConstraint:  NSLayoutConstraint?
    @objc private dynamic var textViewContainerVisibleConstraint: NSLayoutConstraint?
     
    @objc @IBOutlet private dynamic var sendersArrayController:  NSArrayController?
    @objc @IBOutlet private dynamic var messagesArrayController: NSArrayController?
    @objc @IBOutlet private dynamic var textView:                NSTextView?
    @objc @IBOutlet private dynamic var textViewContainer:       NSView?
    
    convenience init()
    {
        self.init( sender: nil )
    }
    
    convenience init( sender: String? )
    {
        self.init( windowNibName: NSNib.Name( NSStringFromClass( type( of: self ) ) ) )
        
        self.asl = ASL( sender: sender )
    }
    
    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name( NSStringFromClass( type( of: self ) ) )
    }
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.window?.titlebarAppearsTransparent = true
        self.window?.titleVisibility            = .hidden
        
        self.asl?.start()
        
        self.sendersArrayController?.sortDescriptors  = [ NSSortDescriptor( key: "name", ascending: true ) ]
        self.messagesArrayController?.sortDescriptors = [ NSSortDescriptor( key: "time", ascending: false ) ]
        
        let o1 = self.asl?.observe( \.messages )
        {
            ( o, c ) in
            
            if( self.sendersArrayController?.selectedObjects.count == 0 )
            {
                self.messagesArrayController?.content = self.asl?.messages
            }
            else
            {
                self.messagesArrayController?.content = self.sendersArrayController?.value( forKeyPath: "selection.@unionOfArrays.messages" )
            }
        }
        
        let o2 = self.sendersArrayController?.observe( \.selection )
        {
            ( o, c ) in
            
            if( self.sendersArrayController?.selectionIndexes.count == 0 )
            {
                self.messagesArrayController?.content = self.asl?.messages
            }
            else
            {
                self.messagesArrayController?.content = self.sendersArrayController?.value( forKeyPath: "selection.@unionOfArrays.messages" )
            }
        }
        
        let o3 = self.messagesArrayController?.observe( \.selection )
        {
            ( o, c ) in
            
            if( self.messagesArrayController?.selectionIndexes.count != 1 )
            {
                self.textViewContainerVisibleConstraint?.isActive = false
                self.textViewContainerHiddenConstraint?.isActive  = true
            }
            else
            {
                self.textViewContainerHiddenConstraint?.isActive  = false
                self.textViewContainerVisibleConstraint?.isActive = true
            }
        }
        
        if( o1 != nil ) { self.observations.append( o1! ) }
        if( o2 != nil ) { self.observations.append( o2! ) }
        if( o3 != nil ) { self.observations.append( o3! ) }
        
        self.messagesArrayController?.content = self.asl?.messages
        self.textView?.textContainerInset     = NSMakeSize( 10.0, 15.0 )
        
        let o4  = Preferences.shared.observe( \.fontName         ) { ( o, c ) in self.updateDisplaySettings() }
        let o5  = Preferences.shared.observe( \.fontSize         ) { ( o, c ) in self.updateDisplaySettings() }
        let o6  = Preferences.shared.observe( \.backgroundColorR ) { ( o, c ) in self.updateDisplaySettings() }
        let o7  = Preferences.shared.observe( \.backgroundColorG ) { ( o, c ) in self.updateDisplaySettings() }
        let o8  = Preferences.shared.observe( \.backgroundColorB ) { ( o, c ) in self.updateDisplaySettings() }
        let o9  = Preferences.shared.observe( \.foregroundColorR ) { ( o, c ) in self.updateDisplaySettings() }
        let o10 = Preferences.shared.observe( \.foregroundColorG ) { ( o, c ) in self.updateDisplaySettings() }
        let o11 = Preferences.shared.observe( \.foregroundColorB ) { ( o, c ) in self.updateDisplaySettings() }
        
        self.observations.append( contentsOf: [ o4, o5, o6, o7, o8, o9, o10, o11 ] )
        
        self.updateDisplaySettings()
        
        for constraint in self.textViewContainer?.constraints ?? []
        {
            if( constraint.firstAttribute == .height )
            {
                constraint.isActive                     = false
                self.textViewContainerVisibleConstraint = constraint
                self.textViewContainerHiddenConstraint  = NSLayoutConstraint( item: self.textViewContainer!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: 0.0 )
                
                self.textViewContainer?.addConstraint( self.textViewContainerHiddenConstraint! )
                
                break
            }
        }
    }
    
    @IBAction func clearAllMessages( _ sender: Any? )
    {
        var senders: [ ASLSender ]?
        
        if( self.sendersArrayController?.selectedObjects.count != 0 )
        {
            senders = self.sendersArrayController?.selectedObjectsArray()
        }
        else
        {
            senders = self.sendersArrayController?.arrangedObjectsArray()
        }
        
        for s in senders ?? []
        {
            s.clear()
        }
    }
    
    @objc private func updateDisplaySettings()
    {
        var font: NSFont?
        
        let fontName = Preferences.shared.fontName
        
        if( fontName != nil && fontName!.count > 0 )
        {
            font = NSFont( name: fontName!, size: Preferences.shared.fontSize )
        }
        
        if( font == nil )
        {
            font = NSFont( name: "Consolas", size: Preferences.shared.fontSize )
        }
        
        if( font == nil )
        {
            font = NSFont( name: "Menlo", size: Preferences.shared.fontSize )
        }
        
        if( font == nil )
        {
            font = NSFont( name: "Monaco", size: Preferences.shared.fontSize )
        }
        
        if( font == nil )
        {
            font = NSFont.systemFont( ofSize: Preferences.shared.fontSize )
        }
        
        self.textView?.font = font
        
        let background = NSColor( deviceRed: Preferences.shared.backgroundColorR, green: Preferences.shared.backgroundColorG, blue: Preferences.shared.backgroundColorB, alpha: 1.0 )
        let foreground = NSColor( deviceRed: Preferences.shared.foregroundColorR, green: Preferences.shared.foregroundColorG, blue: Preferences.shared.foregroundColorB, alpha: 1.0 )
        
        self.textView?.backgroundColor = background
        self.textView?.textColor       = foreground
    }
    
    // MARK: - NSTableViewDataSource
    
    func tableView( _ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard ) -> Bool
    {
        tableView.setDraggingSourceOperationMask( .copy, forLocal: false )
        
        guard let messages = ( self.messagesArrayController?.arrangedObjects as? NSArray )?.objects( at: rowIndexes ) else
        {
            return false
        }
        
        var contents = [ String ]()
        
        for message in messages as! [ ASLMessage ]
        {
            contents.append( message.message )
        }
        
        if( contents.count > 0 )
        {
            pboard.setString( contents.joined( separator: "\n\n--------------------------------------------------------------------------------\n\n" ), forType: .string )
            
            return true
        }
        
        return false
    }
}
