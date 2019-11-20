//
//  EBAEventbritePurchaseViewController.m
//  InEvent
//
//  Created by Pedro Góes on 12/16/15.
//  Copyright © 2015 InEvent. All rights reserved.
//

#import "PSTCKAuthViewController.h"

@interface PSTCKAuthViewController ()

@property(nonatomic, strong) WKWebView *authenticationWebView;
@property(nonatomic, copy) PSTCKAuthCallback completion;
@property(nonatomic, strong) NSURL *authURL;

@end

@interface PSTCKAuthViewController (WKNavigationDelegate) <WKNavigationDelegate, WKUIDelegate>

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
    // Adds javascript to make content width the device width.
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    self.authenticationWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:wkWebConfig];
    self.authenticationWebView.UIDelegate = self;
    self.authenticationWebView.navigationDelegate = self;
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

@implementation PSTCKAuthViewController (WKNavigationDelegate)

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
     #pragma unused(webView, navigationAction)
    NSURLRequest *request = navigationAction.request;
    NSString *url = [[request URL]absoluteString];
    
    // Prevent loading URL if it is the redirectURL
    // The intention is to only requery 3DS auths
    handlingRedirectURL = !([url rangeOfString:@"paystack.co/charge/three_d_response/"].location == NSNotFound);
    
    // Processing has finished?
    if (handlingRedirectURL) {
        self.completion();
        return decisionHandler(WKNavigationActionPolicyCancel);

    }
    else {
        return decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    #pragma unused(webView, navigation)
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    #pragma unused(webView, navigation)
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

@end
