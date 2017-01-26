//
//  Extension.m
//  ExtTest
//
//  Created by Ian McDowell on 12/18/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

#import "Extension.h"
#import "TestObj.h"

@implementation Extension

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
    NSLog(@"Beginning request with context: %@", [context description]);
    
    NSArray *inputItems = [context inputItems];
    NSLog(@"Input items: %@", inputItems);
    
    // Get the input string from the context.
    assert([inputItems count] == 1);
    
    NSExtensionItem *inputItem = inputItems[0];
    
    assert([[inputItem attachments] count] == 1);
    
    NSString *inputString = [inputItem attachments][0];
    
    
    // Uppercase the string.
    NSString *outputString = [inputString uppercaseString];
    
    
    // Instantiate a new object to return to the app. We could just put the NSString in the attachments, but this is here to show how to use your own objects.
    TestObj *obj = [[TestObj alloc] init];
    [obj setName:outputString];
    
    // Archive that object into NSData
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    
    // Create an extension item and attach the data.
    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    [item setAttachments:@[data]];
    
    // Pass the extension item to the context (sends it back to the host app)
    [context completeRequestReturningItems:@[item] completionHandler:^(BOOL expired) {
        NSLog(@"Completed request.");
    }];
}

@end
