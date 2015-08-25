//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQPhotoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"


@interface JSQPhotoMediaItem ()

@property (strong, nonatomic) UIImageView *cachedImageView;

@end


@implementation JSQPhotoMediaItem

#pragma mark - Initialization

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = [image copy];
        _cachedImageView = nil;
    }
    return self;
}

- (void)dealloc
{
    _image = nil;
    _cachedImageView = nil;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    _image = [image copy];
    _cachedImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.image == nil) {
        return nil;
    }
    
    if (self.cachedImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIImage *image = [self fixOrientation:self.image];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = imageView;
    }
    
    return self.cachedImageView;
}

- (UIImage *)fixOrientation:(UIImage*)image {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.image.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.image, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQPhotoMediaItem *copy = [[[self class] allocWithZone:zone] initWithImage:self.image];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
