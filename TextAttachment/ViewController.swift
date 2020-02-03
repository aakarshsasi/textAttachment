//
//  ViewController.swift
//  TextAttachment
//
//  Created by Aakarsh S on 20/01/20.
//  Copyright © 2020 Aakarsh. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getDetails()
    }
    var imageCount = 0;
    var content = NSMutableAttributedString(string: "")
    
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    func getDetails()
        {
           
    //        let headers = [
    //            "Authorization" : "Bearer "+retrievedToken!
    //        ]
            
            let url = "https://api.npoint.io/5ab45880fc3dd8c41671/data/0"
            let urlString = URL(string: url)
                       var mutableURLRequest = URLRequest(url: urlString!)
                       mutableURLRequest.httpMethod = "GET"
    //                   mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        
            Alamofire.request(mutableURLRequest).responseJSON { response in
                switch response.result {
                    
                case .success:
                    let json = response.result.value as! [String:Any]
                    print(json)
                  
                    let newsText = json["text"] as? [String] ?? ["Please try again later"]
                   
                   guard let images = json["images"] as? [[String:Any]]
                    else{
                        return
                    }
                    let titleImageLink = images[0]["link"] as? String
    //                let titleImage = self.urlToImage(url: titleImageLink!)
                    
                    DispatchQueue.main.async {
                        
                        self.newsImage.kf.setImage(with: URL(string:titleImageLink ?? " "))
                       
                    
                        
                    }
                    for para in newsText{
                        if(para == "[IMAGE]")
                        {
                            print("Image Found")
                            let paraImageLink = images[self.imageCount]["link"] as? String
                            
                            
                            let downloader = ImageDownloader.default
                            downloader.downloadImage(with: URL(string:paraImageLink!)!, options: .none) { result in
                                switch result {
                                case .success(let value): let paraImageResized = self.ResizeImage(value.image, targetSize: CGSize(width: 500.0, height: 300.0))
                                let imageAttachement = NSTextAttachment()
                                imageAttachement.image = paraImageResized
                                let imageString = NSAttributedString(attachment: imageAttachement)
                                self.content.append(imageString)
                                self.content.append(NSMutableAttributedString(string: "\n\n"))
                                self.imageCount+=1
                                    
                                case .failure(let error):
                                    print(error)
                                }
                            }
                            //
                        }
                        else{
                            self.content.append(NSAttributedString(string: para+"\n\n"))
                            
                            
                        }
                        print(self.content)
                    }
                    DispatchQueue.main.async {
                        
                        self.text.attributedText = self.content
                    }
                    
                    
                    
                case .failure:
                    print("failed to get details")
                    break
                }
            }
        }
    
    //Function to resize Images
    @IBOutlet weak var text: UILabel!
    
    func ResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
          let size = image.size
          
          let widthRatio  = targetSize.width  / image.size.width
          let heightRatio = targetSize.height / image.size.height
          
          // Figure out what our orientation is, and use that to form the rectangle
          var newSize: CGSize
          if(widthRatio > heightRatio) {
              newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
          } else {
              newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
          }
          
          // This is the rect that we've calculated out and this is what is actually used below
          let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
          
          // Actually do the resizing to the rect using the ImageContext stuff
          UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
          image.draw(in: rect)
          let newImage = UIGraphicsGetImageFromCurrentImageContext()
          UIGraphicsEndImageContext()
          
          return newImage
      }
}

