//
//  ILBMBitmap.h
//  ColorCycling
//
//  Created by James Campbell on 16/04/2015.
//  Copyright (c) 2015 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import <string>
#import <vector>

#import "ILBMPalette.h"

typedef ILBMColor ILBMPixel;

class ILBMBitmap
{
private:
    
    ILBMPalette *pallete;
    std::vector<int> pixels;
    std::vector<int> optimizedPixels;
    std::vector<ILBMColor> *pixelFrameCache = nullptr;
    
    CGSize size;
    void optimize();
    
public:
    
    ILBMBitmap(std::string path);
    ~ILBMBitmap();
    
    CGSize getSize();
    std::vector<ILBMPixel> * pixelsForFrame(int frame);
};