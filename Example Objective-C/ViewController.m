#import "ViewController.h"
@import Palette;

@interface ViewController ()
@property (copy, nonatomic) NSArray<UIView *> *backgrounds;
@property (copy, nonatomic) NSArray<UILabel *> *labels;
@property (copy, nonatomic) NSArray<NSString *> *names;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    UIStackView *content = [[UIStackView alloc] init];
    content.axis = UILayoutConstraintAxisVertical;
    content.spacing = 8;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [content.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:20],
        [content.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-20],
        [content.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:20],
        [content.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-20],
        [content.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor constant:-40]
    ]];
    UILabel *title = [[UILabel alloc] init];
    title.text = @"Palette";
    title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle];
    title.adjustsFontForContentSizeCategory = YES;
    [content addArrangedSubview:title];
    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"Objective-C · Foreground chosen from each background";
    subtitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    subtitle.textColor = UIColor.secondaryLabelColor;
    subtitle.numberOfLines = 0;
    subtitle.adjustsFontForContentSizeCategory = YES;
    [content addArrangedSubview:subtitle];
    [content setCustomSpacing:20 afterView:subtitle];

    self.names = @[@"System background", @"Red · #FF0000", @"Orange · #FF8000",
                   @"Yellow · #FFFF00", @"Green · #00FF00", @"Cyan · #00FFFF",
                   @"Blue · #0000FF", @"Purple · #800080"];
    NSArray<UIColor *> *colors = @[
        UIColor.systemBackgroundColor, UIColor.redColor,
        [UIColor colorWithRed:1 green:0.5 blue:0 alpha:1],
        UIColor.yellowColor, UIColor.greenColor, UIColor.cyanColor, UIColor.blueColor,
        [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:1]
    ];
    NSMutableArray<UIView *> *backgrounds = [NSMutableArray array];
    NSMutableArray<UILabel *> *labels = [NSMutableArray array];
    for (NSUInteger index = 0; index < colors.count; index++) {
        UIView *background = [[UIView alloc] init];
        background.backgroundColor = colors[index];
        background.layer.cornerRadius = 12;
        background.layer.borderWidth = 1;
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        label.adjustsFontForContentSizeCategory = YES;
        label.numberOfLines = 0;
        label.text = self.names[index];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [background addSubview:label];
        [NSLayoutConstraint activateConstraints:@[
            [background.heightAnchor constraintGreaterThanOrEqualToConstant:64],
            [label.topAnchor constraintEqualToAnchor:background.topAnchor constant:12],
            [label.bottomAnchor constraintEqualToAnchor:background.bottomAnchor constant:-12],
            [label.leadingAnchor constraintEqualToAnchor:background.leadingAnchor constant:16],
            [label.trailingAnchor constraintEqualToAnchor:background.trailingAnchor constant:-16]
        ]];
        [content addArrangedSubview:background];
        [backgrounds addObject:background];
        [labels addObject:label];
    }
    self.backgrounds = backgrounds;
    self.labels = labels;
    if (@available(iOS 17.0, *)) {
        [self registerForTraitChanges:@[[UITraitUserInterfaceStyle class]]
                          withAction:@selector(appearanceDidChange)];
    }
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
    for (NSUInteger index = 0; index < self.backgrounds.count; index++) {
        UIView *background = self.backgrounds[index];
        UILabel *label = self.labels[index];
        background.layer.borderColor = [UIColor.separatorColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
        Palette *palette = [[Palette alloc] initWithBackground:background forView:label];
        UIColor *foreground = [palette getContrastingColor];
        label.textColor = foreground;
        NSString *text = [NSString stringWithFormat:@"%@\n%@ foreground", self.names[index],
                          [foreground isEqual:UIColor.blackColor] ? @"Black" : @"White"];
        if (![label.text isEqualToString:text]) {
            label.text = text;
        }
        NSAssert([foreground isEqual:[Palette getContrastingColor:background forView:label]],
                 @"Instance and class Objective-C APIs must agree");
    }
}

@end
