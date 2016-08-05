//  CAPSPageMenu.swift
//
//  Niklas Fahl
//
//  Copyright (c) 2014 The Board of Trustees of The University of Alabama All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  Neither the name of the University nor the names of the contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import UIKit

@objc public protocol CASectionPageMenuDelegate {
    // MARK: - Delegate functions
    
    optional func willMoveToPage(index: Int)
    optional func didMoveToPage(index: Int)
}

@objc public class MenuItemView: UIView {
    // MARK: - Menu item view
    
    var titleLabel : UILabel?
    var menuItemSeparator : UIView?
    
    public func setUpMenuItemView(menuItemWidth: CGFloat, menuScrollViewHeight: CGFloat, indicatorHeight: CGFloat, separatorPercentageHeight: CGFloat, separatorWidth: CGFloat, separatorRoundEdges: Bool, menuItemSeparatorColor: UIColor) {
        titleLabel = UILabel(frame: CGRectMake(0.0, 0.0, menuItemWidth, menuScrollViewHeight - indicatorHeight))
        
        menuItemSeparator = UIView(frame: CGRectMake(menuItemWidth - (separatorWidth / 2), floor(menuScrollViewHeight * ((1.0 - separatorPercentageHeight) / 2.0)), separatorWidth, floor(menuScrollViewHeight * separatorPercentageHeight)))
        menuItemSeparator!.backgroundColor = menuItemSeparatorColor
        
        if separatorRoundEdges {
            menuItemSeparator!.layer.cornerRadius = menuItemSeparator!.frame.width / 2
        }
        
        menuItemSeparator!.hidden = true
        self.addSubview(menuItemSeparator!)
        
        self.addSubview(titleLabel!)
    }
    
//    func setTitleText(text: NSString) {
//        if titleLabel != nil {
//            var attstr:NSMutableAttributedString = NSMutableAttributedString(string: text as String)
//            attstr.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: NSMakeRange(0, text.length))
//            titleLabel!.attributedText = attstr
//            titleLabel?.font = UIFont.systemFontOfSize(18,weight:2)//weight文字线条粗细
////            titleLabel!.text = text as String
//            titleLabel!.numberOfLines = 0
//            titleLabel!.sizeToFit()
//        }
//    }
}

public enum CAPSPageMenuOption {
    case SelectionIndicatorHeight(CGFloat)
    case MenuItemSeparatorWidth(CGFloat)
    case ScrollMenuBackgroundColor(UIColor)
    case ViewBackgroundColor(UIColor)
    case BottomMenuHairlineColor(UIColor)
    case SelectionIndicatorColor(UIColor)
    case MenuItemSeparatorColor(UIColor)
    case MenuMargin(CGFloat)
    case MenuHeight(CGFloat)
    case SelectedMenuItemLabelColor(UIColor)
    case UnselectedMenuItemLabelColor(UIColor)
    case UseMenuLikeSegmentedControl(Bool)
    case MenuItemSeparatorRoundEdges(Bool)
    case MenuItemSeparatorUnderline(Bool)
    case MenuItemFont(UIFont)
    case MenuItemSeparatorPercentageHeight(CGFloat)
    case MenuItemWidth(CGFloat)
    case EnableHorizontalBounce(Bool)
    case AddBottomMenuHairline(Bool)
    case MenuItemWidthBasedOnTitleTextWidth(Bool)
    case ScrollAnimationDurationOnMenuItemTap(Int)
    case CenterMenuItems(Bool)
    case HideTopMenuBar(Bool)
}

public class CASectionPageMenu: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    let menuScrollView = UIScrollView()
    public var controllerScrollView = UIScrollView(){
        didSet{
            setNeedsLayout()
        }
    }
//    var controllerArray : [UIViewController] = []
    public var titleArray:[String] = []{
        didSet{
            setNeedsLayout()
        }
    }
    var menuItems : [MenuItemView] = []
    var menuItemWidths : [CGFloat] = []
    
