// Copyright (C) 2007-2014 Satoshi Nakagawa <psychs AT limechat DOT net>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "IRCMessage.h"
#import "NSDateHelper.h"
#import "NSStringHelper.h"

@implementation IRCMessage

- (id)init
{
    self = [super init];
    if( self ) {
        [self parseLine:@""];
    }
    return self;
}

- (id)initWithLine:(NSString *)line
{
    self = [super init];
    if( self ) {
        [self parseLine:line];
    }
    return self;
}

- (void)parseLine:(NSString *)line
{
    _sender = [IRCPrefix new];
    _command = @"";
    _timestamp = 0;
    _params = [NSMutableArray new];

    NSMutableString *s = [line mutableCopy];

    while( [s hasPrefix:@"@"] ) {
        NSString *t = [s getToken];
        t = [t substringFromIndex:1];

        int i = [t findCharacter:'='];
        if( i < 0 ) {
            continue;
        }

        NSString *key = [t substringToIndex:i];
        NSString *value = [t substringFromIndex:i + 1];

        // Spec is http://ircv3.atheme.org/extensions/server-time-3.2
        // ZNC has supported @t and @time keys and UnixTimestamp and ISO8601 dates
        // in past releases.
        // Attempt to support all previous formats.
        if( [key isEqualToString:@"t"] || [key isEqualToString:@"time"] ) {
            if( [value contains:@"-"] ) {
                _timestamp = [NSDate timeIntervalFromISO8601String:value];
            }
            else {
                _timestamp = [value longLongValue];
            }
        }
    }

    if( _timestamp == 0 ) {
        time( &_timestamp );
    }

    if( [s hasPrefix:@":"] ) {
        NSString *t = [s getToken];
        t = [t substringFromIndex:1];
        _sender.raw = t;

        int i = [t findCharacter:'!'];
        if( i < 0 ) {
            _sender.nick = t;
            _sender.isServer = YES;
        }
        else {
            _sender.nick = [t substringToIndex:i];
            t = [t substringFromIndex:i + 1];

            i = [t findCharacter:'@'];
            if( i >= 0 ) {
                _sender.user = [t substringToIndex:i];
                _sender.address = [t substringFromIndex:i + 1];
            }
        }
    }

    _command = [[s getToken] uppercaseString];
    _numericReply = [_command intValue];

    while( s.length ) {
        if( [s hasPrefix:@":"] ) {
            [_params addObject:[s substringFromIndex:1]];
            break;
        }
        else {
            [_params addObject:[s getToken]];
        }
    }
}

- (NSString *)paramAt:(int)index
{
    if( index < _params.count ) {
        return [_params objectAtIndex:index];
    }
    else {
        return @"";
    }
}

- (NSString *)sequence
{
    return [self sequence:0];
}

- (NSString *)sequence:(int)index
{
    NSMutableString *s = [NSMutableString string];

    int count = _params.count;
    for( int i = index; i < count; i++ ) {
        NSString *e = [_params objectAtIndex:i];
        if( i != index ) [s appendString:@" "];
        [s appendString:e];
    }

    return s;
}

- (NSString *)description
{
    NSMutableString *ms = [NSMutableString string];
    [ms appendString:@"<IRCMessage "];
    [ms appendString:_command];
    for( NSString *s in _params ) {
        [ms appendString:@" "];
        [ms appendString:s];
    }
    [ms appendString:@">"];
    return ms;
}

#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@( self.timestamp ) forKey:@"timestamp"];
    [aCoder encodeObject:self.sender forKey:@"sender"];
    [aCoder encodeObject:self.command forKey:@"command"];
    [aCoder encodeObject:@( self.numericReply ) forKey:@"numericReply"];
    [aCoder encodeObject:self.params forKey:@"params"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if( self ) {
        self.timestamp = [[aDecoder decodeObjectForKey:@"timestamp"] longLongValue];
        self.sender = [aDecoder decodeObjectForKey:@"sender"];
        self.command = [aDecoder decodeObjectForKey:@"command"];
        self.numericReply = [[aDecoder decodeObjectForKey:@"numericReply"] intValue];
        self.params = [aDecoder decodeObjectForKey:@"params"];
    }
    return self;
}
@end
