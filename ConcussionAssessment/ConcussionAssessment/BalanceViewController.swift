//
//  BalanceViewController.swift
//  ConcussionAssessment
//
//  Created by Philson Wong on 2/23/16.
//  Copyright © 2016 PYKS. All rights reserved.
//

import UIKit

class BalanceViewController: UIViewController, UIPageViewControllerDataSource {
  var pageViewController: UIPageViewController?
  var testName: String
  var pageTitles : Array<String>
  var currentIndex : Int = 0
  var limitIndex: Int = 0
  var donePressed: Bool = false
  var instructions: String
  var original: UIViewController?
  var numPages: Int
  var currScore: NSNumber
  var startingViewController: BalanceView? = nil

  
  init(pageTitles : Array<String>, testName : String, instructions: String, original: UIViewController?)
  {
    self.pageTitles = pageTitles
    self.testName = testName
    self.instructions = instructions
    self.original = original!
    self.numPages = 0
    self.currScore = 0
    super.init(nibName:nil, bundle:nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func buttonPressed(sender: UIButton)
  {
    let alertView = UIAlertController(title: "Instructions", message: self.instructions, preferredStyle: UIAlertControllerStyle.Alert)
    alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {
      action in
      switch action.style
      {
      case .Default:
        print("default")
      case .Cancel:
        print("cancel")
      case .Destructive:
        print("destructive")
      }
      
    }))
    presentViewController(alertView, animated: true, completion: nil)
  }
  
  func doneButtonPressed(sender: UIButton)
  {
    self.donePressed = true
    self.setScore()
    self.currentIndex += 1
    if(currentIndex == numPages)
    {
    //self.navigationController?.popToViewController(self.original!, animated: true)
        let scoreboard = ScoreBoardController(originalPage: self.original!)
        self.navigationController?.pushViewController(scoreboard, animated: true)
    }
    else
    {
      let startingViewController: BalanceView = self.viewControllerAtIndex(self.currentIndex)!
      let viewControllers = [startingViewController]
      self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
    }
    
  }
  
  func setScore()
  {
    print("set balance score")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    pageViewController!.dataSource = self
    
    if(self.startingViewController == nil) // not instantiated so it has no instruction page
    {
      self.startingViewController = viewControllerAtIndex(0)!
    }
    
    let viewControllers = [self.startingViewController!]
    pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
    pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    
    
    addChildViewController(pageViewController!)
    view.addSubview(pageViewController!.view)
    pageViewController!.didMoveToParentViewController(self)
    
    
    
    
    /***** TITLE SETTINGS ****
     *********************************/
    
    let title : [String] = self.testName.characters.split(":").map(String.init)
    
    
    if title.count > 1
    {
      self.navigationItem.prompt  = title[0]
      var subtitle : String = ""
      var index = 1
      for t in title[1..<title.count]
      {
        if index < title.count - 1
        {
          subtitle += t + ": "
        }
        else
        {
          subtitle += t
        }
        
        index += 1
      }
      self.navigationItem.title = subtitle
    }
    else
    {
      self.title = title[0]
    }
    
    
    /***** RIGHT NAV BAR BUTTONS ****
     *********************************/
    let infobutton = UIButton(type: UIButtonType.InfoDark)
    infobutton.addTarget(self, action: #selector(BalanceViewController.buttonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    let infoModalButton : UIBarButtonItem? = UIBarButtonItem(customView: infobutton)
    let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(BalanceViewController.doneButtonPressed(_:)))
    
    self.navigationItem.rightBarButtonItems = [doneButton, infoModalButton!]

  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
  {
    var index = self.currentIndex
    
    if(index == 0) || (index == NSNotFound)
    {
      return nil
    }
    index -= 1
    
    return viewControllerAtIndex(index)
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
  {
    var index = self.currentIndex
    if index == NSNotFound
    {
      return nil
    }
    index += 1
    currentIndex = index
    limitIndex = index
    
    if(index == self.pageTitles.count)
    {
      return nil
    }
    currentIndex = index
    
    return viewControllerAtIndex(index)
  }
  
  func viewControllerAtIndex(index: Int) ->BalanceView?
  {
    if self.pageTitles.count == 0 || index >= self.pageTitles.count || index < limitIndex
    {
      return nil
    }
    
    let pageContentViewController = BalanceView(bvc: self)
    pageContentViewController.titleText = pageTitles[index]
    
    return pageContentViewController
  }
  
  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
  {
    self.numPages = self.pageTitles.count
    return self.numPages
  }
  
  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
  {
    return self.currentIndex
  }
  
}

class BalanceView : UITableViewController
{
  var titleText : String = ""
  weak var bvc : BalanceViewController?

  
  init(bvc : BalanceViewController)
  {
    self.bvc = bvc
    
    super.init(style: UITableViewStyle.Grouped)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.tableView.contentInset = UIEdgeInsetsMake(120.0, 0, -120.0, 0)
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    self.tableView.rowHeight = 50.0
    
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int)->String?
  {
    return titleText
  }
  
  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
  {
    let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 20.0)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    //return self.bvc!.pageTitles.count
    return 2
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MenuCell")
//    cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 18.0)
//    
//    let label1 = cell.viewWithTag(1) as! UILabel // 1 is tag of first label;
//    label1.text = "AAAA"
    return cell
  }
  
  
  
  
}
