//
//  LibraryAPI.m
//  BlueLibrary
//
//  Created by apple on 16/2/22.
//  Copyright © 2016年 Eli Ganem. All rights reserved.
//

#import "LibraryAPI.h"

#import "PersistencyManager.h"
//#import "HTTPClient.h"
#import "UIImageView+WebCache.h"

@interface LibraryAPI () {
    PersistencyManager *persistencyManager;
    //HTTPClient *httpClient;
    BOOL isOnline;
}

@end


@implementation LibraryAPI
+ (LibraryAPI*)sharedInstance
{
    // 1 创建一个静态属性，属性将成为类属性，用于记录当前实例
    static LibraryAPI *_sharedInstance = nil;
    
    // 2 创建一次性执行标记位，确保第三步骤只会被执行一次
    static dispatch_once_t oncePredicate;
    
    // 3 使用GCD方法来执行初始化方法，此方法将根据oncePredicate来执行，值执行一次
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        persistencyManager = [[PersistencyManager alloc] init];
        //httpClient = [[HTTPClient alloc] init];
        isOnline = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:@"BLDownloadImageNotification" object:nil];
    }
    return self;
}


- (NSArray*)getAlbums
{
    return [persistencyManager getAlbums];
}

- (void)addAlbum:(Album*)album atIndex:(int)index
{
    [persistencyManager addAlbum:album atIndex:index];
    if (isOnline)
    {
        //[httpClient postRequest:@"/api/addAlbum" body:[album description]];
    }
}

- (void)deleteAlbumAtIndex:(int)index
{
    [persistencyManager deleteAlbumAtIndex:index];
    if (isOnline)
    {
        //[httpClient postRequest:@"/api/deleteAlbum" body:[@(index) description]];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadImage:(NSNotification*)notification
{
    
    // 1
    UIImageView *imageView = notification.userInfo[@"imageView"];
    NSString *coverUrl = notification.userInfo[@"coverUrl"];
    
    // 框架的词方法的功能已经可以替代注释掉的代码的功能
    [imageView sd_setImageWithURL:[NSURL URLWithString:coverUrl] placeholderImage:nil];
    
    //    // 2 从缓存或者沙盒中读取图片
    //    imageView.image = [persistencyManager getImage:[coverUrl lastPathComponent]];
    //
    //    if (imageView.image == nil)
    //    {
    //        // 3 当缓存或者沙盒中图片不存在的时候，远程多线程下载图片。
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //            UIImage *image = [httpClient downloadImage:coverUrl];
    //
    //            // 4 图片下载完毕后需要在主线程中更行UI，并保存图片到沙盒和刷新缓存
    //            dispatch_sync(dispatch_get_main_queue(), ^{
    //                imageView.image = image;
    //                [persistencyManager saveImage:image filename:[coverUrl lastPathComponent]];
    //            });
    //        });
    //    }
}

- (void)saveAlbums
{
    [persistencyManager saveAlbums];
}

@end
