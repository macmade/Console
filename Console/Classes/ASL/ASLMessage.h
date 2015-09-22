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

@import Cocoa;

#import <asl.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASLMessage: NSObject

@property( atomic, readonly ) NSUInteger pid;
@property( atomic, readonly ) NSNumber * pidNumber;
@property( atomic, readonly ) NSUInteger uid;
@property( atomic, readonly ) NSNumber * uidNumber;
@property( atomic, readonly ) NSUInteger gid;
@property( atomic, readonly ) NSNumber * gidNumber;
@property( atomic, readonly ) NSString * facility;
@property( atomic, readonly ) NSString * host;
@property( atomic, readonly ) NSString * sender;
@property( atomic, readonly ) NSUUID   * senderUUID;
@property( atomic, readonly ) NSDate   * time;
@property( atomic, readonly ) NSUInteger level;
@property( atomic, readonly ) NSNumber * levelNumber;
@property( atomic, readonly ) NSString * levelString;
@property( atomic, readonly ) NSString * message;
@property( atomic, readonly ) NSUInteger messageID;
@property( atomic, readonly ) NSNumber * messageIDNumber;

- ( instancetype )initWithASLMessage: ( nullable aslmsg )message NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
