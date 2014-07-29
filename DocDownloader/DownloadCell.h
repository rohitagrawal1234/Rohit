//
//  DownloadCell.h
//  DocDownloader
//
//  Created by Admin on 7/28/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameOutlet;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *downloadCompleteIcon;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@end
