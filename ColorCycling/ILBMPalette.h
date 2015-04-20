//
//  ILBMPalette.h
//  ColorCycling
//
//  Created by James Campbell on 17/04/2015.
//  Copyright (c) 2015 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <unordered_map>
#import <vector>

class ILBMBitmap;

struct ILBMColor
{
    uint8_t r;
    uint8_t b;
    uint8_t g;
    uint8_t a;
};

typedef struct ILBMColor ILBMColor;

struct ILBMCycle
{
    float rate;
    int reverse;
    int low;
    int high;
};

typedef struct ILBMCycle ILBMCycle;

class ILBMPalette
{
    friend class ILBMBitmap;
    
private:
    std::vector<ILBMColor *> * reverseColorsForCycle(std::vector<ILBMColor *> *colors, ILBMCycle *cycle);
    std::vector<ILBMColor *> * blendShiftColorsForCycleAndCycleAmount(std::vector<ILBMColor *> *colors, ILBMCycle *cycle, float cycleAmount);
 
    std::unordered_map<NSInteger, ILBMColor *> *animatedColors;
    std::vector<ILBMColor *> *colors;
    std::vector<ILBMColor *> *colorFrameCache = nullptr;
    std::vector<ILBMCycle *> *cycles;
    
public:
    ILBMPalette();
    ~ILBMPalette();

    std::vector<ILBMColor *> * colorsForFrame(NSInteger frame);
};
