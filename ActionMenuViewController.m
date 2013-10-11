//
//  ActionMenuViewController.m
//  WebComiX
//
//  Created by Chris Golding on 4/10/12.
//  Copyright (c) 2012 RabidMonkeyWare. All rights reserved.
//

#import "ActionMenuViewController.h"

@interface ActionMenuViewController ()

@end

@implementation ActionMenuViewController

@synthesize urlToCurrentPage = _urlToCurrentPage;
@synthesize titleOfPage = _titleOfPage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentSizeForViewInPopover = CGSizeMake(209,96);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)mailLinkToPage:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:self.titleOfPage];
                        
        NSString *emailBody = self.urlToCurrentPage;
        [mailer setMessageBody:emailBody isHTML:NO];
        
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:mailer animated:YES];
        
        [mailer release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)tweetLinkToPage:(id)sender {
    if ( [TWTweetComposeViewController canSendTweet] ){
        TWTweetComposeViewController *twitterComposer = [[TWTweetComposeViewController alloc]init];
        //[twitterComposer setInitialText:self.urlToCurrentPage];
        [twitterComposer addURL:[NSURL URLWithString:self.urlToCurrentPage]];
        [self presentModalViewController:twitterComposer animated:YES];
    }
    else {
        UIAlertView *objAlertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your device annot send the tweet now, kindly check the internet connection or make a check whether your device has atleast one twitter account setup" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [objAlertView show];
        [objAlertView release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}
@end
