//
//  ViewController.swift
//  SOFileSharing
//
//  Created by Hitesh on 8/20/16.
//  Copyright © 2016 myCompany. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Decalir IB
    @IBOutlet var tblList: UITableView?
    
    //Declair Variables
    var arrAllFiles = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadDataFromDocumentDirectory()
    }
    
    func loadDataFromDocumentDirectory() {
        //Get All Files from Document Directory to Array
        arrAllFiles = listFilesFromDocumentsFolder()
        tblList?.reloadData()
    }
    
    
    //MARK:- Get List of document from document directory
    func listFilesFromDocumentsFolder() -> [String] {
        let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        if dirs.count != 0 {
            let dir = dirs[0]
            let fileList = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir)
            return fileList   // edit: added ! for Swift 1.2 compatibitily
        }else{
            let fileList = ["No Any File Found."]
            return fileList
        }
    }
    
    
    // MARK: - UIImagePickerController Get Image from Gallary Methods
    //For Delegate self add UIImagePickerControllerDelegate, UINavigationControllerDelegate
    @IBAction func getImageFromGallary() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true;
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let dictPicker:Dictionary = info;
        print(dictPicker)
        
        var newImage: UIImage
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let result = PHAsset.fetchAssetsWithALAssetURLs([imageURL], options: nil)
        let filename = (result.firstObject?.filename)! as String

        //Create path for save image in document directory
        let localPath = self.pathToDocsFolder(filename)
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        let data = UIImagePNGRepresentation(newImage)
        data!.writeToFile(localPath, atomically: true)
        
        dismissViewControllerAnimated(true) {
            //Reload tableview
            self.loadDataFromDocumentDirectory()
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK:- Get path of document directory
    func pathToDocsFolder(fileName:String) -> String {
        let pathToDocumentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return pathToDocumentsFolder.stringByAppendingString("/\(fileName)")
    }
    
    //MARK:- Remove document from document directory
    func removeOldFileIfExist(fileName:String) {
        let filePath = self.pathToDocsFolder(fileName)
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            } catch {
                print("an error during a removing")
            }
        }
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAllFiles.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: NSIndexPath) {
        cell.textLabel?.text = arrAllFiles[forRowAtIndexPath.row];
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.removeOldFileIfExist(arrAllFiles[indexPath.row])
            arrAllFiles.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

