//
//  FSFileDownLoadTool.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/19.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileDownLoadTool.h"

@interface FSFileDownLoadTool()<NSURLSessionDownloadDelegate>

@end
@implementation FSFileDownLoadTool
-(void)downloadWithUrl:(NSString *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downLoadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"downLoadSueesee");
    }];
    
    [downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
    }];
    [downLoadTask resume];
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{

}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{

}
@end
