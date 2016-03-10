//
//  PersistencyManager.m
//  BlueLibrary
//
//  Created by apple on 16/2/22.
//  Copyright © 2016年 Eli Ganem. All rights reserved.
//

#import "PersistencyManager.h"

@interface PersistencyManager () {
    // an array of all albums
    NSMutableArray *albums;
    
    // 图片缓存
    NSMutableDictionary *imageCache;
    
}
@end


@implementation PersistencyManager

- (id)init
{
    self = [super init];
    if (self) {
        
        // 初始化图片缓存
        imageCache = [NSMutableDictionary dictionary];
        
        // 当归档的数据加载进内存
        NSData *data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/albums.bin"]];
        albums = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (albums == nil)
        {
            albums = [NSMutableArray arrayWithArray:
                      @[[[Album alloc] initWithTitle:@"Best of Bowie" artist:@"David Bowie" coverUrl:@"http://musicdata.baidu.com/data2/pic/122819029/122819029.jpg" year:@"1992"],
                        [[Album alloc] initWithTitle:@"It's My Life" artist:@"No Doubt" coverUrl:@"http://b.hiphotos.baidu.com/ting/abpic/item/d000baa1cd11728b0d5fc2bec9fcc3cec3fd2c3f.jpg" year:@"2003"],
                        [[Album alloc] initWithTitle:@"Nothing Like The Sun" artist:@"Sting" coverUrl:@"http://musicdata.baidu.com/data2/pic/118743792/118743792.jpg" year:@"1999"],
                        [[Album alloc] initWithTitle:@"Staring at the Sun" artist:@"U2" coverUrl:@"http://musicdata.baidu.com/data2/pic/117415481/117415481.jpg" year:@"2000"],
                        [[Album alloc] initWithTitle:@"American Pie" artist:@"Madonna" coverUrl:@"http://musicdata.baidu.com/data2/pic/102334731/102334731.jpg" year:@"2000"]]];
            [self saveAlbums];
        }
    }
    return self;
}


- (NSArray*)getAlbums
{
    return albums;
}

- (void)addAlbum:(Album*)album atIndex:(int)index
{
    if (albums.count >= index)
        [albums insertObject:album atIndex:index];
    else
        [albums addObject:album];
}

- (void)deleteAlbumAtIndex:(int)index
{
    [albums removeObjectAtIndex:index];
}



- (void)saveImage:(UIImage*)image filename:(NSString*)filename
{
    // 进到这里可以认为图片刚从往下下载了
    NSLog(@"Get the image:%@ from internet!", filename);
    
    // 将图片放到缓存中
    [imageCache setObject:image forKey:filename];
    
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:filename atomically:YES];
}

- (UIImage*)getImage:(NSString*)filename
{
    NSString *fileName = filename;
    // 先从缓存中获取数据，如果有就直接返回
    UIImage *image = [imageCache objectForKey:filename];
    if (image) {
        NSLog(@"Get the image:%@ from cache!", filename);
        return image;
    }
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    image = [UIImage imageWithData:data];
    
    // 当图片在沙盒中，但是没有在缓存中，将图片放到缓存
    if (image)
    {
        NSLog(@"Get the image：%@ from sandbox!", fileName);
        // 将图片放到缓存中
        [imageCache setObject:image forKey:fileName];
    }
    
    return image;
}

- (void)saveAlbums
{
    NSString *filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/albums.bin"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:albums];
    [data writeToFile:filename atomically:YES];
}

@end
