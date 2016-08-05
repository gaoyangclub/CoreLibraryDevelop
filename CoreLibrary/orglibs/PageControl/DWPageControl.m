//
//  DWPageControl.m
//  BestPalmPilot
//
//  Created by admin on 16/3/2.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "DWPageControl.h"

@implementation DWPageControl

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(id) initWithFrame:(CGRect)frame

{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _activeColor = [UIColor redColor];
        _inactiveColor = [UIColor lightGrayColor];
        _cornerRadius = 2;
    }
    return self;
}

-(void) updateDots

{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, _cornerRadius * 2, _cornerRadius * 2);
        dot.layer.cornerRadius = _cornerRadius;
        if (i == self.currentPage) {
            dot.backgroundColor = _activeColor;
        } else {
            dot.backgroundColor = _inactiveColor;
        }
        
    }
    
}

-(void) setCurrentPage:(NSInteger)page

{
    
    [super setCurrentPage:page];
    
    [self updateDots];
    
}


@end
