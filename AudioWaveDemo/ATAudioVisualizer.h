

#import <UIKit/UIKit.h>

@interface ATAudioVisualizer : UIView

- (id) initWithBarsNumber:(NSInteger)barsCount frame:(CGRect)frame andColor:(UIColor *)color;
- (void) stopAudioVisualizer;
- (void) animateAudioVisualizerWithChannel0Level:(float)level0 andChannel1Level:(float)level1;


@end
