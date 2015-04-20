//
//  ViewController.m
//  ColorCycling
//
//  Created by James Campbell on 16/04/2015.
//  Copyright (c) 2015 CC. All rights reserved.
//

#import "ViewController.h"
#import "ILBMBitmap.h"

static double const ILBMFrameDuration = 1.0 / 25.0;

@interface ViewController ()
{
    ILBMBitmap *bitmap;
    NSInteger frame;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSTimer *updateTimer;

- (void)updateImage;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.updateTimer = [NSTimer timerWithTimeInterval:ILBMFrameDuration
                                               target:self
                                             selector:@selector(updateImage)
                                             userInfo:nil
                                              repeats:YES];
    
    [self.view addSubview:self.imageView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TESTRAMP"
                                                     ofType:@"json"];
    bitmap = new ILBMBitmap(std::string(path.UTF8String));
    frame = 0;
    
    [self updateImage];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer
                              forMode:NSRunLoopCommonModes];
}


- (void)updateImage
{
    CGSize size = bitmap->getSize();
    auto pixels = bitmap->pixelsForFrame(frame);

    ILBMPixel *rawPixels = pixels->data();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Add 1 for the alpha channel
    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace) + 1;
    
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = (bitsPerComponent * numberOfComponents) / 8;
    size_t bytesPerRow = bytesPerPixel * size.width;
    
    CGContextRef contextRef = CGBitmapContextCreate(rawPixels,
                                                   size.width,
                                                   size.height,
                                                   bitsPerComponent,
                                                   bytesPerRow,
                                                   colorSpace,
                                                   kCGImageAlphaNoneSkipLast);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    UIImage* image = [UIImage imageWithCGImage:imageRef];
    
    self.imageView.image = image;
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    
    frame ++;
}

- (void)dealloc
{
    free(bitmap);
    bitmap = nullptr;
}

@end
