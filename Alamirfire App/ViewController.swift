//
//  ViewController.swift
//  Alamirfire App
//
//  Created by Victor Smirnov on 02/01/2018.
//  Copyright © 2018 Victor Smirnov. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
  
  fileprivate var items = [Item]()
  fileprivate var text = String()
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var tableView: UITableView!
  @IBAction func sendRequest(_ sender: UIButton) {
    
    let url = "http://www.gutenberg.org/cache/epub/35688/pg35688.txt"
    let filename = "text_file.txt"
    
    loadText(from: url, to: filename)
    
    Alamofire.request("https://jsonplaceholder.typicode.com/photos", method: .get).responseJSON {response in
      guard response.result.isSuccess else {
        print("Error in request data \(String(describing: response.result.error))")
        return
      }
      guard let arrayOfItems = response.result.value as? [[String: AnyObject]]
        else {
          print("Can not create array.")
          return
      }
      
      for itm in arrayOfItems {
        let item = Item(albumId: itm["albumId"] as! Int, id: itm["id"] as! Int, title: itm["title"] as! String, url: itm["url" ] as! String)
        self.items.append(item)
      }
      DispatchQueue.main.async {
        self.tableView.reloadData()
        self.textView.text = self.text
      }
    }
  }
  
  func loadText(from url: String, to file: String) {
    
    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
      let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let fileUrl = documentsUrl.appendingPathComponent(file)
      
      return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
    }
    
    Alamofire.download(url, to: destination).response { response in
      
      if response.error == nil, let textPath = response.destinationURL?.path {
        do {
          self.text = try String(contentsOfFile: textPath, encoding: .utf8)
        } catch {
          self.text = "Error: \(error.localizedDescription)"
        }
      }
    }
  }
}

// Supporting protocols for tableview (datasource and delegate)
extension ViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ItemCell
    configureCell(cell: cell, for: indexPath)
    return cell
  }
  
  private func configureCell(cell: ItemCell, for indexPath: IndexPath) {
    
    let item = items[indexPath.row]
    cell.idLabel.text = "\(item.id)"
    cell.albumIdLabel.text = "\(item.albumId)"
    cell.urlLabel.text = "\(item.url)"
    cell.titleLabel.text = "\(item.title)"
    
  }
}

