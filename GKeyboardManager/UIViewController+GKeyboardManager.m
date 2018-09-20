//
//  UIViewController+GKeyboardManager.m
//  GKeyboardManager
//
//  Created by wanghaoqiang on 2018/9/20.
//  Copyright © 2018年 wanghaoqiang. All rights reserved.
//

#import "UIViewController+GKeyboardManager.h"
#import <objc/runtime.h>
@implementation UIViewController (GKeyboardManager)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(viewDidAppear:);
        SEL swizzledSelector = @selector(hw_viewDidAppear:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if(success)
        {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }else
        {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        SEL originalSelector1 = @selector(viewDidDisappear:);
        SEL swizzledSelector1 = @selector(hw_viewDidDisappear:);
        Method originalMethod1 = class_getInstanceMethod(class, originalSelector1);
        Method swizzledMethod1 = class_getInstanceMethod(class, swizzledSelector1);
        BOOL success1 = class_addMethod(class, originalSelector1, method_getImplementation(swizzledMethod1), method_getTypeEncoding(swizzledMethod1));
        if(success1)
        {
            class_replaceMethod(class, swizzledSelector1, method_getImplementation(originalMethod1), method_getTypeEncoding(originalMethod1));
        }else
        {
            method_exchangeImplementations(originalMethod1, swizzledMethod1);
        }
        
        
    });
}
- (void)hw_viewDidDisappear:(Boolean)animated
{
    [self hw_viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)hw_viewDidAppear:(BOOL)animated
{
    [self hw_viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
#pragma mark keyboard
- (UIView *)responderInputView
{
    UIViewController *vc = [self currentViewController];
    UIView *view = vc.view;
    NSArray* inputs =[self getInputView:view];
    for(UIView *inputView in inputs)
    {
        if([inputView isFirstResponder])
        {
            return inputView;
        }
    }
    return nil;
}
- (NSArray*)getInputView:(UIView*)view
{
    NSMutableArray *inputViews = [NSMutableArray array];
    if(view != nil && view.subviews.count > 0)
    {
        for(UIView *inputView in view.subviews)
        {
            if([inputView isKindOfClass:[UITextField class]] || [inputViews isKindOfClass:[UITextView class]])
            {
                [inputViews addObject:inputView];
            }else
            {
                [inputViews addObjectsFromArray:[self getInputView:inputView]];
            }
        }
    }
    return inputViews;
}
- (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
}
- (UIViewController *)findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *)vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *)vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *)vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}
- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    UIView *view = [self responderInputView];
    UIView *targetView = [[self currentViewController] view];
    if (view) {
        CGRect rect    = [view.superview convertRect:view.frame toView:targetView];
        CGFloat offset = (rect.origin.y + rect.size.height + 1) - (targetView.frame.size.height - kbHeight);
        
        if (self.navigationController != nil) {
            //            if(offset > rect.origin.y - Sz_NAV_H) {
            //                offset = rect.origin.y - Sz_NAV_H;
            //            };
        } else {
            if (offset > rect.origin.y) {
                offset = rect.origin.y;
            };
        }
        // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
        double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        //将视图上移计算好的偏移
        if (offset > 0) {
            [UIView animateWithDuration:duration
                             animations:^{
                                 targetView.frame =
                                 CGRectMake(0.0f, -offset, targetView.frame.size.width, targetView.frame.size.height);
                             }];
        } else {
            //视图下沉恢复原状
            [UIView animateWithDuration:duration
                             animations:^{
                                 targetView.frame =
                                 CGRectMake(0, 0, targetView.frame.size.width, targetView.frame.size.height);
                             }];
        }
    }
}
///键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notify {
    UIView *targetView = [[self currentViewController] view];
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration
                     animations:^{
                         targetView.frame = CGRectMake(0, 0, targetView.frame.size.width, targetView.frame.size.height);
                     }];
}
@end
