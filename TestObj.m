//
//  TestObj.m
//  ExtTest
//
//  Created by Ian McDowell on 1/23/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

#import "TestObj.h"

@implementation TestObj

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
}

@end
