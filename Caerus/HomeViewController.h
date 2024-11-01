//
//  HomeViewController.h
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/04.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *games;
@property (strong, nonatomic) NSArray *filteredGames; // Filtered list of games based on search query

@end
