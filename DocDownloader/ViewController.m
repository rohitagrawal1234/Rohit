//
//  ViewController.m
//  DocDownloader
//
//  Created by Admin on 7/28/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "ViewController.h"
#import "TCBlobDownloader.h"
#import "TCBlobDownloadManager.h"
#import "NSFileManager+TCBlobDownload.h"

static NSString * const kDownloadCellIdentifier = @"downloadCell";

@interface ViewController ()
@property(nonatomic,strong)NSMutableArray *downloadObjs;
@property (nonatomic, strong) NSMutableArray *currentDownloads;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadAll];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshDownload:(id)sender
{
    [self downloadAll];
}


- (void)downloadAll
{
    NSString *meetingName = @"/MetingFolder";
    
    _downloadObjs = [[NSMutableArray alloc] init];
    _currentDownloads = [[NSMutableArray alloc] init];

    NSArray *urlArray = [[NSArray alloc] initWithObjects:@"https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf",@"https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/MobileHIG.pdf",@"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf",@"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf", nil];
    
    for (int i=0;i < [urlArray count];i++) {
        NSString *fileDownloadUrl = [urlArray objectAtIndex:i];
        NSString *fileTitle = [NSString stringWithFormat:@"iphoneappprogrammingguide%d.pdf",i];
        NSString *fileLocalPath = [NSFileManager getLocalPathForFile:fileTitle inMeetingFolder:meetingName];
        BOOL isFileExist = NO;
      
        
        TCBlobDownloader *download = [[TCBlobDownloader alloc] initWithURL:[NSURL URLWithString:fileDownloadUrl]
                                                              downloadPath:[NSFileManager getMeetingFolderPathForFolder:meetingName]
                                                                  delegate:self];
        [download setFileName:fileTitle];
        
        if ([self isFileExistAtPath:fileLocalPath]) {
            isFileExist = YES;
            download.isFileAlreadyExist = YES;
            download.fileLocalPath = fileLocalPath;
            download.state = TCBlobDownloadStateDone;
            [self.currentDownloads addObject:download];

        } else {
            download.isFileAlreadyExist = NO;
            download.fileLocalPath = nil;
            [self.currentDownloads addObject:download];
            [[TCBlobDownloadManager sharedInstance] startDownload:download];
        }

    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                       withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (BOOL)isFileExistAtPath:(NSString *)FilePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:FilePath];
    
}

- (float)getProgressForDownload:(TCBlobDownloader *)download
{
    return (float)(download.progress);
}


- (NSString *)subtitleForDownload:(TCBlobDownloader *)download
{
    NSString *stateString;
    
    switch (download.state) {
        case TCBlobDownloadStateReady:
            stateString = @"Ready";
            break;
        case TCBlobDownloadStateDownloading:
            stateString = @"Downloading";
            break;
        case TCBlobDownloadStateDone:
            stateString = @"Done";
            break;
        case TCBlobDownloadStateCancelled:
            stateString = @"Cancelled";
            break;
        case TCBlobDownloadStateFailed:
            stateString = @"Failed";
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%i%% • %lis left • State: %@",
            (int)(download.progress),
            (long)download.remainingTime,
            stateString];
}



#pragma mark - TCBlobDownloader Delegate


- (void)updateFileLocalPath:(NSString *)pahtToFile forDownlaod:(TCBlobDownloader *)blobDownload
{
    blobDownload.fileLocalPath = pahtToFile;
}

- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSuccess:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    if (downloadFinished) {
        NSLog(@"FINISHED");

    } else {
        NSLog(@"erorr");

    }
    NSInteger index = [self.currentDownloads indexOfObject:blobDownload];

    [self updateFileLocalPath:pathToFile forDownlaod:blobDownload];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)download:(TCBlobDownloader *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength
        progress:(float)progress
{
    NSInteger index = [self.currentDownloads indexOfObject:blobDownload];
    
    DownloadCell *cell = (DownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.progressBar setProgress:[self getProgressForDownload:blobDownload]];
   
}

- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
    
}

- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
    
    
    NSInteger index = [self.currentDownloads indexOfObject:blobDownload];
    
    DownloadCell *cell = (DownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.downloadCompleteIcon setImage:[UIImage imageNamed:@"attention-icon.png"]];
    
    NSLog(@"eror %@",[error localizedDescription]);
}


#pragma mark - UITableViewDataSource Delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentDownloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:kDownloadCellIdentifier];
   
    TCBlobDownloader *download = self.currentDownloads[indexPath.row];
    
    [cell.fileNameOutlet setText:download.fileName];
    [cell.fileNameOutlet setFont:[UIFont systemFontOfSize:10.f]];
    [cell.progressBar setProgress:[self getProgressForDownload:download]];
    
    if (download.state == TCBlobDownloadStateReady) {
        [cell.activityIndicator startAnimating];
        [cell.progressBar setHidden:NO];
        [cell.downloadCompleteIcon setHidden:YES];
    } else if(download.state == TCBlobDownloadStateDone) {
        [cell.activityIndicator stopAnimating];
        [cell.progressBar setHidden:YES];
        [cell.downloadCompleteIcon setHidden:NO];
        [cell.downloadCompleteIcon setImage:[UIImage imageNamed:@"tick.png"]];
    } else if(download.state == TCBlobDownloadStateFailed) {
        [cell.activityIndicator stopAnimating];
        [cell.progressBar setHidden:YES];
        [cell.downloadCompleteIcon setHidden:NO];
        [cell.downloadCompleteIcon setImage:[UIImage imageNamed:@"attention-icon.png"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCBlobDownloader *download = self.currentDownloads[indexPath.row];

    if (download.state != TCBlobDownloadStateDone) {
        NSLog(@"not downloaded %@",download.fileLocalPath);

    } else {
        NSLog(@"filepath %@",download.fileLocalPath);
    }
}


@end

