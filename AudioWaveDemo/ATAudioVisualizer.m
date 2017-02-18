

#import "ATAudioVisualizer.h"

#define animateDuration 0.15

@interface ATAudioVisualizer ()
{
    NSMutableArray *rectArray;
    NSMutableArray *waveFormArray;
    CGFloat initialBarHeight;

}

@property (nonatomic, strong) UIColor *visualizerColor;
@property (nonatomic, assign) NSInteger barsNumber;


@end

@implementation ATAudioVisualizer

- (id) initWithBarsNumber:(NSInteger)barsCount frame:(CGRect)frame andColor:(UIColor *)color
{
    self.barsNumber = barsCount;
    self.visualizerColor = color;
    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        [self addEqualizerBars];
    }
    
    return self;
}

- (void)updateWithLevel:(CGFloat)level
{
    
}

- (void) addEqualizerBars
{
    CGFloat padding = (self.frame.size.width / self.barsNumber) / 3;
    CGFloat rectHeight = self.frame.size.height-padding;
    CGFloat rectWidth = (self.frame.size.width-padding*(self.barsNumber+1))/self.barsNumber;
    rectArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *temp = [NSMutableArray new];
    
    for (int i = 0; i < self.barsNumber; i++)
    {
        UIView *rectangle = [[UIView alloc] init];
        CGRect rectFrame = CGRectMake(padding+(padding+rectWidth)*i,padding+(rectHeight-rectWidth),rectWidth,rectWidth);
        initialBarHeight = rectWidth;
        
        [temp addObject:[NSValue valueWithCGRect:rectFrame]];
        
        [rectangle setFrame:rectFrame];
        [rectangle setBackgroundColor:self.visualizerColor];
        rectangle.layer.cornerRadius = rectWidth / 2;
        
        [self addSubview:rectangle];
        [rectArray addObject:rectangle];
    }
    
    // add values for wave form
    NSArray *values = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:10], [NSNumber numberWithInt:15], [NSNumber numberWithInt:10], [NSNumber numberWithInt:5], [NSNumber numberWithInt:1], nil];
    
    waveFormArray = [[NSMutableArray alloc] init];
    int j = 0;
    for (int i = 0; i < self.barsNumber; i++)
    {
        [waveFormArray addObject:[values objectAtIndex:j]];
        j++;
        if (j == values.count) j = 0;
    }
}


- (void) animateAudioVisualizerWithChannel0Level:(float)level0 andChannel1Level:(float)level1
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:animateDuration
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             for (int i = 0; i < self.barsNumber; i++)
                             {
                                 int channelValue = arc4random_uniform(2); // random select channel 0 or channel 1
                                 int wavePeak = arc4random_uniform([[waveFormArray objectAtIndex:i] intValue]);
                                 
                                 UIView *barView = (UIView *)[rectArray objectAtIndex:i];
                                 
                                 CGRect barFrame = barView.frame;
                                 if (channelValue == 0)
                                 {
                                     barFrame.size.height = self.frame.size.height - (1 / level0 * 13) + wavePeak;
                                 }
                                 else
                                 {
                                     barFrame.size.height = self.frame.size.height - (1 / level1 * 13) + wavePeak;
                                 }
                                 
                                 if (barFrame.size.height < 4 || barFrame.size.height > self.frame.size.height) barFrame.size.height = initialBarHeight + wavePeak;
                                 barFrame.origin.y = self.frame.size.height - barFrame.size.height;
                                 barView.frame = barFrame;
                             }
                         }
                         completion:nil];
    });
}

- (void) stopAudioVisualizer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:animateDuration
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             for (int i = 0; i < self.barsNumber; i++)
                             {
                                 UIView *barView = (UIView *)[rectArray objectAtIndex:i];
                                 CGRect barFrame = barView.frame;
                                 barFrame.size.height = initialBarHeight;
                                 barFrame.origin.y = self.frame.size.height - barFrame.size.height;
                                 barView.frame = barFrame;
                             }
                         }
                         completion:nil];
    });
}

@end