//    public var menuHeight : CGFloat = 34.0
    public var menuMargin : CGFloat = 15.0
    public var menuItemWidth : CGFloat = 111.0
    public var selectionIndicatorHeight : CGFloat = 3.0
    var totalMenuItemWidthIfDifferentWidths : CGFloat = 0.0
    public var scrollAnimationDurationOnMenuItemTap : Int = 500 // Millisecons
    var startingMenuMargin : CGFloat = 0.0
    
    var selectionIndicatorView : UIView = UIView()
    
    var currentPageIndex : Int = 0
    var lastPageIndex : Int = 0
    
    public var selectionIndicatorColor : UIColor = UIColor.whiteColor()
    public var selectedMenuItemLabelColor : UIColor = UIColor.whiteColor()
    public var unselectedMenuItemLabelColor : UIColor = UIColor.lightGrayColor()
    public var scrollMenuBackgroundColor : UIColor = UIColor.blackColor()
    public var viewBackgroundColor : UIColor = UIColor.whiteColor()
    public var bottomMenuHairlineColor : UIColor = UIColor.whiteColor()
    public var menuItemSeparatorColor : UIColor = UIColor.lightGrayColor()
    
    public var menuItemFont : UIFont = UIFont.systemFontOfSize(15.0)
    public var menuItemSeparatorPercentageHeight : CGFloat = 0.2
    public var menuItemSeparatorWidth : CGFloat = 0.5
    public var menuItemSeparatorRoundEdges : Bool = false
    public var menuItemSeparatorUnderline:Bool = false
    
    public var addBottomMenuHairline : Bool = true
    public var menuItemWidthBasedOnTitleTextWidth : Bool = false
    public var useMenuLikeSegmentedControl : Bool = false
    public var centerMenuItems : Bool = false
    public var enableHorizontalBounce : Bool = true
    public var hideTopMenuBar : Bool = false
    
    var currentOrientationIsPortrait : Bool = true
    var pageIndexForOrientationChange : Int = 0
    var didLayoutSubviewsAfterRotation : Bool = false
    var didScrollAlready : Bool = false
    
    var lastControllerScrollViewContentOffset : CGFloat = 0.0
    
    var lastScrollDirection : CAPSPageMenuScrollDirection = .Other
    var startingPageForScroll : Int = 0
    var didTapMenuItemToScroll : Bool = false
    
    var pagesAddedDictionary : [Int : Int] = [:]
    
    public weak var delegate : CASectionPageMenuDelegate?
    
    var tapTimer : NSTimer?
    
    enum CAPSPageMenuScrollDirection : Int {
        case Left
        case Right
        case Other
    }
    
    // MARK: - View life cycle
    
    /**
    Initialize PageMenu with view controllers
    
    - parameter viewControllers: List of view controllers that must be subclasses of UIViewController
    - parameter frame: Frame for page menu view
    - parameter options: Dictionary holding any customization options user might want to set
    */
//    public init(pageMenuOptions: [CAPSPageMenuOption]?) {
//        
//    }
    
    public override init(frame:CGRect){
        super.init(frame:frame)
    }
    
    public convenience init(pageMenuOptions: [CAPSPageMenuOption]?,frame:CGRect = CGRectZero) {
//        self.init(coder:NSCoder())
//        self.init(frame:CGRectMake(0, 0, 100, 20))
        self.init(frame:frame)
        
        if let options = pageMenuOptions {
            for option in options {
                switch (option) {
                case let .SelectionIndicatorHeight(value):
                    selectionIndicatorHeight = value
                case let .MenuItemSeparatorWidth(value):
                    menuItemSeparatorWidth = value
                case let .ScrollMenuBackgroundColor(value):
                    scrollMenuBackgroundColor = value
                case let .ViewBackgroundColor(value):
                    viewBackgroundColor = value
                case let .BottomMenuHairlineColor(value):
                    bottomMenuHairlineColor = value
                case let .SelectionIndicatorColor(value):
                    selectionIndicatorColor = value
                case let .MenuItemSeparatorColor(value):
                    menuItemSeparatorColor = value
                case let .MenuMargin(value):
                    menuMargin = value
                case let .MenuHeight(value):
                    _ = value
                case let .SelectedMenuItemLabelColor(value):
                    selectedMenuItemLabelColor = value
                case let .UnselectedMenuItemLabelColor(value):
                    unselectedMenuItemLabelColor = value
                case let .UseMenuLikeSegmentedControl(value):
                    useMenuLikeSegmentedControl = value
                case let .MenuItemSeparatorRoundEdges(value):
                    menuItemSeparatorRoundEdges = value
                case let .MenuItemSeparatorUnderline(value):
                    menuItemSeparatorUnderline = value
                case let .MenuItemFont(value):
                    menuItemFont = value
                case let .MenuItemSeparatorPercentageHeight(value):
                    menuItemSeparatorPercentageHeight = value
                case let .MenuItemWidth(value):
                    menuItemWidth = value
                case let .EnableHorizontalBounce(value):
                    enableHorizontalBounce = value
                case let .AddBottomMenuHairline(value):
                    addBottomMenuHairline = value
                case let .MenuItemWidthBasedOnTitleTextWidth(value):
                    menuItemWidthBasedOnTitleTextWidth = value
                case let .ScrollAnimationDurationOnMenuItemTap(value):
                    scrollAnimationDurationOnMenuItemTap = value
                case let .CenterMenuItems(value):
                    centerMenuItems = value
                case let .HideTopMenuBar(value):
                    hideTopMenuBar = value
                }
            }
        }
        if hideTopMenuBar {
            addBottomMenuHairline = false
            //                menuHeight = 0.0
        }
    }
    
