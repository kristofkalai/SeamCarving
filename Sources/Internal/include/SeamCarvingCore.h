//
//  SeamCarvingCore.h
//
//
//  Created by Kristóf Kálai on 29/10/2023.
//

#ifndef SeamCarvingCore_h
#define SeamCarvingCore_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SeamCarvingCore : NSObject
- (id _Nonnull)initWithImage:(UIImage *_Nonnull)image;
- (UIImage *_Nonnull)carve;
@end

NS_ASSUME_NONNULL_END

#endif /* SeamCarvingCore_h */
