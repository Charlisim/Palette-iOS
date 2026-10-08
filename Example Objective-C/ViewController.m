#import "ViewController.h"
@import Palette;

@interface ViewController ()
@property (strong, nonatomic) UILabel *contrastLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 17.0, *)) {
        [self registerForTraitChanges:@[[UITraitUserInterfaceStyle class]]
                          withAction:@selector(appearanceDidChange)];
    }
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.contrastLabel = [[UILabel alloc] init];
    self.contrastLabel.text = @"Palette Objective-C example";
    self.contrastLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    self.contrastLabel.adjustsFontForContentSizeCategory = YES;
    self.contrastLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.contrastLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.contrastLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.contrastLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)appearanceDidChange {
    [self.view setNeedsLayout];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 17.0, *)) {
        return;
    }
    [self.view setNeedsLayout];
}
#pragma clang diagnostic pop

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    Palette *palette = [[Palette alloc] initWithBackground:self.view forView:self.contrastLabel];
    self.contrastLabel.textColor = [palette getContrastingColor];
    NSAssert([self.contrastLabel.textColor isEqual:[Palette getContrastingColor:self.view forView:self.contrastLabel]],
             @"Instance and class Objective-C APIs must agree");
}

@end
