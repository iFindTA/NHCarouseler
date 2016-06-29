//
//  NHCarouseler.h
//  NHCarouseler
//
//  Created by hu jiaju on 16/6/7.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NHCarouselerCell;
@protocol NHCarouselerDelegate;
@protocol NHCarouselerDataSource;
@interface NHCarouseler : UIView

@property (nonatomic, weak) id<NHCarouselerDataSource> dataSource;
@property (nonatomic, weak) id<NHCarouselerDelegate> delegate;

/**
 *  @brief <#Description#>
 *
 *  @param identifier <#identifier description#>
 *
 *  @return <#return value description#>
 */
- (NHCarouselerCell *)dequeueReusablePageWithIdentifier:(NSString *)identifier;

/**
 *  @brief refresh carouseler
 */
- (void)reloadData;

@end

@protocol NHCarouselerDelegate <NSObject>
@optional
- (void)carouseler:(NHCarouseler *)view willDismissIndex:(NSUInteger)index;
- (void)carouseler:(NHCarouseler *)view didChangeToIndex:(NSUInteger)index;

- (void)carouseler:(NHCarouseler *)view didSelectedIndex:(NSUInteger)index;

@end

@protocol NHCarouselerDataSource <NSObject>
@required
- (NSInteger)numberOfRowsForCarouseler:(NHCarouseler *)carouseler;
- (NHCarouselerCell *)carouseler:(NHCarouseler *)view cellForRowIndex:(NSUInteger)index;

@end

@interface NHCarouselerCell : UIView//<NSCopying,NSMutableCopying>

- (NHCarouselerCell *)initWithIdentifier:(NSString *)identifier;

@property (nonatomic, copy, readonly) NSString *identifier;

@end


NS_ASSUME_NONNULL_END