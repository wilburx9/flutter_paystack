//
//  EBAEventbritePurchaseViewController.m
//  InEvent
//
//  Created by Pedro Góes on 12/16/15.
//  Copyright © 2015 InEvent. All rights reserved.
//

#import "PSTCKAuthViewController.h"

@interface PSTCKAuthViewController ()

@property(nonatomic, strong) UIWebView *authenticationWebView;
@property(nonatomic, copy) PSTCKAuthCallback completion;
@property(nonatomic, strong) NSURL *authURL;

@end

@interface PSTCKAuthViewController (UIWebViewDelegate) <UIWebViewDelegate>

@end

@implementation PSTCKAuthViewController

BOOL handlingRedirectURL;

- (id)initWithURL:(NSURL *)authURL handler:(PSTCKAuthCallback)completion {
    self = [super init];
    if (self) {
        self.authURL = authURL;
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef __IPHONE_7_0
    self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(tappedCancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.authenticationWebView = [[UIWebView alloc] init];
    self.authenticationWebView.delegate = self;
    self.authenticationWebView.scalesPageToFit = NO;
    [self.view addSubview:self.authenticationWebView];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.authenticationWebView loadRequest:[NSURLRequest requestWithURL:self.authURL]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.authenticationWebView.frame = [UIScreen mainScreen].bounds;
}

#pragma mark UI Action Methods

- (void)tappedCancelButton:(id)cancelButton {
    #pragma unused(cancelButton)
    self.completion();
}

@end

@implementation PSTCKAuthViewController (UIWebViewDelegate)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    #pragma unused(webView, navigationType)
    NSString *url = [[request URL] absoluteString];
    
    // Prevent loading URL if it is the redirectURL
    // The intention is to only requery 3DS auths
    handlingRedirectURL = !([url rangeOfString:@"paystack.co/charge/three_d_response/"].location == NSNotFound);
    
    // Processing has finished?
    if (handlingRedirectURL) {
        self.completion();
    }
    
    return !handlingRedirectURL;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    #pragma unused(webView)
    
    NSLog(@"%@", error);
    NSString * myString = error.description;
    NSLog(@"%@", myString);
    
    // Turn off network activity indicator upon failure to load web view
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // In case the user hits 'Allow' before the page is fully loaded
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    // Abort if we are on Eventbrite's domain
    if (!handlingRedirectURL) {
        self.completion();
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    #pragma unused(webView)

    // Turn off network activity indicator upon finishing web view load
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}

@end
