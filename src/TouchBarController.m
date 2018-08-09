/**
 * @file TouchBarController.m
 *
 * @copyright 2018 Bill Zissimopoulos
 */
/*
 * This file is part of TouchBarDock.
 *
 * You can redistribute it and/or modify it under the terms of the GNU
 * General Public License version 3 as published by the Free Software
 * Foundation.
 */

#import "TouchBarController.h"
#import "TouchBarPrivate.h"

@implementation TouchBarController
{
    NSMutableDictionary *_items;
}

- (id)init
{
    self = [super init];
    if (nil == self)
        return nil;

    _items = [[NSMutableDictionary alloc] init];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(willEnterCustomization:)
        name:@"NSTouchBarWillEnterCustomization"
        object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(didExitCustomization:)
        name:@"NSTouchBarDidExitCustomization"
        object:nil];

    return self;
}

- (void)dealloc
{
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        removeObserver:self];

    [_items release];
    self.touchBar = nil;

    [super dealloc];
}

- (BOOL)present
{
    return [self presentWithPlacement:1];
}

- (BOOL)presentWithPlacement:(NSInteger)placement
{
    if ([NSTouchBar respondsToSelector:
        @selector(presentSystemModalFunctionBar:placement:systemTrayItemIdentifier:)])
    {
        [NSTouchBar
            presentSystemModalFunctionBar:self.touchBar
            placement:placement
            systemTrayItemIdentifier:nil];
        return YES;
    }
    else if ([NSTouchBar respondsToSelector:
        @selector(presentSystemModalTouchBar:placement:systemTrayItemIdentifier:)])
    {
        [NSTouchBar
            presentSystemModalTouchBar:self.touchBar
            placement:placement
            systemTrayItemIdentifier:nil];
        return YES;
    }
    else
        return NO;
}

- (void)dismiss
{
    if ([NSTouchBar respondsToSelector:
        @selector(dismissSystemModalFunctionBar:)])
    {
        [NSTouchBar
            dismissSystemModalFunctionBar:self.touchBar];
    }
    else if ([NSTouchBar respondsToSelector:
        @selector(dismissSystemModalTouchBar:)])
    {
        [NSTouchBar
            dismissSystemModalTouchBar:self.touchBar];
    }
}

- (IBAction)customize:(id)sender
{
    [NSApp toggleTouchBarCustomizationPalette:self];
}

- (void)willEnterCustomization:(NSNotification *)notification
{
    [self dismiss];
}

- (void)didExitCustomization:(NSNotification *)notification
{
    [self present];
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar
    makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier
{
    NSTouchBarItem *item = [_items objectForKey:identifier];
    if (nil == item)
    {
        NSArray *components = [identifier componentsSeparatedByString:@" "];
        NSString *widgetClass = [[components objectAtIndex:0] stringByAppendingString:@"Widget"];
        item = [[[NSClassFromString(widgetClass) alloc] initWithIdentifier:identifier] autorelease];
        [_items setObject:item forKey:identifier];
    }
    return item;
}
@end
