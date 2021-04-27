#include "AVCWidget.h"

@interface AVCSpotifyWidget : AVCWidget
@property (nonatomic, strong, readwrite) UILabel *title;
@property (nonatomic, strong, readwrite) UILabel *subtitle;
@property (nonatomic, strong, readwrite) UIImageView *background;
@property (nonatomic, strong, readwrite) UIButton *playButton;
@end
