//
//  HomeViewController.m
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/04.
//

#import "HomeViewController.h"
#import "SDLViewController.h"

@interface HomeViewController () <UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation HomeViewController

// Uncomment the following line to enable iPad auto-rotation support
#define ENABLE_IPADAUTOROTATE 0

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load the generic Chippy placeholder game image
    UIImage *defaultImage = [UIImage new];
    
    // Sample game data and images
    self.games = @[
        @{@"name": @"Game 1", @"image": defaultImage},
        @{@"name": @"Game 2", @"image": defaultImage},
        @{@"name": @"Game 3", @"image": defaultImage},
        @{@"name": @"Game 4", @"image": defaultImage},
        @{@"name": @"Game 5", @"image": defaultImage},
        @{@"name": @"Game 6", @"image": defaultImage},
        @{@"name": @"Game 7", @"image": defaultImage},
        @{@"name": @"Game 8", @"image": defaultImage}
    ];
    
    // Initialize filteredGames with the full list initially
    self.filteredGames = self.games;
    
    // Set up the navigation bar
    [self setupNavigationBar];
    
    // Set up the layout for the collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 10; // Space between rows
    layout.minimumInteritemSpacing = 10; // Space between items

    // Set section insets for left and right margins
    CGFloat leftRightMargin = 20.0;
    layout.sectionInset = UIEdgeInsetsMake(10, leftRightMargin, 10, leftRightMargin); // top, left, bottom, right

    // Initialize the collection view
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    if (@available(iOS 13.0, *)) {
        self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.collectionView.backgroundColor = [UIColor whiteColor];
    }

    // Enable scrolling
    self.collectionView.alwaysBounceVertical = YES;

    // Register a cell class
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"GameCell"];

    [self.view addSubview:self.collectionView];
}

- (void)setupNavigationBar {
    // Set the title for the navigation bar
    self.navigationItem.title = @"Games";

    // Create and configure the search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search for games";
    self.navigationItem.titleView = self.searchBar;

    // Create the "plus" button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGame)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)addGame {
    // This is where you would handle adding a new game
    NSLog(@"Plus button tapped - add new game.");
}

#pragma mark - UICollectionView DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.games.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GameCell" forIndexPath:indexPath];

    // Clear previous views if any
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }

    // Game data
    NSDictionary *gameData = self.games[indexPath.item];
    NSString *gameName = gameData[@"name"];
    UIImage *gameImage = gameData[@"image"];
    
    // Create image view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:gameImage];
    imageView.backgroundColor = [UIColor lightGrayColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = 10; // Rounded corners
    imageView.translatesAutoresizingMaskIntoConstraints = NO;

    // Create label
    UILabel *label = [[UILabel alloc] init];
    label.text = gameName;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;

    // Add image view and label to cell
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:label];

    // Setup constraints for image view and label
    [NSLayoutConstraint activateConstraints:@[
        [imageView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor],
        [imageView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor],
        [imageView.heightAnchor constraintEqualToAnchor:cell.contentView.heightAnchor multiplier:0.75], // Image takes 75% height
        [label.topAnchor constraintEqualToAnchor:imageView.bottomAnchor],
        [label.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor],
        [label.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor],
        [label.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor]
    ]];

    return cell;
}

#pragma mark - UICollectionView Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedGame = self.games[indexPath.item][@"name"];
    NSLog(@"Selected Game: %@", selectedGame);
    
    // Handle the selection (e.g., navigate to game details)
    SDLViewController *sdlVC = [[SDLViewController alloc] init];
    [self.navigationController pushViewController:sdlVC animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Calculate the width based on the number of items you want per row
    CGFloat padding = 20; // total padding (left + right)
    CGFloat totalWidth = CGRectGetWidth(collectionView.frame) - padding - (20 * 2); // account for section insets
    
    NSInteger itemsPerRow = [self itemsPerRowForCurrentOrientation]; // Adjust items based on orientation
    CGFloat itemWidth = totalWidth / itemsPerRow;

    return CGSizeMake(itemWidth, itemWidth + 40); // Square cells + extra height for the label
}

#pragma mark - Helper Method for Items Per Row

- (NSInteger)itemsPerRowForCurrentOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? 4 : 3; // 4 in landscape, 3 in portrait
    } else {
        return 3; // Default for iPhone
    }
}

#pragma mark - iPad Rotation Handling

#if ENABLE_IPADAUTOROTATE
// Override to handle orientation changes
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // Invalidate the layout to re-calculate the sizes
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout]; // Ensure layout is valid after view layout changes
}
#endif

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [UIViewController attemptRotationToDeviceOrientation];
}

@end
