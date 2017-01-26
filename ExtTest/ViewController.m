//
//  ViewController.m
//  ExtTest
//
//  Created by Ian McDowell on 12/18/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

#import "ViewController.h"

#import "PrivateHeaders.h"

#import "TestObj.h"

@interface ViewController ()

@property (nonatomic, strong) NSExtension *extension;

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *requestButton;
@property (nonatomic, strong) UILabel *responseLabel;

@end

@implementation ViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Extension Test";
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        NSError *error;
        self.extension = [NSExtension extensionWithIdentifier:@"net.ianmcdowell.ExtTest.ExtTestExtension" error:&error];
        
        NSLog(@"Loaded extension: %@", [self.extension description]);
        
        // This block will be called if the extension calls
        // [context cancelRequestWithError:]
        [self.extension setRequestCancellationBlock:^(NSUUID *uuid, NSError *error) {
            NSLog(@"Request %@ cancelled. %@", uuid, error);
        }];
        
        // This block will be called if the extension process crashes or there was an XPC communication issue.
        [self.extension setRequestInterruptionBlock:^(NSUUID *uuid) {
            NSLog(@"Request %@ interrupted.", uuid);
        }];
        
        __weak ViewController *weakSelf = self;
        // This block will be called if the extension calls
        // [context completeRequestReturningItems:completionHandler:]
        [self.extension setRequestCompletionBlock:^(NSUUID *uuid, NSArray *extensionItems) {
            
            NSLog(@"Request %@ completed.", uuid);
            
            // In this scenario, we are assuming that the extension will always return 1 extension item.
            // That extension item will always contain an attachment, which is an NSData serialization
            // of a TestObj. Your use case may vary.
            
            assert([extensionItems count] == 1);
            
            NSExtensionItem *item = extensionItems[0];
            NSArray *attachments = [item attachments];
            
            assert([attachments count] == 1);
            
            NSData *attachmentData = attachments[0];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:attachmentData];
            [unarchiver setRequiresSecureCoding:YES];
            
            TestObj *obj = [unarchiver decodeObjectOfClass:[TestObj class] forKey:NSKeyedArchiveRootObjectKey];
            
            NSLog(@"Received response object: %@", obj);
            
            // This block is called on a background queue, so to modify our UI, we must dispatch back to the main queue.
            dispatch_async(dispatch_get_main_queue(), ^{
                // Show the response in the label.
                [weakSelf.responseLabel setText:[obj name]];
            });

        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.textField = [[UITextField alloc] init];
    [self.textField setPlaceholder:@"Enter text to send to the extension"];
    
    self.requestButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.requestButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.requestButton addTarget:self action:@selector(sendExtensionRequest) forControlEvents:UIControlEventTouchUpInside];
    
    self.responseLabel = [[UILabel alloc] init];
    [self.responseLabel setNumberOfLines:0];
    [self.responseLabel setText:@"Send a request and the response will appear here."];
    
    
    // Add to view
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.textField, self.requestButton, self.responseLabel]];
    [stackView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [stackView setSpacing:25];
    [stackView setAlignment:UIStackViewAlignmentFill];
    [stackView setAxis:UILayoutConstraintAxisVertical];
    [stackView setDistribution:UIStackViewDistributionFillProportionally];
    
    [self.view addSubview:stackView];
    [[stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:25] setActive:YES];
    [[stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant: -25] setActive:YES];
    [[stackView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:25] setActive:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (void)sendExtensionRequest {
    
    NSString *input = [self.textField text];

    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    [item setAttachments:@[input]];
    
    // Start a request to the extension with the given input items.
    [self.extension beginExtensionRequestWithInputItems:@[item] completion:^void (NSUUID *requestIdentifier){
        
        int pid = [self.extension pidForRequestIdentifier:requestIdentifier];
        
        NSLog(@"Started extension request: %@. Extension PID is: %i", requestIdentifier, pid);
    }];
}

@end
