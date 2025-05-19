//
//  IEReNaMeLaYeRsCaseModifier.m
//  ReNaMeLaYeRs
//
//  Created by Dmitry Rodionov on 19.05.2025.
//

#import "IEReNaMeLaYeRsCaseModifier.h"

@implementation IEReNaMeLaYeRsCaseModifier

+ (NSArray <IEReNaMeLaYeRsCaseModifier *> *)allCases
{
    return @[
        IEReNaMeLaYeRsUppercaseModifier.new,
        IEReNaMeLaYeRsLowercaseModifier.new,
        IEReNaMeLaYeRsCapitalizeModifier.new
    ];
}

- (NSString *)symbol
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"-symbol must be implemented in subclasses" userInfo:nil];
}

- (NSString *)appliedToString:(NSString *)string
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"-appliedToString: must be implemented in subclasses" userInfo:nil];
}
@end

@implementation IEReNaMeLaYeRsUppercaseModifier
- (NSString *)symbol
{
    return @"^";
}
- (NSString *)appliedToString:(NSString *)string
{
    return [string localizedUppercaseString];
}
@end

@implementation IEReNaMeLaYeRsLowercaseModifier
- (NSString *)symbol
{
    return @".";
}
- (NSString *)appliedToString:(NSString *)string
{
    return [string localizedLowercaseString];
}
@end

@implementation IEReNaMeLaYeRsCapitalizeModifier
- (NSString *)symbol
{
    return @"-";
}
- (NSString *)appliedToString:(NSString *)string
{
    return [string localizedCapitalizedString];
}
@end
