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

@objc class PreferencesWindowController: NSWindowController
{
    @objc private dynamic var fontDescription: String                    = ""
    @objc private dynamic var backgroundColor: NSColor                   = NSColor.white
    @objc private dynamic var foregroundColor: NSColor                   = NSColor.black
    @objc private dynamic var selectedTheme:   Int                       = 0
    @objc private dynamic var observations:    [ NSKeyValueObservation ] = []
    
    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name( NSStringFromClass( type( of: self ) ) )
    }
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.fontDescription = String( format: "%@ %.0f", Preferences.shared.fontName ?? "-", Preferences.shared.fontSize )
        self.backgroundColor = NSColor( deviceRed: Preferences.shared.backgroundColorR, green: Preferences.shared.backgroundColorG, blue: Preferences.shared.backgroundColorB, alpha: 1.0 )
        self.foregroundColor = NSColor( deviceRed: Preferences.shared.foregroundColorR, green: Preferences.shared.foregroundColorG, blue: Preferences.shared.foregroundColorB, alpha: 1.0 )
        
        let o1 = Preferences.shared.observe( \.fontName )
        {
            ( o, c ) in self.fontDescription = String( format: "%@ %.0f", o.fontName ?? "-", o.fontSize )
        }
        
        let o2 = Preferences.shared.observe( \.fontSize )
        {
            ( o, c ) in self.fontDescription = String( format: "%@ %.0f", o.fontName ?? "-", o.fontSize )
        }
        
        let o3 = self.observe( \.backgroundColor )
        {
            ( o, c ) in
            
            var r: CGFloat = 0.0
            var g: CGFloat = 0.0
            var b: CGFloat = 0.0
            
            self.backgroundColor.usingColorSpace( .deviceRGB )?.getRed( &r, green: &g, blue: &b, alpha: nil )
            
            Preferences.shared.backgroundColorR = r
            Preferences.shared.backgroundColorG = g
            Preferences.shared.backgroundColorB = b
        }
        
        let o4 = self.observe( \.foregroundColor )
        {
            ( o, c ) in
            
            var r: CGFloat = 0.0
            var g: CGFloat = 0.0
            var b: CGFloat = 0.0
            
            self.foregroundColor.usingColorSpace( .deviceRGB )?.getRed( &r, green: &g, blue: &b, alpha: nil )
            
            Preferences.shared.foregroundColorR = r
            Preferences.shared.foregroundColorG = g
            Preferences.shared.foregroundColorB = b
        }
        
        let o5 = self.observe( \.selectedTheme )
        {
            ( o, c ) in
            
            switch( self.selectedTheme )
            {
                case 1:
                    
                    self.backgroundColor = self.hexColor( 0xFFFFFF, alpha: 1.0 );
                    self.foregroundColor = self.hexColor( 0x000000, alpha: 1.0 );
                    
                    break;
                    
                case 2:
                    
                    self.backgroundColor = self.hexColor( 0x000000, alpha: 1.0 );
                    self.foregroundColor = self.hexColor( 0xFFFFFF, alpha: 1.0 );
                    
                    break;
                    
                case 3:
                    
                    self.backgroundColor = self.hexColor( 0xFFFCE5, alpha: 1.0 );
                    self.foregroundColor = self.hexColor( 0xC3741C, alpha: 1.0 );
                    
                    break;
                    
                case 4:
                    
                    self.backgroundColor = self.hexColor( 0x161A1D, alpha: 1.0 );
                    self.foregroundColor = self.hexColor( 0xBFBFBF, alpha: 1.0 );
                    
                    break;
                    
                default:
                    
                    break;
            }
        }
        
        self.observations.append( contentsOf: [ o1, o2, o3, o4, o5 ] )
    }
    
    private func hexColor( _ hex: UInt, alpha: CGFloat ) -> NSColor
    {
        let r: CGFloat = CGFloat( ( ( hex >> 16 ) & 0x0000FF ) ) / 255.0
        let g: CGFloat = CGFloat( ( ( hex >>  8 ) & 0x0000FF ) ) / 255.0
        let b: CGFloat = CGFloat( ( ( hex       ) & 0x0000FF ) ) / 255.0
        
        return NSColor( deviceRed: r, green: g, blue: b, alpha: alpha )
    }
    
    @IBAction func chooseFont( _ sender: Any? )
    {
        let font    = NSFont( name: Preferences.shared.fontName as String? ?? "", size: Preferences.shared.fontSize )
        let manager = NSFontManager.shared
        let panel   = manager.fontPanel( true )
        
        if( font != nil )
        {
            manager.setSelectedFont( font!, isMultiple: false )
        }
        
        panel?.makeKeyAndOrderFront( sender )
    }
    
    @IBAction override func changeFont( _ sender: Any? )
    {
        guard let manager = ( sender as AnyObject? ) as? NSFontManager else
        {
            return
        }
        
        guard let selected = manager.selectedFont else
        {
            return
        }
        
        let font = manager.convert( selected )
        
        Preferences.shared.fontName = font.fontName
        Preferences.shared.fontSize = font.pointSize
    }
}

