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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Preferences: NSObject

+ ( instancetype )sharedInstance;

@property( atomic, readwrite, strong, nullable ) NSDate   * lastStart;
@property( atomic, readwrite, strong, nullable ) NSString * fontName;
@property( atomic, readwrite, assign           ) CGFloat    fontSize;
@property( atomic, readwrite, assign           ) CGFloat    backgroundColorR;
@property( atomic, readwrite, assign           ) CGFloat    backgroundColorG;
@property( atomic, readwrite, assign           ) CGFloat    backgroundColorB;
@property( atomic, readwrite, assign           ) CGFloat    foregroundColorR;
@property( atomic, readwrite, assign           ) CGFloat    foregroundColorG;
@property( atomic, readwrite, assign           ) CGFloat    foregroundColorB;

@end

NS_ASSUME_NONNULL_END
