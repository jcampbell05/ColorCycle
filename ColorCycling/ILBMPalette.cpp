//
//  ILBMPalette.m
//  ColorCycling
//
//  Created by James Campbell on 17/04/2015.
//  Copyright (c) 2015 CC. All rights reserved.
//

#import "ILBMPalette.h"

ILBMPalette::ILBMPalette()
{
    animatedColors = new std::unordered_map<int, ILBMColor *>();
    colors = new std::vector<ILBMColor *>();
    cycles = new std::vector<ILBMCycle *>();
}

ILBMPalette::~ILBMPalette()
{
    free(animatedColors);
    animatedColors = nullptr;
    
    free(colors);
    colors = nullptr;
    
    free(colorFrameCache);
    colorFrameCache = nullptr;

    free(cycles);
    cycles = nullptr;
}

std::vector<ILBMColor *> * ILBMPalette::colorsForFrame(int frame)
{
    if (!colorFrameCache)
    {
        colorFrameCache = new std::vector<ILBMColor *>(*colors);
    }
    
    for (auto iterator = cycles->begin(); iterator != cycles->end(); iterator ++)
    {
        ILBMCycle *cycle = *iterator;
        
        if (cycle->rate)
        {
            int cycleSize = (cycle->high - cycle->low) + 1;
            int cycleAmount = 0;
            
            // standard cycle
            if (cycle->reverse < 3)
            {
                cycleAmount = fmod(frame, cycleSize);
            }
            
            // ping-pong
            else if (cycle->reverse == 3)
            {
                cycleAmount = fmod(frame, cycleSize * 2);
            
                if (cycleAmount >= cycleSize)
                {
                   cycleAmount = (cycleSize * 2) - cycleAmount;
                }
            }
            
            // sine wave
            else if (cycle->reverse < 6)
            {
                cycleAmount = fmod(frame, cycleSize);
                cycleAmount = sinf((cycleAmount * M_PI * 2) / cycleSize) + 1;
                
                if (cycle->reverse == 4)
                {
                    cycleAmount *= (cycleSize / 4);
                }
                else if (cycle->reverse == 5)
                {
                    cycleAmount *= (cycleSize / 2);
                }
            }

            if (cycle->reverse == 2)
            {
               colorFrameCache = reverseColorsForCycle(colors, cycle);
            }
        
            for (int index = cycle->low; index <= cycle->high; index++)
            {
                int newIndex = index + cycleAmount;
                
                if (newIndex > cycle->high)
                {
                    int indexOverflowAmount = fmodf(newIndex, cycle->high);
                    newIndex = cycle->low + (indexOverflowAmount - 1);
                }
                
                colorFrameCache->at(newIndex) = colors->at(index);
            }
            
            if (cycle->reverse == 2)
            {
               colorFrameCache = reverseColorsForCycle(colors, cycle);
            }
        }
    }
    
    return colorFrameCache;
}

std::vector<ILBMColor *> * ILBMPalette::reverseColorsForCycle(std::vector<ILBMColor *> *colors, ILBMCycle *cycle)
{
    int cycleSize = (cycle->high - cycle->low) + 1;
    
    for (int index = 0; index < cycleSize / 2; index++)
    {
        int lowIndex = cycle->low + index;
        int highIndex = cycle->high - index;
        
        ILBMColor *lowColor = colors->at(lowIndex);
        ILBMColor *highColor = colors->at(highIndex);
        
        colorFrameCache->at(lowIndex) = highColor;
        colorFrameCache->at(highIndex) = lowColor;
    }
    
    return colorFrameCache;
}