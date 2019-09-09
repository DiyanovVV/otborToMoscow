//
//  ViewController.swift
//  OtborWINER
//
//  Created by WSR on 08/09/2019.
//  Copyright © 2019 WSR. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON


class ViewController: UIViewController, ChartViewDelegate, UITextFieldDelegate {


    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    
    var months: [String]!
    var City: String = "Moscow"
    var tempMassiv: Array<Double> = []
    var dateMassiv: Array<String> = []
    var imgage: UIImage? = nil
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeather()
        
        textField.placeholder = "Введите город"
        textField.delegate = self
        
        barChartView.delegate = self
        
       // print("\(self.tempMassiv.count) ze luppa and pupa")
        
        screenShotMethod()
//
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
//                    self.zapolnenie()
//              })
    }
    func getWeather() {
        tempMassiv.removeAll()
        dateMassiv.removeAll()
        
        let APIUrl = "http://api.openweathermap.org/data/2.5/forecast?q=\(City)&units=metric&apikey=6da8e8bdb22e1d408ffb437eab399b45"
    Alamofire.request(APIUrl,method: .get).validate().responseJSON { response in
        switch response.result {
            
        case .success(let value):
            let json = JSON(value)
//            json["list"].count
            for i in 0...json["list"].count {
                
                self.tempMassiv.append(Double(String(format: "%.1f", json["list"][i]["main"]["temp"].doubleValue)) as! Double)
                self.dateMassiv.append(json["list"][i]["dt_txt"].stringValue)
                print("\(self.tempMassiv) ze luppa and pupa")
            }
            self.cityLabel.text = self.City
            self.zapolnenie()
            
            
            
            
        case .failure:
            let alert = UIAlertController(title: "Такого города не существует", message: nil , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            }
        
        
        }

    }
    
    func zapolnenie() {
        setChart(dataPoints: self.dateMassiv, values: self.tempMassiv)
        self.barChartView.reloadInputViews()
    }
    
//
    // все что ниже связано с графиком
//
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."

        var dataEntries: [BarChartDataEntry] = []

        for i in 0..<dataPoints.count-1 {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
          //  let dataEntry = BarChartDataEntry(value: values[i], index: i)
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Units Sold")
        let chartDatta = BarChartData(dataSet: chartDataSet)
       // let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
        barChartView.data = chartDatta



        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        //        chartDataSet.colors = ChartColorTemplates.colorful()

        barChartView.xAxis.labelPosition = .bottom

        //        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)

        //        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        //barChartView?.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)

        //let ll = ChartLimitLine(limit: 15.0, label: "15 градусов")
       // barChartView.rightAxis.addLimitLine(ll)

    }

    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        //print("\(entry.value) in \(months?[entry.index])")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.City = textField.text!
        getWeather()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
//            self.zapolnenie()
//        })
        
        return true
    }
    
    func screenShotMethod() {
        //Create the UIImage
        UIGraphicsBeginImageContext(barChartView.frame.size)
        barChartView.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.imgage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("\(self.imgage) dadadad  ")

        
    }
    
    func createPDF(image: UIImage) -> NSData? {
        
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
        
        var mediaBox = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
        
        pdfContext.beginPage(mediaBox: &mediaBox)
        pdfContext.draw(image.cgImage!, in: mediaBox)
        pdfContext.endPage()
        
        return pdfData
    }
    
    @IBAction func shareFunc(_ sender: Any) {
        self.screenShotMethod()
        
        
        let objectsToShare = self.createPDF(image: self.imgage!)
        
       // let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
       
        
        let activityVC = UIActivityViewController(activityItems: [objectsToShare as? Any], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        
        if let popOver = activityVC.popoverPresentationController {
            popOver.sourceView = self.view
            //popOver.sourceRect =
            //popOver.sourceRect =
            //popOver.barButtonItem
        }
        
        present(activityVC, animated: true, completion: nil)
    }
    

}

