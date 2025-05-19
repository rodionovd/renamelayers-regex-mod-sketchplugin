//
//  IEReNaMeLaYeRsCaseModifier.h
//  ReNaMeLaYeRs
//
//  Created by Dmitry Rodionov on 19.05.2025.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface IEReNaMeLaYeRsCaseModifier: NSObject
@property (copy, readonly, nonnull) NSString *symbol;
- (NSString *_Nonnull)appliedToString:(NSString *_Nonnull)string;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (NSArray <IEReNaMeLaYeRsCaseModifier *> *_Nonnull)allCases;
@end

@interface IEReNaMeLaYeRsUppercaseModifier: IEReNaMeLaYeRsCaseModifier @end  // "Layer name" => "LAYER NAME"
@interface IEReNaMeLaYeRsLowercaseModifier: IEReNaMeLaYeRsCaseModifier @end  // "Layer name" => "layer name"
@interface IEReNaMeLaYeRsCapitalizeModifier: IEReNaMeLaYeRsCaseModifier @end // "Layer name" => "Layer Name"

NS_ASSUME_NONNULL_END
