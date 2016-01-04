//
//  ILBMBitmap.m
//  ColorCycling
//
//  Created by James Campbell on 16/04/2015.
//  Copyright (c) 2015 CC. All rights reserved.
//

#import "ILBMBitmap.h"
#import "ILBMPalette.h"

ILBMBitmap::ILBMBitmap(std::string path)
{
    if (path.empty()) return;
    
    pallete = new ILBMPalette();
    
    NSString *objcPath = [NSString stringWithCString:path.c_str()
                                            encoding:NSUTF8StringEncoding];
    NSData *fileData = [NSData dataWithContentsOfFile:objcPath];
    
    NSError *error;
    NSDictionary *fileDictionary = [NSJSONSerialization JSONObjectWithData:fileData
                                                                   options:0
                                                                     error:&error];
    
    if (!error)
    {
        size = (CGSize)
        {
            [fileDictionary[@"width"] floatValue],
            [fileDictionary[@"height"] floatValue]
        };
        
        NSArray *fileColors = fileDictionary[@"colors"];
        [fileColors enumerateObjectsUsingBlock:^(NSArray *fileColor, NSUInteger idx, BOOL *stop)
         {
             ILBMColor *color = new ILBMColor({
                 .r = (uint8_t)[fileColor[0] intValue],
                 .b = (uint8_t)[fileColor[1] intValue],
                 .g = (uint8_t)[fileColor[2] intValue],
                 .a = 255
             });
             
             pallete->colors->push_back(color);
         }];
        
        NSArray *fileCycles = fileDictionary[@"cycles"];
        [fileCycles enumerateObjectsUsingBlock:^(NSDictionary *fileCycle, NSUInteger idx, BOOL *stop)
         {
             ILBMCycle *cycle = new ILBMCycle({
                 .rate = [fileCycle[@"rate"] floatValue],
                 .reverse = [fileCycle[@"reverse"] intValue],
                 .low = [fileCycle[@"low"] intValue],
                 .high = [fileCycle[@"high"] intValue]
             });
             
             for (NSInteger colorIndex = cycle->low; colorIndex <= cycle->high; colorIndex++)
             {
                 ILBMColor *color = pallete->colors->at(colorIndex);
                 
                 std::pair<NSInteger, ILBMColor *> animatedColorEntry (colorIndex, color);
                 pallete->animatedColors->insert(animatedColorEntry);
             }
             
             pallete->cycles->push_back(cycle);
         }];
        
        pixels = std::vector<int>();
        
        NSArray *filePixels = fileDictionary[@"pixels"];
        
        [filePixels enumerateObjectsUsingBlock:^(NSNumber *pixel, NSUInteger idx, BOOL *stop)
         {
             int pixelValue = [pixel intValue];
             pixels.push_back(pixelValue);
         }];
        
        optimize();
    }
    else
    {
        NSLog(@"Error loading bitmap: %@", error);
    }
}

ILBMBitmap::~ILBMBitmap()
{
    free(pallete);
    pallete = nullptr;
    
    free(pixelFrameCache);
    pixelFrameCache = nullptr;
}

CGSize ILBMBitmap::getSize()
{
    return size;
}

void ILBMBitmap::optimize()
{
    optimizedPixels = std::vector<int>();
    
    int totalPixels = (int)pixels.size();
    optimizedPixels.reserve(totalPixels);
    
    for (int pixelIndex = 0; pixelIndex < totalPixels; pixelIndex ++)
    {
        int pixelValue = pixels[pixelIndex];
        ILBMColor *animatedColor = pallete->animatedColors->operator[](pixelValue);
        
        if (animatedColor)
        {
            optimizedPixels.push_back(pixelIndex);
        }
    }
}

std::vector<ILBMColor> * ILBMBitmap::pixelsForFrame(int frame)
{
    NSInteger totalPixels = pixels.size();
    auto palletteColors = pallete->colorsForFrame(frame);
    
    if (!pixelFrameCache)
    {
        pixelFrameCache = new std::vector<ILBMColor>(totalPixels);
        
        for (NSInteger pixelIndex = 0; pixelIndex < totalPixels; pixelIndex ++)
        {
            NSInteger pixelValue = pixels[pixelIndex];
            ILBMColor *pixelColor = palletteColors->at(pixelValue);
            
            pixelFrameCache->at(pixelIndex) = *pixelColor;
        }
    }
    else
    {
        NSInteger totalOptimizedPixels = optimizedPixels.size();
        for (NSInteger optimizedPixelIndex = 0; optimizedPixelIndex < totalOptimizedPixels; optimizedPixelIndex ++)
        {
            NSInteger pixelIndex = optimizedPixels[optimizedPixelIndex];
            NSInteger pixelValue = pixels[pixelIndex];
            ILBMColor *pixelColor = palletteColors->at(pixelValue);
            
            pixelFrameCache->at(pixelIndex) = *pixelColor;
        }
    }
    
    return pixelFrameCache;
}