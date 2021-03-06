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
  var instructions: Array<String>
  var original: UIViewController?
  var numPages: Int
  var currScore: NSNumber
  var startingViewController: BalanceView? = nil
  var cellTimerLabel: UILabel!
  var cellTimerButton: UIButton!
  var cellCounterLabel: UILabel!
  var cellIncrementButton: UIStepper!
  var timer = NSTimer()
  var timerCount = 20.00 as Float
  var count = 0 as Int
  var doneButton: UIBarButtonItem!
  var next: UIViewController?
  var domFoot: String?
  var domFootDefault: Int
  var domFootSwitch: UISegmentedControl!

  
  init(pageTitles : Array<String>, testName : String, instructions: Array<String>, original: UIViewController?, next: TablePageViewController?)
  {
    self.pageTitles = pageTitles
    self.testName = testName
    self.instructions = instructions
    self.original = original!
    self.numPages = 0
    self.currScore = 0
    self.next = next
    self.domFootDefault = 1
    self.domFoot = "Right"
    super.init(nibName:nil, bundle:nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func instructionButtonPressed(sender: UIButton)
  {
    let alertView = UIAlertController(title: "Instructions", message: self.instructions[currentIndex], preferredStyle: UIAlertControllerStyle.Alert)
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
  
  
  func setScore()
  {
    self.currScore = Int(self.currScore) + Int(self.count)
    print("set balance score \(self.currScore)")
    
    if self.currentIndex == self.numPages
    {
      database.setBalance(currentScoreID!, score: self.currScore)
      database.setDomFoot(currentScoreID!, score: self.domFoot!)
    }

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    pageViewController!.dataSource = self
    
    for view in pageViewController!.view.subviews{
      if let subView = view as? UIScrollView{
        subView.scrollEnabled = false
      }
    }

    
    if(self.startingViewController == nil) // not instantiated so it has no instruction page
    {
      self.startingViewController = viewControllerAtIndex(0)!
    }
    
    let viewControllers = [self.startingViewController!]
    pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
    pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - (self.tabBarController!.tabBar.frame.size.height));
    
    
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
    infobutton.addTarget(self, action: #selector(BalanceViewController.instructionButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    let infoModalButton : UIBarButtonItem? = UIBarButtonItem(customView: infobutton)
    
    self.navigationItem.rightBarButtonItems = [infoModalButton!]

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
  var doneButton : UIButton
  let domFootChoice = ["Left", "Right"]
//  var timer = 20.00 as Float
//  var count = 0 as Int

  init(bvc : BalanceViewController)
  {
    self.bvc = bvc
    self.doneButton = UIButton(frame: CGRectMake(self.bvc!.view.frame.size.width / 2 - 50, -30, 100, 50))
    self.doneButton.enabled = false

    super.init(style: UITableViewStyle.Grouped)
 
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.navigationItem.setHidesBackButton(true, animated: true)

    self.doneButton.enabled = false

    self.tableView.frame = CGRectMake(0, (self.bvc!.navigationController?.navigationBar.frame.size.height)! - self.bvc!.tabBarController!.tabBar.frame.size.height, self.bvc!.view.frame.size.width, self.tableView.frame.size.height-self.bvc!.tabBarController!.tabBar.frame.size.height);
    
    self.tableView.contentInset = UIEdgeInsetsMake((self.bvc!.navigationController?.navigationBar.frame.size.height)! + 40, 0, -(self.bvc!.tabBarController!.tabBar.frame.size.height), 0)
    self.tableView.scrollIndicatorInsets.bottom = -(self.bvc!.tabBarController!.tabBar.frame.size.height)
    self.tableView.scrollIndicatorInsets.top = (self.bvc!.navigationController?.navigationBar.frame.size.height)! + 40
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    self.tableView.rowHeight = 40.0
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int
  {
    return 2
  }
  
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int)->String?
  {
    if section == 1
    {
      return ""
      
    }
    else
    {
      return titleText
 
    }
  }
  
  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
  {
    let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 20.0)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    //return self.bvc!.pageTitles.count
    if section == 1{
      return 1
    }
    else
    {
      return 9
    }

  }
  
  func doneButtonPressed(sender: UIButton)
  {
    print("huiyty5rft")
    self.bvc!.donePressed = true
    self.bvc!.currentIndex += 1
    self.bvc!.setScore()
    self.bvc!.count = 0
    self.bvc!.timerCount = 20
    self.bvc!.timer.invalidate()
    if(self.bvc!.currentIndex == self.bvc!.numPages)
    {
      if(self.bvc!.next == nil) //end of test
      {
        if (self.navigationController?.topViewController!.isKindOfClass(ScoreBoardController) != nil)
        {
            let scoreboard = ScoreBoardController(originalPage: self.bvc!.original!)
            self.navigationController?.pushViewController(scoreboard, animated: true)
        }
      }
      else if(self.bvc!.next != nil)
      {
        print("next, bvc controller")
        self.bvc!.pageViewController?.view.userInteractionEnabled = false
        self.bvc!.navigationController?.pushViewController(self.bvc!.next!, animated: true)
        self.bvc!.view.userInteractionEnabled = true

        //self.navigationController?.pushViewController(self.bvc!.next!, animated: true)
      }
    }
    else
    {
      let startingViewController: BalanceView = self.bvc!.viewControllerAtIndex(self.bvc!.currentIndex)!
      let viewControllers = [startingViewController]
      self.bvc!.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
    }
    
  }
  

  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "")
    cell.selectionStyle = UITableViewCellSelectionStyle.None
//    cell.preservesSuperviewLayoutMargins = true
//    cell.contentView.preservesSuperviewLayoutMargins = true
    
    if indexPath.section == 1
    {
      let Cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "PickerCell")
      
      self.doneButton.addTarget(self, action: #selector(BalanceView.doneButtonPressed(_:)), forControlEvents: .TouchUpInside)
      
      self.doneButton.setTitle("Done", forState: .Normal)
      self.doneButton.backgroundColor = UIColor.whiteColor()
      self.doneButton.setTitleColor(UIColor(rgb: 0x007AFF), forState: .Normal)
      self.doneButton.layer.borderWidth = 1
      self.doneButton.layer.borderColor = (UIColor(rgb: 0x007AFF)).CGColor
      self.doneButton.layer.cornerRadius = 10
      self.doneButton.clipsToBounds = true;
      
      self.doneButton.hidden = true
    
      self.doneButton.enabled = false
      Cell.contentView.addSubview(self.doneButton)
      Cell.backgroundColor = UIColor.clearColor()

    
      
      return Cell
      
    }
    else
    {
      
      
      if(indexPath.row == 0)
      {
        //initializeTimer()
        self.bvc!.cellTimerLabel = UILabel(frame: CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: 50))
        self.bvc!.cellTimerLabel.text = "What is the athlete's dominant foot?"
        self.bvc!.cellTimerLabel.textAlignment = NSTextAlignment.Center
        self.bvc!.cellTimerLabel.font = UIFont(name: "Helvetica Neue", size: 20.0)
        self.bvc!.cellTimerLabel.userInteractionEnabled = false
        
        cell.contentView.addSubview(self.bvc!.cellTimerLabel)
      }
      
      if(indexPath.row == 1)
      {
        //self.bvc!.domFootSwitch = UISegmentedControl(frame: CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: 50))
        self.bvc!.domFootSwitch = UISegmentedControl(items: domFootChoice)
        self.bvc!.domFootSwitch.frame = CGRect(x: self.view.frame.midX-self.view.frame.width/6, y: self.view.frame.minY + 10, width: self.view.frame.width/3, height: 30)
        self.bvc!.domFootSwitch.addTarget(self, action: #selector(BalanceView.domFootSelect(_:)), forControlEvents: .ValueChanged)
        self.bvc!.domFootSwitch.selectedSegmentIndex = self.bvc!.domFootDefault
        
        
        cell.contentView.addSubview(self.bvc!.domFootSwitch)
      }
      
      if(indexPath.row == 3)
      {
        //initializeTimer()
        self.bvc!.cellTimerLabel = UILabel(frame: CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: 50))
        self.bvc!.cellTimerLabel.text = String(self.bvc!.timerCount)
        self.bvc!.cellTimerLabel.textAlignment = NSTextAlignment.Center
        self.bvc!.cellTimerLabel.font = UIFont(name: "Helvetica Neue", size: 36.0)
        self.bvc!.cellTimerLabel.userInteractionEnabled = false
        
        cell.contentView.addSubview(self.bvc!.cellTimerLabel)
      }
      
      if(indexPath.row == 4)
      {
        self.bvc!.cellTimerButton = UIButton()
        self.bvc!.cellTimerButton.addTarget(self, action: #selector(BalanceView.timerButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.bvc!.cellTimerButton.frame = CGRectMake(self.view.frame.midX-50, self.view.frame.minY + 10, 100, 40)
        self.bvc!.cellTimerButton.setTitle("Start", forState: .Normal)
        self.bvc!.cellTimerButton.backgroundColor = UIColor.whiteColor()
        self.bvc!.cellTimerButton.setTitleColor(UIColor(rgb: 0x007AFF), forState: .Normal)
        self.bvc!.cellTimerButton.layer.borderWidth = 1
        self.bvc!.cellTimerButton.layer.borderColor = (UIColor(rgb: 0x007AFF)).CGColor
        self.bvc!.cellTimerButton.layer.cornerRadius = 10
        self.bvc!.cellTimerButton.clipsToBounds = true;
        
        cell.contentView.addSubview(self.bvc!.cellTimerButton)
      }
      
      if(indexPath.row == 6)
      {
        self.bvc!.cellCounterLabel = UILabel(frame: CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: 50))
        self.bvc!.cellCounterLabel.text = "Number of Errors: \(self.bvc!.count)"
        self.bvc!.cellCounterLabel.textAlignment = NSTextAlignment.Center
        self.bvc!.cellCounterLabel.font = UIFont(name: "Helvetica Neue", size: 24.0)
        self.bvc!.cellCounterLabel.userInteractionEnabled = false
        
        cell.contentView.addSubview(self.bvc!.cellCounterLabel)
      }
      
      if(indexPath.row == 7)
      {
        self.bvc!.cellIncrementButton = UIStepper()
        self.bvc!.cellIncrementButton.enabled = false
        self.bvc!.cellIncrementButton.alpha = 0.5

        self.bvc!.cellIncrementButton.wraps = false
        self.bvc!.cellIncrementButton.continuous = false
        self.bvc!.cellIncrementButton.autorepeat = false
        self.bvc!.cellIncrementButton.maximumValue = 10
        self.bvc!.cellIncrementButton.minimumValue = 0
        self.bvc!.cellIncrementButton.addTarget(self, action: #selector(BalanceView.stepperPressed(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.bvc!.cellIncrementButton.frame = CGRectMake(self.view.frame.midX - 50, self.view.frame.minY, 25, 25)
        
        cell.contentView.addSubview(self.bvc!.cellIncrementButton)
      }
      
      return cell
      
    }
  }
  
  func timerButtonPressed(sender: UIButton)
  {
    print("timer start")
    self.bvc!.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(BalanceView.timerCountdown), userInfo: nil, repeats: true)
    sender.enabled = false
    self.bvc!.cellIncrementButton.enabled = true
    self.bvc!.cellIncrementButton.alpha = 1.0
    self.bvc!.cellTimerButton.enabled = false
    self.bvc!.cellTimerButton.alpha = 0.5


  }
  
  func stepperPressed(sender: UIStepper)
  {
    //print("It Works, Value is --&gt;\(Int(sender.value).description)")
    self.bvc!.count = Int(sender.value)
    self.bvc!.cellCounterLabel.text = "Number of Errors: \(self.bvc!.count)"
  }
  
  func timerCountdown()
  {
    if self.bvc == nil
    {
    }
    else if(self.bvc!.timerCount > 0) {
      self.bvc!.timerCount -= 0.1
      self.bvc!.cellTimerLabel.text = String(format: "%.1f", self.bvc!.timerCount)
      if(self.bvc!.timerCount<0.5)
      {
        self.doneButton.enabled = true

      }
      if(self.bvc!.timerCount < 0.1)
      {


        self.bvc!.timerCount = 0
        self.bvc!.cellTimerLabel.text = "Press Done When Ready"
        self.bvc!.cellTimerLabel.font = UIFont(name: "Helvetica Neue", size: 20.0)
        self.doneButton.hidden = false
      }
    }
  }
  
  func domFootSelect(sender: UISegmentedControl)
  {
    switch sender.selectedSegmentIndex {
    case 0:
      self.bvc!.domFoot = "Left"
      self.bvc!.domFootDefault = 0
      print("Left")
    case 1:
      self.bvc!.domFoot = "Right"
      self.bvc!.domFootDefault = 1
      print("Right")
    default:
      print("Default")
      
    }
  }
  
}