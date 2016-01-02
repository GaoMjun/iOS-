//
//  ViewController.m
//  yanzhengma
//
//  Created by ll on 1/2/16.
//  Copyright © 2016 ll. All rights reserved.
//

#import "ViewController.h"

#define Mask8(x) ( (x) & 0xFF ) 
#define R(x) ( Mask8(x) ) 
#define G(x) ( Mask8(x >> 8 ) ) 
#define B(x) ( Mask8(x >> 16) ) 
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *originVerityCodeImage;
@property (weak, nonatomic) IBOutlet UIImageView *splitedVeirityCodeImage;

@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGImageRef imageRef = [UIImage imageNamed:@"verityCodeImage"].CGImage;
    
    CGImageRef image = CGImageCreateWithImageInRect(imageRef, CGRectMake(6, 4, 47, 12));
    _splitedVeirityCodeImage.image = [UIImage imageWithCGImage:image];
    
    CGImageRef imageRef1 = CGImageCreateWithImageInRect(imageRef, CGRectMake(6, 4, 8, 12));
    _image1.image = [self operatePixelInImage:imageRef1];
    _label1.text = [self compareWithReference:_image1.image];
    
    CGImageRef imageRef2 = CGImageCreateWithImageInRect(imageRef, CGRectMake(6+8+5, 4, 8, 12));
    _image2.image = [self operatePixelInImage:imageRef2];
    _label2.text = [self compareWithReference:_image2.image];
    
    CGImageRef imageRef3 = CGImageCreateWithImageInRect(imageRef, CGRectMake(6+8+5 +8+5, 4, 8, 12));
    _image3.image = [self operatePixelInImage:imageRef3];
    _label3.text = [self compareWithReference:_image3.image];
    
    CGImageRef imageRef4 = CGImageCreateWithImageInRect(imageRef, CGRectMake(6+8+5 +8+5 +8+5, 4, 8, 12));
    _image4.image = [self operatePixelInImage:imageRef4];
    _label4.text = [self compareWithReference:_image4.image];
    
//    CGImageRelease(imageRef);
    CGImageRelease(image);
    CGImageRelease(imageRef1);
    CGImageRelease(imageRef2);
    CGImageRelease(imageRef3);
    CGImageRelease(imageRef4);
    
}



- (UIImage *) operatePixelInImage:(CGImageRef)image
{
    NSUInteger width = 8;
    NSUInteger height = 12;
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 *pixels = (UInt32 *)calloc(height * width, sizeof(UInt32));
    
    CGContextRef context = CGBitmapContextCreate(pixels, 
                                                 width, 
                                                 height, 
                                                 bitsPerComponent, 
                                                 bytesPerRow, 
                                                 CGColorSpaceCreateDeviceRGB(), 
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    UInt32 *currentPixel = pixels;
    for (NSUInteger i = 0; i < height; i++) {
        for (NSUInteger j = 0; j < width; j++) {
            UInt32 color = *currentPixel;
            
            UInt8 r = R(color);
            UInt8 g = G(color);
            UInt8 b = B(color);
            UInt32 l = (r + g + b) / 3;

            if (l <= 150) {
                l = 0;
            } else {
                l = 255;
            }
            
            *currentPixel = RGBAMake(l, l, l, 0xff);
            
            currentPixel++;
        }
        
    }
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    
    UIImage *newImage = [UIImage imageWithCGImage:newCGImage];
    
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    free(pixels);
    
    return newImage;
}

- (NSString *) compareWithReference:(UIImage *)image
{
    NSString *numStr = nil;
    
    CGImageRef cgImage = image.CGImage;
    
    NSUInteger width = 8;
    NSUInteger height = 12;
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 *pixels = (UInt32 *)calloc(height * width, sizeof(UInt32));
    UInt32 *refPixels = (UInt32 *)calloc(height * width, sizeof(UInt32));
    
    for (int i = 0; i < 10; i++) {
        int n = 0;
        
        CGImageRef refImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d", i]].CGImage;
        
        CGContextRef context = CGBitmapContextCreate(pixels, 
                                                     width, 
                                                     height, 
                                                     bitsPerComponent, 
                                                     bytesPerRow, 
                                                     CGColorSpaceCreateDeviceRGB(), 
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        
        CGContextRef refContext = CGBitmapContextCreate(refPixels, 
                                                         width, 
                                                         height, 
                                                         bitsPerComponent, 
                                                         bytesPerRow, 
                                                         CGColorSpaceCreateDeviceRGB(), 
                                                         kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
        CGContextDrawImage(refContext, CGRectMake(0, 0, width, height), refImage);
        
        UInt32 *currentPixel = pixels;
        UInt32 *currentRefPixel = refPixels;
        for (NSUInteger i = 0; i < height; i++) {
            for (NSUInteger j = 0; j < width; j++) {
                UInt32 color = *currentPixel;
                UInt32 refColor = *currentRefPixel;
                
                UInt8 r = R(color);
                UInt8 g = G(color);
                UInt8 b = B(color);
                UInt32 l = (r + g + b) / 3;
                
                UInt8 rr = R(refColor);
                UInt8 gg = G(refColor);
                UInt8 bb = B(refColor);
                UInt32 ll = (rr + gg + bb) / 3;
                
                if ((l-ll) <= 50 || (ll-l) <= 50) {
                    n++;
                }
                
                currentPixel++;
                currentRefPixel++;
            }
            
        }
        
        if (n >= 90) {
            numStr = [NSString stringWithFormat:@"%d", i];
        }
        
        printf("%d ", n);
        
        CGContextRelease(context);
        CGContextRelease(refContext);
//        CGImageRelease(refImage);
        
    }
    printf("\n");
    
    CGImageRelease(cgImage);
    free(pixels);
    free(refPixels);
    
    return numStr;
}

@end








