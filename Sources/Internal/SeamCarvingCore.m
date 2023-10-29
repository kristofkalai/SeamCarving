//
//  SeamCarvingCore.m
//
//
//  Created by Kristóf Kálai on 29/10/2023.
//

#import <UIKit/UIKit.h>
#import "SeamCarvingCore.h"

typedef struct {
    double sofar;
    int direction;
}CarvingCache;

@interface SeamCarvingCore ()
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic) const UInt8 *pointer;
@property (nonatomic) double *grayscale;
@property (nonatomic) double *gradient;
@property (nonatomic) CFDataRef data;
@end

@implementation SeamCarvingCore
- (id _Nonnull)initWithImage:(UIImage *_Nonnull)image {
    self = [super init];
    self.image = image;
    self.width = image.size.width;
    self.height = image.size.height;
    if (_width > 1 && _height > 1) {
        CGImageRef imgRef = [image CGImage];
        CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(imgRef));
        self.pointer = CFDataGetBytePtr(data);
        self.data = data;
        [self buildGrayScale];
        [self buildGradient];
    }
    return self;
}

- (void)buildGrayScale {
    self.grayscale = malloc(sizeof(double) * _height * _width);
    int i, j;
    for (i = 0; i < _height; i++) {
        for (j = 0; j < _width; j++) {
            double *this = _grayscale + i * _width + j;
            const UInt8 *rgb = [self rgbPointerAtRow:i column:j];
            *this = 0.33 * rgb[0] + 0.59 * rgb[1] + 0.11 * rgb[2];
        }
    }
}

- (void)buildGradient {
    self.gradient = malloc(sizeof(double) * _height * _width);
    long i, j;
    for (i = 1; i < _height - 1; i++) {
        for (j = 1; j < _width - 1; j++) {
            double *this = _gradient + i * _width + j;
            *this = fabs([self grayAtRow:i-1 column:j] - [self grayAtRow:i+1 column:j]) + fabs([self grayAtRow:i column:j-1] - [self grayAtRow:i column:j+1]);
        }
    }
    i = 0;
    for (j = 1; j < _width - 1; j++) {
        double *this = _gradient + i * self.width + j;
        *this = fabs([self grayAtRow:i column:j] - [self grayAtRow:i+1 column:j]) * 0.5 + fabs([self grayAtRow:i column:j-1] - [self grayAtRow:i column:j+1]);
    }
    i = self.height - 1;
    for (j = 1; j < _width - 1; j++) {
        double *this = _gradient + i * _width + j;
        *this = fabs([self grayAtRow:i column:j] - [self grayAtRow:i-1 column:j]) * 0.5 + fabs([self grayAtRow:i column:j-1] - [self grayAtRow:i column:j+1]);
    }
    j = 0;
    for (i = 1; i < _height - 1; i++) {
        double *this = _gradient + i * _width + j;
        *this = fabs([self grayAtRow:i+1 column:j] - [self grayAtRow:i-1 column:j]) + fabs([self grayAtRow:i column:j] - [self grayAtRow:i column:j+1]) * 0.5;
    }
    j = _width - 1;
    for (i = 1; i < _height - 1; i++) {
        double *this = _gradient + i * _width + j;
        *this = fabs([self grayAtRow:i+1 column:j] - [self grayAtRow:i-1 column:j]) + fabs([self grayAtRow:i column:j-1] - [self grayAtRow:i column:j]) * 0.5;
    }

    i = 0; j = 0;
    double *this = _gradient + i * _width + j;
    *this = fabs([self grayAtRow:i+1 column:j] - [self grayAtRow:i column:j]) * 0.5 + fabs([self grayAtRow:i column:j+1] - [self grayAtRow:i column:j]) * 0.5;

    i = 0; j = _width - 1;
    this = _gradient + i * _width + j;
    *this = fabs([self grayAtRow:i+1 column:j] - [self grayAtRow:i column:j]) * 0.5 + fabs([self grayAtRow:i column:j-1] - [self grayAtRow:i column:j]) * 0.5;

    i = _height - 1; j = 0;
    this = _gradient + i * _width + j;
    *this = fabs([self grayAtRow:i-1 column:j] - [self grayAtRow:i column:j]) * 0.5 + fabs([self grayAtRow:i column:j+1] - [self grayAtRow:i column:j]) * 0.5;

    i = _height - 1; j = _width - 1;
    this = _gradient + i * _width + j;
    *this = fabs([self grayAtRow:i-1 column:j] - [self grayAtRow:i column:j]) * 0.5 + fabs([self grayAtRow:i column:j-1] - [self grayAtRow:i column:j]) * 0.5;
}

