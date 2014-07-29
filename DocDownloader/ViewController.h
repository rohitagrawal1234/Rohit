//
//  ViewController.h
//  DocDownloader
//
//  Created by Admin on 7/28/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadCell.h"
#import "TCBlobDownload.h"
#import "NSFileManager+TCBlobDownload.h"

@interface ViewController : UIViewController <TCBlobDownloaderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)refreshDownload:(id)sender;
@end