//    required public init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
//        super.init(coder: aDecoder)
    }
    
    // MARK: - UI Setup
    
    func setUpUserInterface() {
//        let viewsDictionary = ["menuScrollView":menuScrollView, "controllerScrollView":controllerScrollView]
        
        
//        controllerScrollView.frame = CGRectMake(0.0, menuHeight, self.frame.width, self.frame.height - menuHeight)
         self.addSubview(menuScrollView)
        
        // Set up menu scroll view
        menuScrollView.snp_makeConstraints { [weak self](make) -> Void in
            make.left.top.right.equalTo(self!)
//            make.height.equalTo(menuHeight)
            make.bottom.equalTo(self!)
        }
        
//        menuScrollView.frame = CGRectMake(0.0, 0.0, self.view.frame.width, menuHeight)
        
        // Add hairline to menu scroll view
        if addBottomMenuHairline {
            let menuBottomHairline : UIView = UIView()
            
            
            self.addSubview(menuBottomHairline)
            menuBottomHairline.snp_makeConstraints(closure: { [weak self](make) -> Void in
                make.left.right.equalTo(self!)
                make.bottom.equalTo(self!)
                make.height.equalTo(0.5)
            })
            
//            menuBottomHairline.setTranslatesAutoresizingMaskIntoConstraints(false)
//            
//            let menuBottomHairline_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[menuBottomHairline]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
//            let menuBottomHairline_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(menuHeight)-[menuBottomHairline(0.5)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
//            
//            self.addConstraints(menuBottomHairline_constraint_H)
//            self.addConstraints(menuBottomHairline_constraint_V)
            
            menuBottomHairline.backgroundColor = bottomMenuHairlineColor
        }
        
        // Disable scroll bars
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.showsVerticalScrollIndicator = false
        
        // Set background color behind scroll views and for menu scroll view
        self.backgroundColor = viewBackgroundColor
        menuScrollView.backgroundColor = scrollMenuBackgroundColor
    }
    
    func configureUserInterface() {
        // Add tap gesture recognizer to controller scroll view to recognize menu item selection
        let menuItemTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleMenuItemTap:"))
        menuItemTapGestureRecognizer.numberOfTapsRequired = 1
        menuItemTapGestureRecognizer.numberOfTouchesRequired = 1
        menuItemTapGestureRecognizer.delegate = self
        menuScrollView.addGestureRecognizer(menuItemTapGestureRecognizer)
        
        // When the user taps the status bar, the scroll view beneath the touch which is closest to the status bar will be scrolled to top,
        // but only if its `scrollsToTop` property is YES, its delegate does not return NO from `shouldScrollViewScrollToTop`, and it is not already at the top.
        // If more than one scroll view is found, none will be scrolled.
        // Disable scrollsToTop for menu and controller scroll views so that iOS finds scroll views within our pages on status bar tap gesture.
        menuScrollView.scrollsToTop = false
        
        // Configure menu scroll view
        if useMenuLikeSegmentedControl {
            menuScrollView.scrollEnabled = false
            menuScrollView.contentSize = CGSizeMake(self.frame.width, self.frame.height)
            menuMargin = 0.0
        } else {
            menuScrollView.contentSize = CGSizeMake((menuItemWidth + menuMargin) * CGFloat(titleArray.count) + menuMargin, self.frame.height)
        }
        
        // Configure controller scroll view content size
//        controllerScrollView.contentSize = CGSizeMake(self.frame.width * CGFloat(titleArray.count), 0.0)
        
        var index : CGFloat = 0.0
        
        for title in titleArray {
            if index == 0.0 {
                // Add first two controllers to scrollview and as child view controller
//                controller.viewWillAppear(true)
                addPageAtIndex(0)
//                controller.viewDidAppear(true)
            }
            
            // Set up menu item for menu scroll view
            var menuItemFrame : CGRect = CGRect()
            
            if useMenuLikeSegmentedControl {
                menuItemFrame = CGRectMake(self.frame.width / CGFloat(titleArray.count) * CGFloat(index), 0.0, CGFloat(self.frame.width) / CGFloat(titleArray.count), self.frame.height)
            } else if menuItemWidthBasedOnTitleTextWidth {
                let controllerTitle : String? = title
                
                let titleText : String = controllerTitle != nil ? controllerTitle! : "Menu \(Int(index) + 1)"
                
                let itemWidthRect : CGRect = (titleText as NSString).boundingRectWithSize(CGSizeMake(1000, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:menuItemFont], context: nil)
                
                menuItemWidth = itemWidthRect.width
                
                menuItemFrame = CGRectMake(totalMenuItemWidthIfDifferentWidths + menuMargin + (menuMargin * index), 0.0, menuItemWidth, self.frame.height)
                
                totalMenuItemWidthIfDifferentWidths += itemWidthRect.width
                menuItemWidths.append(itemWidthRect.width)
            } else {
                if centerMenuItems && index == 0.0  {
                    startingMenuMargin = ((self.frame.width - ((CGFloat(titleArray.count) * menuItemWidth) + (CGFloat(titleArray.count - 1) * menuMargin))) / 2.0) -  menuMargin
                    
                    if startingMenuMargin < 0.0 {
                        startingMenuMargin = 0.0
                    }
                    
                    menuItemFrame = CGRectMake(startingMenuMargin + menuMargin, 0.0, menuItemWidth, self.frame.height)
                } else {
                    menuItemFrame = CGRectMake(menuItemWidth * index + menuMargin * (index + 1) + startingMenuMargin, 0.0, menuItemWidth, self.frame.height)
                }
            }
            
            let menuItemView : MenuItemView = MenuItemView(frame: menuItemFrame)
            if useMenuLikeSegmentedControl {
                menuItemView.setUpMenuItemView(CGFloat(self.frame.width) / CGFloat(titleArray.count), menuScrollViewHeight: self.frame.height, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
            } else {
                menuItemView.setUpMenuItemView(menuItemWidth, menuScrollViewHeight: self.frame.height, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
            }
            
            // Configure menu item label font if font is set by user
            menuItemView.titleLabel!.font = menuItemFont
            
            menuItemView.titleLabel!.textAlignment = NSTextAlignment.Center
            menuItemView.titleLabel!.textColor = unselectedMenuItemLabelColor
            
            
            // Set title depending on if controller has a title set
            var info:NSString
            if title != "" {
                info = title
            } else {
                info = "Menu \(Int(index) + 1)"
            }
            let attstr:NSMutableAttributedString = NSMutableAttributedString(string: info as String)
            if menuItemSeparatorUnderline {
                attstr.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: NSMakeRange(0, info.length))
            }
            menuItemView.titleLabel!.attributedText = attstr
            
            
            // Add separator between menu items when using as segmented control
            if useMenuLikeSegmentedControl {
                if Int(index) < titleArray.count - 1 {
                    menuItemView.menuItemSeparator!.hidden = false
                }
            }
            
            // Add menu item view to menu scroll view
            menuScrollView.addSubview(menuItemView)
            menuItems.append(menuItemView)
            
            index++
        }
        
        // Set new content size for menu scroll view if needed
        if menuItemWidthBasedOnTitleTextWidth {
            menuScrollView.contentSize = CGSizeMake((totalMenuItemWidthIfDifferentWidths + menuMargin) + CGFloat(titleArray.count) * menuMargin, self.frame.height)
        }
        
        // Set selected color for title label of selected menu item
        if menuItems.count > 0 {
            if menuItems[currentPageIndex].titleLabel != nil {
                menuItems[currentPageIndex].titleLabel!.textColor = selectedMenuItemLabelColor
            }
        }
        
        // Configure selection indicator view
        var selectionIndicatorFrame : CGRect!// = CGRect()
        
        if useMenuLikeSegmentedControl {
            selectionIndicatorFrame = CGRectMake(0.0, self.frame.height - selectionIndicatorHeight, self.frame.width / CGFloat(titleArray.count), selectionIndicatorHeight)
        } else if menuItemWidthBasedOnTitleTextWidth {
            selectionIndicatorFrame = CGRectMake(menuMargin, self.frame.height - selectionIndicatorHeight, menuItemWidths[0], selectionIndicatorHeight)
        } else {
            if centerMenuItems  {
                selectionIndicatorFrame = CGRectMake(startingMenuMargin + menuMargin, self.frame.height - selectionIndicatorHeight, menuItemWidth, selectionIndicatorHeight)
            } else {
                selectionIndicatorFrame = CGRectMake(menuMargin, self.frame.height - selectionIndicatorHeight, menuItemWidth, selectionIndicatorHeight)
            }
        }
        
        selectionIndicatorView = UIView(frame: selectionIndicatorFrame)
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
        
        if menuItemWidthBasedOnTitleTextWidth && centerMenuItems {
            self.configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            let leadingAndTrailingMargin = self.getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            selectionIndicatorView.frame = CGRectMake(leadingAndTrailingMargin, self.frame.height - selectionIndicatorHeight, menuItemWidths[0], selectionIndicatorHeight)
        }
    }
    
    // Adjusts the menu item frames to size item width based on title text width and center all menu items in the center
    // if the menuItems all fit in the width of the view. Otherwise, it will adjust the frames so that the menu items
    // appear as if only menuItemWidthBasedOnTitleTextWidth is true.
    private func configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems() {
        // only center items if the combined width is less than the width of the entire view's bounds
        if menuScrollView.contentSize.width < CGRectGetWidth(self.bounds) {
            // compute the margin required to center the menu items
            let leadingAndTrailingMargin = self.getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            
            // adjust the margin of each menu item to make them centered
            for (index, menuItem) in menuItems.enumerate() {
                let controllerTitle = titleArray[index]
                
                let itemWidthRect = controllerTitle.boundingRectWithSize(CGSizeMake(1000, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:menuItemFont], context: nil)
                
                menuItemWidth = itemWidthRect.width
                
                var margin: CGFloat
                if index == 0 {
                    // the first menu item should use the calculated margin
                    margin = leadingAndTrailingMargin
                } else {
                    // the other menu items should use the menuMargin
                    let previousMenuItem = menuItems[index-1]
                    let previousX = CGRectGetMaxX(previousMenuItem.frame)
                    margin = previousX + menuMargin
                }
                
                menuItem.frame = CGRectMake(margin, 0.0, menuItemWidth, self.frame.height)
            }
        } else {
            // the menuScrollView.contentSize.width exceeds the view's width, so layout the menu items normally (menuItemWidthBasedOnTitleTextWidth)
            for (index, menuItem) in menuItems.enumerate() {
                var menuItemX: CGFloat
                if index == 0 {
                    menuItemX = menuMargin
                } else {
                    menuItemX = CGRectGetMaxX(menuItems[index-1].frame) + menuMargin
                }
                
                menuItem.frame = CGRectMake(menuItemX, 0.0, CGRectGetWidth(menuItem.bounds), CGRectGetHeight(menuItem.bounds))
            }
        }
    }
    
    // Returns the size of the left and right margins that are neccessary to layout the menuItems in the center.
    private func getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems() -> CGFloat {
        let menuItemsTotalWidth = menuScrollView.contentSize.width - menuMargin * 2
        let leadingAndTrailingMargin = (CGRectGetWidth(self.bounds) - menuItemsTotalWidth) / 2
        
        return leadingAndTrailingMargin
    }
    
    
    // MARK: - Scroll view delegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !didLayoutSubviewsAfterRotation {
            if scrollView.isEqual(controllerScrollView) {
                if scrollView.contentOffset.x >= 0.0 && scrollView.contentOffset.x <= (CGFloat(titleArray.count - 1) * self.frame.width) {
                    if (currentOrientationIsPortrait && UIApplication.sharedApplication().statusBarOrientation.isPortrait) || (!currentOrientationIsPortrait && UIApplication.sharedApplication().statusBarOrientation.isLandscape) {
                        // Check if scroll direction changed
                        if !didTapMenuItemToScroll {
                            if didScrollAlready {
                                var newScrollDirection : CAPSPageMenuScrollDirection = .Other
                                
                                if (CGFloat(startingPageForScroll) * scrollView.frame.width > scrollView.contentOffset.x) {
                                    newScrollDirection = .Right
                                } else if (CGFloat(startingPageForScroll) * scrollView.frame.width < scrollView.contentOffset.x) {
                                    newScrollDirection = .Left
                                }
                                
                                if newScrollDirection != .Other {
                                    if lastScrollDirection != newScrollDirection {
                                        let index : Int = newScrollDirection == .Left ? currentPageIndex + 1 : currentPageIndex - 1
                                        
                                        if index >= 0 && index < titleArray.count {
                                            // Check dictionary if page was already added
                                            if pagesAddedDictionary[index] != index {
                                                addPageAtIndex(index)
                                                pagesAddedDictionary[index] = index
                                            }
                                        }
                                    }
                                }
                                
                                lastScrollDirection = newScrollDirection
                            }
                            
                            if !didScrollAlready {
                                if (lastControllerScrollViewContentOffset > scrollView.contentOffset.x) {
                                    if currentPageIndex != titleArray.count - 1 {
                                        // Add page to the left of current page
                                        let index : Int = currentPageIndex - 1
                                        
                                        if pagesAddedDictionary[index] != index && index < titleArray.count && index >= 0 {
                                            addPageAtIndex(index)
                                            pagesAddedDictionary[index] = index
                                        }
                                        
                                        lastScrollDirection = .Right
                                    }
                                } else if (lastControllerScrollViewContentOffset < scrollView.contentOffset.x) {
                                    if currentPageIndex != 0 {
                                        // Add page to the right of current page
                                        let index : Int = currentPageIndex + 1
                                        
                                        if pagesAddedDictionary[index] != index && index < titleArray.count && index >= 0 {
                                            addPageAtIndex(index)
                                            pagesAddedDictionary[index] = index
                                        }
                                        
                                        lastScrollDirection = .Left
                                    }
                                }
                                
                                didScrollAlready = true
                            }
                            
                            lastControllerScrollViewContentOffset = scrollView.contentOffset.x
                        }
                        
                        var ratio : CGFloat = 1.0
                        
                        
                        // Calculate ratio between scroll views
                        ratio = (menuScrollView.contentSize.width - self.frame.width) / (controllerScrollView.contentSize.width - self.frame.width)
                        
                        if menuScrollView.contentSize.width > self.frame.width {
                            var offset : CGPoint = menuScrollView.contentOffset
                            offset.x = controllerScrollView.contentOffset.x * ratio
                            menuScrollView.setContentOffset(offset, animated: false)
                        }
                        
                        // Calculate current page
                        let width : CGFloat = controllerScrollView.frame.size.width;
                        let page : Int = Int((controllerScrollView.contentOffset.x + (0.5 * width)) / width)
                        
                        // Update page if changed
                        if page != currentPageIndex {
                            lastPageIndex = currentPageIndex
                            currentPageIndex = page
                            
                            if pagesAddedDictionary[page] != page && page < titleArray.count && page >= 0 {
                                addPageAtIndex(page)
                                pagesAddedDictionary[page] = page
                            }
                            
                            if !didTapMenuItemToScroll {
                                // Add last page to pages dictionary to make sure it gets removed after scrolling
                                if pagesAddedDictionary[lastPageIndex] != lastPageIndex {
                                    pagesAddedDictionary[lastPageIndex] = lastPageIndex
                                }
                                
                                // Make sure only up to 3 page views are in memory when fast scrolling, otherwise there should only be one in memory
                                let indexLeftTwo : Int = page - 2
                                if pagesAddedDictionary[indexLeftTwo] == indexLeftTwo {
                                    pagesAddedDictionary.removeValueForKey(indexLeftTwo)
                                    removePageAtIndex(indexLeftTwo)
                                }
                                let indexRightTwo : Int = page + 2
                                if pagesAddedDictionary[indexRightTwo] == indexRightTwo {
                                    pagesAddedDictionary.removeValueForKey(indexRightTwo)
                                    removePageAtIndex(indexRightTwo)
                                }
                            }
                        }
                        
                        // Move selection indicator view when swiping
                        moveSelectionIndicator(page)
                    }
                } else {
                    var ratio : CGFloat = 1.0
                    
                    ratio = (menuScrollView.contentSize.width - self.frame.width) / (controllerScrollView.contentSize.width - self.frame.width)
                    
                    if menuScrollView.contentSize.width > self.frame.width {
                        var offset : CGPoint = menuScrollView.contentOffset
                        offset.x = controllerScrollView.contentOffset.x * ratio
                        menuScrollView.setContentOffset(offset, animated: false)
                    }
                }
            }
        } else {
            didLayoutSubviewsAfterRotation = false
            
            // Move selection indicator view when swiping
            moveSelectionIndicator(currentPageIndex)
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.isEqual(controllerScrollView) {
            // Call didMoveToPage delegate function
//            var currentController = controllerArray[currentPageIndex]
            delegate?.didMoveToPage?(currentPageIndex)
            
            // Remove all but current page after decelerating
            for key in pagesAddedDictionary.keys {
                if key != currentPageIndex {
                    removePageAtIndex(key)
                }
            }
            
            didScrollAlready = false
            startingPageForScroll = currentPageIndex
            
            
            // Empty out pages in dictionary
            pagesAddedDictionary.removeAll(keepCapacity: false)
        }
    }
    
    func scrollViewDidEndTapScrollingAnimation() {
        // Call didMoveToPage delegate function
//        var currentController = controllerArray[currentPageIndex]
        delegate?.didMoveToPage?(currentPageIndex)
        
        // Remove all but current page after decelerating
        for key in pagesAddedDictionary.keys {
            if key != currentPageIndex {
                removePageAtIndex(key)
            }
        }
        
        startingPageForScroll = currentPageIndex
        didTapMenuItemToScroll = false
        
        // Empty out pages in dictionary
        pagesAddedDictionary.removeAll(keepCapacity: false)
    }
    
    
    // MARK: - Handle Selection Indicator
    func moveSelectionIndicator(pageIndex: Int) {
        if pageIndex >= 0 && pageIndex < titleArray.count {
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                var selectionIndicatorWidth : CGFloat = self.selectionIndicatorView.frame.width
                var selectionIndicatorX : CGFloat = 0.0
                
                if self.useMenuLikeSegmentedControl {
                    selectionIndicatorX = CGFloat(pageIndex) * (self.frame.width / CGFloat(self.titleArray.count))
                    selectionIndicatorWidth = self.frame.width / CGFloat(self.titleArray.count)
                } else if self.menuItemWidthBasedOnTitleTextWidth {
                    selectionIndicatorWidth = self.menuItemWidths[pageIndex]
                    selectionIndicatorX = CGRectGetMinX(self.menuItems[pageIndex].frame)
                } else {
                    if self.centerMenuItems && pageIndex == 0 {
                        selectionIndicatorX = self.startingMenuMargin + self.menuMargin
                    } else {
                        selectionIndicatorX = self.menuItemWidth * CGFloat(pageIndex) + self.menuMargin * CGFloat(pageIndex + 1) + self.startingMenuMargin
                    }
                }
                
                self.selectionIndicatorView.frame = CGRectMake(selectionIndicatorX, self.selectionIndicatorView.frame.origin.y, selectionIndicatorWidth, self.selectionIndicatorView.frame.height)
                
                // Switch newly selected menu item title label to selected color and old one to unselected color
                if self.menuItems.count > 0 {
                    if self.menuItems[self.lastPageIndex].titleLabel != nil && self.menuItems[self.currentPageIndex].titleLabel != nil {
                        self.menuItems[self.lastPageIndex].titleLabel!.textColor = self.unselectedMenuItemLabelColor
                        self.menuItems[self.currentPageIndex].titleLabel!.textColor = self.selectedMenuItemLabelColor
                    }
                }
            })
        }
    }
    
    
    // MARK: - Tap gesture recognizer selector
    
    func handleMenuItemTap(gestureRecognizer : UITapGestureRecognizer) {
        let tappedPoint : CGPoint = gestureRecognizer.locationInView(menuScrollView)
        
        if tappedPoint.y < menuScrollView.frame.height {
            
            // Calculate tapped page
            var itemIndex : Int = 0
            
            if useMenuLikeSegmentedControl {
                itemIndex = Int(tappedPoint.x / (self.frame.width / CGFloat(titleArray.count)))
            } else if menuItemWidthBasedOnTitleTextWidth {
                var menuItemLeftBound: CGFloat
                var menuItemRightBound: CGFloat
                
                if centerMenuItems {
                    menuItemLeftBound = CGRectGetMinX(menuItems[0].frame)
                    menuItemRightBound = CGRectGetMaxX(menuItems[menuItems.count-1].frame)
                    
                    if (tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                        for (index, title) in titleArray.enumerate() {
                            menuItemLeftBound = CGRectGetMinX(menuItems[index].frame)
                            menuItemRightBound = CGRectGetMaxX(menuItems[index].frame)
                            
                            if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                                itemIndex = index
                                break
                            }
                        }
                    }
                } else {
                    // Base case being first item
                    menuItemLeftBound = 0.0
                    menuItemRightBound = menuItemWidths[0] + menuMargin + (menuMargin / 2)
                    
                    if !(tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                        for i in 1...titleArray.count - 1 {
                            menuItemLeftBound = menuItemRightBound + 1.0
                            menuItemRightBound = menuItemLeftBound + menuItemWidths[i] + menuMargin
                            
                            if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                                itemIndex = i
                                break
                            }
                        }
                    }
                }
            } else {
                let rawItemIndex : CGFloat = ((tappedPoint.x - startingMenuMargin) - menuMargin / 2) / (menuMargin + menuItemWidth)
                
                // Prevent moving to first item when tapping left to first item
                if rawItemIndex < 0 {
                    itemIndex = -1
                } else {
                    itemIndex = Int(rawItemIndex)
                }
            }
            
            if itemIndex >= 0 && itemIndex < titleArray.count {
                // Update page if changed
                if itemIndex != currentPageIndex {
                    startingPageForScroll = itemIndex
                    lastPageIndex = currentPageIndex
                    currentPageIndex = itemIndex
                    didTapMenuItemToScroll = true
                    
                    // Add pages in between current and tapped page if necessary
                    let smallerIndex : Int = lastPageIndex < currentPageIndex ? lastPageIndex : currentPageIndex
                    let largerIndex : Int = lastPageIndex > currentPageIndex ? lastPageIndex : currentPageIndex
                    
                    if smallerIndex + 1 != largerIndex {
                        for index in (smallerIndex + 1)...(largerIndex - 1) {
                            if pagesAddedDictionary[index] != index {
                                addPageAtIndex(index)
                                pagesAddedDictionary[index] = index
                            }
                        }
                    }
                    
                    addPageAtIndex(itemIndex)
                    
                    // Add page from which tap is initiated so it can be removed after tap is done
                    pagesAddedDictionary[lastPageIndex] = lastPageIndex
                }
                
                // Move controller scroll view when tapping menu item
                let duration : Double = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
                
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    let xOffset : CGFloat = CGFloat(itemIndex) * self.controllerScrollView.frame.width
                    self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
                })
                
                if tapTimer != nil {
                    tapTimer!.invalidate()
                }
                
                let timerInterval : NSTimeInterval = Double(scrollAnimationDurationOnMenuItemTap) * 0.001
                tapTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "scrollViewDidEndTapScrollingAnimation", userInfo: nil, repeats: false)
            }
        }
    }
    
    
    // MARK: - Remove/Add Page
    func addPageAtIndex(index : Int) {
        // Call didMoveToPage delegate function
//        var currentController = controllerArray[index]
        delegate?.willMoveToPage?(index)
        
//        var newVC = controllerArray[index]
//        
//        newVC.willMoveToParentViewController(self)
//        
//        newVC.view.frame = CGRectMake(self.view.frame.width * CGFloat(index), menuHeight, self.view.frame.width, self.view.frame.height - menuHeight)
//        
//        self.addChildViewController(newVC)
//        self.controllerScrollView.addSubview(newVC.view)
//        newVC.didMoveToParentViewController(self)
    }
    
    func removePageAtIndex(index : Int) {
//        var oldVC = controllerArray[index]
//        
//        oldVC.willMoveToParentViewController(nil)
//        
//        oldVC.view.removeFromSuperview()
//        oldVC.removeFromParentViewController()
//        
//        oldVC.didMoveToParentViewController(nil)
    }
    
    
    // MARK: - Orientation Change
    
    override public func layoutSubviews() {
        // Configure controller scroll view content size
//        controllerScrollView.contentSize = CGSizeMake(self.frame.width * CGFloat(titleArray.count), self.frame.height - menuHeight)
        if menuScrollView.subviews.count == 0 && titleArray.count > 0{
            setUpUserInterface()
            configureUserInterface()
        }
        
        setUpControllerScrollView()
        // Hsoi 2015-02-05 - Running on iOS 7.1 complained: "'NSInternalInconsistencyException', reason: 'Auto Layout 
        // still required after sending -viewDidLayoutSubviews to the view controller. ViewController's implementation 
        // needs to send -layoutSubviews to the view to invoke auto layout.'"
        //
        // http://stackoverflow.com/questions/15490140/auto-layout-error
        //
        // Given the SO answer and caveats presented there, we'll call layoutIfNeeded() instead.
//        self.view.layoutIfNeeded()
        layoutIfNeeded()
    }
    
    private func setUpControllerScrollView(){
        // Set delegate for controller scroll view
        controllerScrollView.delegate = self
        controllerScrollView.scrollsToTop = false;
        // Set up controller scroll view
        controllerScrollView.pagingEnabled = true
        //        controllerScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        controllerScrollView.alwaysBounceHorizontal = enableHorizontalBounce
        controllerScrollView.bounces = enableHorizontalBounce
        controllerScrollView.showsHorizontalScrollIndicator = false
        controllerScrollView.showsVerticalScrollIndicator = false
        
        let oldCurrentOrientationIsPortrait : Bool = currentOrientationIsPortrait
        currentOrientationIsPortrait = UIApplication.sharedApplication().statusBarOrientation.isPortrait
        
        if (oldCurrentOrientationIsPortrait && UIDevice.currentDevice().orientation.isLandscape) || (!oldCurrentOrientationIsPortrait && UIDevice.currentDevice().orientation.isPortrait) {
            didLayoutSubviewsAfterRotation = true
            
            //Resize menu items if using as segmented control
            if useMenuLikeSegmentedControl {
                menuScrollView.contentSize = CGSizeMake(self.frame.width, self.frame.height)
                
                // Resize selectionIndicator bar
                let selectionIndicatorX : CGFloat = CGFloat(currentPageIndex) * (self.frame.width / CGFloat(self.titleArray.count))
                let selectionIndicatorWidth : CGFloat = self.frame.width / CGFloat(self.titleArray.count)
                selectionIndicatorView.frame =  CGRectMake(selectionIndicatorX, self.selectionIndicatorView.frame.origin.y, selectionIndicatorWidth, self.selectionIndicatorView.frame.height)
                
                // Resize menu items
                var index : Int = 0
                
                for item : MenuItemView in menuItems as [MenuItemView] {
                    item.frame = CGRectMake(self.frame.width / CGFloat(titleArray.count) * CGFloat(index), 0.0, self.frame.width / CGFloat(titleArray.count), self.frame.height)
                    item.titleLabel!.frame = CGRectMake(0.0, 0.0, self.frame.width / CGFloat(titleArray.count), self.frame.height)
                    item.menuItemSeparator!.frame = CGRectMake(item.frame.width - (menuItemSeparatorWidth / 2), item.menuItemSeparator!.frame.origin.y, item.menuItemSeparator!.frame.width, item.menuItemSeparator!.frame.height)
                    
                    index++
                }
            } else if menuItemWidthBasedOnTitleTextWidth && centerMenuItems {
                self.configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
                let selectionIndicatorX = CGRectGetMinX(menuItems[currentPageIndex].frame)
                selectionIndicatorView.frame = CGRectMake(selectionIndicatorX, self.frame.height - selectionIndicatorHeight, menuItemWidths[currentPageIndex], selectionIndicatorHeight)
            } else if centerMenuItems {
                startingMenuMargin = ((self.frame.width - ((CGFloat(titleArray.count) * menuItemWidth) + (CGFloat(titleArray.count - 1) * menuMargin))) / 2.0) -  menuMargin
                
                if startingMenuMargin < 0.0 {
                    startingMenuMargin = 0.0
                }
                
                let selectionIndicatorX : CGFloat = self.menuItemWidth * CGFloat(currentPageIndex) + self.menuMargin * CGFloat(currentPageIndex + 1) + self.startingMenuMargin
                selectionIndicatorView.frame =  CGRectMake(selectionIndicatorX, self.selectionIndicatorView.frame.origin.y, self.selectionIndicatorView.frame.width, self.selectionIndicatorView.frame.height)
                
                // Recalculate frame for menu items if centered
                var index : Int = 0
                
                for item : MenuItemView in menuItems as [MenuItemView] {
                    if index == 0 {
                        item.frame = CGRectMake(startingMenuMargin + menuMargin, 0.0, menuItemWidth, self.frame.height)
                    } else {
                        item.frame = CGRectMake(menuItemWidth * CGFloat(index) + menuMargin * CGFloat(index + 1) + startingMenuMargin, 0.0, menuItemWidth, self.frame.height)
                    }
                    
                    index++
                }
            }
            
            for view : UIView in controllerScrollView.subviews {
                view.frame = CGRectMake(self.frame.width * CGFloat(currentPageIndex), self.frame.height, controllerScrollView.frame.width, self.frame.height - self.frame.height)
            }
            
            let xOffset : CGFloat = CGFloat(self.currentPageIndex) * controllerScrollView.frame.width
            controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: controllerScrollView.contentOffset.y), animated: false)
            
            let ratio : CGFloat = (menuScrollView.contentSize.width - self.frame.width) / (controllerScrollView.contentSize.width - self.frame.width)
            
            if menuScrollView.contentSize.width > self.frame.width {
                var offset : CGPoint = menuScrollView.contentOffset
                offset.x = controllerScrollView.contentOffset.x * ratio
                menuScrollView.setContentOffset(offset, animated: false)
            }
        }
    }
    
    
    // MARK: - Move to page index
    
    /**
    Move to page at index
    
    - parameter index: Index of the page to move to
    */
    public func moveToPage(index: Int) {
        if index >= 0 && index < titleArray.count {
            // Update page if changed
            if index != currentPageIndex {
                startingPageForScroll = index
                lastPageIndex = currentPageIndex
                currentPageIndex = index
                didTapMenuItemToScroll = true
                
                // Add pages in between current and tapped page if necessary
                let smallerIndex : Int = lastPageIndex < currentPageIndex ? lastPageIndex : currentPageIndex
                let largerIndex : Int = lastPageIndex > currentPageIndex ? lastPageIndex : currentPageIndex
                
                if smallerIndex + 1 != largerIndex {
                    for i in (smallerIndex + 1)...(largerIndex - 1) {
                        if pagesAddedDictionary[i] != i {
                            addPageAtIndex(i)
                            pagesAddedDictionary[i] = i
                        }
                    }
                }
                
                addPageAtIndex(index)
                
                // Add page from which tap is initiated so it can be removed after tap is done
                pagesAddedDictionary[lastPageIndex] = lastPageIndex
            }
            
            // Move controller scroll view when tapping menu item
            let duration : Double = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                let xOffset : CGFloat = CGFloat(index) * self.controllerScrollView.frame.width
                self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
            })
        }
    }
}