- (double)gradientAtRow:(NSInteger)i column:(NSInteger)j {
    return *(_gradient + i * _width + j);
}

- (double)grayAtRow:(NSInteger)i column:(NSInteger)j {
    return *(_grayscale + i * _width + j);
}

- (const UInt8 *)rgbPointerAtRow:(NSInteger)i column:(NSInteger)j {
    return _pointer + 4 * i * _width + 4 * j;
}

- (UIColor *)pixelAtRow:(NSInteger)row column:(NSInteger)column {
    const UInt8 *ptr = _pointer + 4 * row * _width + 4 * column;
    return [[UIColor alloc] initWithRed:ptr[0] green:ptr[1] blue:ptr[2] alpha:255];
}

- (UIImage *_Nonnull)carve {
    if (_width <= 1 || _height <= 1) {
        return _image;
    }
    CarvingCache *cache[_height];
    for (int i = 0; i < _height; i++) {
        cache[i] = malloc(sizeof(CarvingCache) * _width);
    }
    long i, j;
    for (j = 0; j < _width; j++) {
        cache[0][j].sofar = [self gradientAtRow:0 column:j];
    }
    for (i = 1; i < _height; i++) {
        for (j = 1; j < _width - 1; j++) {
            int d = 0;
            int ii;
            double thisG = [self gradientAtRow:i column:j];
            double best = cache[i - 1][j].sofar + [self gradientAtRow:i column:j];
            for (ii = -1; ii <= 1; ii += 2) {
                double t =cache[i - 1][j + ii].sofar + thisG;
                if (t < best) {
                    best = t;
                    d = ii;
                }
            }
            cache[i][j].sofar = best;
            cache[i][j].direction = d;
        }
        {
            j = 0;
            int ii;
            int d = 0;
            double thisG = [self gradientAtRow:i column:j];
            double best = cache[i - 1][j].sofar + [self gradientAtRow:i column:j];
            for (ii = 1; ii <= 1; ii += 2) {
                double t =cache[i - 1][j + ii].sofar + thisG;
                if (t < best) {
                    best = t;
                    d = ii;
                }
            }
            cache[i][j].sofar = best;
            cache[i][j].direction = d;
        }
        {
            int d = 0;
            j = _width - 1;
            double thisG =[self gradientAtRow:i column:j];
            double best = cache[i - 1][j].sofar + [self gradientAtRow:i column:j];
            int ii;
            for (ii = -1; ii <= -1; ii += 2) {
                double t =cache[i - 1][j + ii].sofar  + thisG;
                if (t < best) {
                    best = t;
                    d = ii;
                }
            }
            cache[i][j].sofar = best;
            cache[i][j].direction = d;
        }
    }
    int *carved = malloc(sizeof(int) * _height * _width);
    i = _height - 1;
    double best = cache[i][0].sofar;
    carved[i] = 0;
    for (j = 0; j < _width; j++) {
        if (cache[i][j].sofar < best) {
            best = cache[i][j].sofar;
            carved[i] = (int)j;
        }
    }
    for (i = _height - 2; i >= 0; i--) {
        carved[i] = cache[i+1][carved[i + 1]].direction + carved[i + 1];
    }
    UInt8 *rawBytes = malloc(sizeof(UInt8) * _height * _width * 4);
    UInt8 *inputPtr = rawBytes;
    const UInt8 *originPtr = _pointer;
    for (i = 0; i < _height; i++) {
        for (j = 0; j < _width; j++, originPtr += 4) {
            if (carved[i] == j) {
                continue;
            }
            inputPtr[0] = originPtr[0];
            inputPtr[1] = originPtr[1];
            inputPtr[2] = originPtr[2];
            inputPtr[3] = originPtr[3];
            inputPtr += 4;
        }
    }
    CFDataRef rawData = CFDataCreate(NULL, rawBytes, (_width - 1) * 4 * (_height));
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(rawData);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = CGImageCreate(_width - 1, _height, 8, 32, (_width - 1) * 4, colorSpace, 5, provider, NULL, NO, kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *carvedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    free(carved);
    for (i = 0; i < _height; i++) {
        free(cache[i]);
    }
    free(rawBytes);
    CFRelease(rawData);
    CGDataProviderRelease(provider);
    return carvedImage;
}

- (void)dealloc {
    if (_gradient) {
        free(_gradient);
    }
    if (_grayscale) {
        free(_grayscale);
    }
    if (_data) {
        CFRelease(_data);
    }
}

@end
