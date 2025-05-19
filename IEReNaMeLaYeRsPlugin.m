//
//  IEReNaMeLaYeRsPlugin.m
//  ReNaMe LaYeRs
//
//  Created by Dmitry Rodionov on 17.05.2025.
//

#import "IEReNaMeLaYeRsPlugin.h"
#import "RSSwizzle/RSSwizzle.h"

static BOOL pluginIsEnabled = NO;
static const void *NSRegularExpressionSwizzleKey = &NSRegularExpressionSwizzleKey;

@implementation IEReNaMeLaYeRsPlugin

+ (BOOL)enabled
{
    return pluginIsEnabled;
}

+ (void)setEnabled:(BOOL)isEnabled
{
    if (pluginIsEnabled == isEnabled) { return; }
    pluginIsEnabled = isEnabled;

    if (pluginIsEnabled) {
        [self install];
    }
}

+ (void)install
{
    // So the main idea was to re-implement this NSRegularExpression's bit from scratch to
    // add support for optional case modifiers for capture groups referenced in the template.
    // These modifiers will affect how the corresponding capture group would be rendered as a result, e.g.:
    //
    //  $1  -- no changes, expand this capture group as is
    //  $-1 -- expand this capture group and then capitalize it
    //  $^1 -- expand this capture group and then make it uppercase
    //  $.1 -- expand this capture group and then make it lowercase
    [RSSwizzle swizzleInstanceMethod:@selector(replacementStringForResult:inString:offset:template:)
                             inClass:NSRegularExpression.class
                       newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
        return ^NSString *(__unsafe_unretained NSRegularExpression *self, NSTextCheckingResult *match, NSString *input,
                           NSInteger offset, NSString *template) {
            NSString *(*originalIMP)(__unsafe_unretained id, SEL, NSTextCheckingResult *, NSString *, NSInteger, NSString *);
            originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];

            if (!pluginIsEnabled) {
                return originalIMP(self, swizzleInfo.selector, match, input, offset, template);
            }

            NSScanner *scanner = [NSScanner scannerWithString:template];
            NSMutableString *result = [NSMutableString new];
            // FIXME: <rodionovd> we should also handle the escape characters (\) here, but I'm lazy today
            // See https://developer.apple.com/documentation/foundation/nsregularexpression?language=objc#Template-Matching-Format
            NSCharacterSet *captureGroupMarker = [NSCharacterSet characterSetWithCharactersInString:@"$"];
            while (![scanner isAtEnd]) {
                NSString *buffer;
                // 1) eat up verbatim text
                if ([scanner scanUpToCharactersFromSet:captureGroupMarker intoString:&buffer]) {
                    [result appendString:buffer];
                }
                // 2) try to eat the $ symbol(s)
                buffer = nil;

                if ([scanner scanCharactersFromSet:captureGroupMarker intoString:&buffer]) {
                    if (buffer.length > 1) {
                        // 2-a) in case we read a *seqence* of "$"s, only the last may denote a capture group, the rest are verbatim
                        [result appendString:[buffer substringWithRange:NSMakeRange(0, buffer.length - 1)]];
                    }
                    // 2-b) try to parse an optional case modifier in between $ and N (of a "$N" capture group template)
                    NSString *caseModifierSymbol = ^NSString *(void) {
                        NSString *parsed = nil;
                        for (NSString *modifier in @[@"^", @".", @"-"]) {
                            if ([scanner scanString:modifier intoString:&parsed]) {
                                break;
                            }
                        }
                        return parsed;
                    }();

                    // 3) eat up as many digits as a capture group index as we can until it stops being a valid index
                    buffer = nil;
                    if (![scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&buffer]) {
                        // 3-a) no digits followed the $ symbol (after an optional case modifier), so it's not a capture group
                        [result appendFormat:@"$%@", caseModifierSymbol ?: @""];
                        continue;
                    }
                    NSInteger captureGroupIndex = -1;
                    NSString *leftoverDigits = nil;
                    for (NSInteger cutoff = 1; cutoff <= buffer.length; cutoff++) {
                        NSInteger candidate = [[buffer substringToIndex:cutoff] integerValue];
                        // -[NSString integerValue] above will happily convert @"01" to 1, which is not exactly ideal for purposes here,
                        // thus we check if we've already found the "$0" capturing group – and treat the rest of the digits as text
                        if (candidate <= [self numberOfCaptureGroups] && captureGroupIndex != 0) {
                            captureGroupIndex = candidate;
                            leftoverDigits = [buffer substringFromIndex:cutoff];
                        }
                    }
                    if (captureGroupIndex == -1) {
                        // 3-b) if the given index doesn't match any capture groups so we skip the first digit
                        // and insert the rest of (if any) them as is, to match the NSRegularExpression behavour
                        if (buffer.length > 1) {
                            [result appendString:[buffer substringFromIndex:1]];
                        }
                        continue;
                    }

                    // 4) get the original value for this capture group and modify it if needed
                    NSString *captureGroupValue = ^NSString *(void) {
                        NSString *singleGroupTemplate = [NSString stringWithFormat:@"$%li", captureGroupIndex];
                        return originalIMP(self, swizzleInfo.selector, match, input, offset, singleGroupTemplate);
                    }();
                    if ([caseModifierSymbol isEqualToString:@"^"]) {
                        [result appendString:[captureGroupValue localizedUppercaseString]];
                    } else if ([caseModifierSymbol isEqualToString:@"."]) {
                        [result appendString:[captureGroupValue localizedLowercaseString]];
                    } else if ([caseModifierSymbol isEqualToString:@"-"]) {
                        [result appendString:[captureGroupValue localizedCapitalizedString]];
                    } else {
                        [result appendString:captureGroupValue];
                    }

                    // 4-a) insert the rest of the digits that were not a part of the capture group number
                    if (leftoverDigits) {
                        [result appendString:leftoverDigits];
                    }
                }
            }
            return [result copy];
        };
    } mode:RSSwizzleModeOncePerClass key:NSRegularExpressionSwizzleKey];
}

@end
