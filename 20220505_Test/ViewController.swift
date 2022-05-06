//
//  ViewController.swift
//  20220505_Test
//
//  Created by crawford on 2022/5/5.
//

import UIKit
import SwiftyJSON
import Starscream
import Reachability

struct dataDic : Codable {
    var e : String
    var E : Int
    var s : String
    var t : Int
    var p : String
    var q : String
    var b : Int
    var a : Int
    var T : Int
    var m : String
    var M : String
}
var dataArray = [dataDic]()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableviewOfTest: UITableView!
    
    var socketManager: WebSocket?
    var isConnected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initWebSocket()
        
        self.socketManager?.connect()
        
        tableviewOfTest.delegate = self
        tableviewOfTest.dataSource = self
        
        tableviewOfTest.estimatedRowHeight = 200.0
        tableviewOfTest.rowHeight = UITableView.automaticDimension
        
        self.tableviewOfTest.transform = CGAffineTransform(rotationAngle: .pi)
        
        let timer = Timer(timeInterval: 5, repeats: true) { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                if self.isConnected == false {
                    self.socketManager?.connect()
                }
                self.tableviewOfTest.reloadData()
            }
        }
        RunLoop.current.add(timer, forMode: .default)
    }
    @objc func loadData(){
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.tableviewOfTest.reloadData()
            }
            
        }
    
private func initWebSocket() {
    var request = URLRequest(url: URL(string: "wss://stream.yshyqxx.com/stream?streams=btcusdt@trade")!)
    request.timeoutInterval = 5
    request.setValue("some message", forHTTPHeaderField: "Qi-WebSocket-Header")
    request.setValue("some message", forHTTPHeaderField: "Qi-WebSocket-Protocol")
    request.setValue("0.0.1", forHTTPHeaderField: "Qi-WebSocket-Version")
    request.setValue("some message", forHTTPHeaderField: "Qi-WebSocket-Protocol-2")
    socketManager = WebSocket(request: request)
    socketManager?.delegate = self
}
    // 連接
    @objc func connetButtonClicked() {
        socketManager?.connect()
    }
    // 斷線
    @objc func closeButtonCliked() {
        socketManager?.disconnect()
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if dataArray.count < 41 {
            return dataArray.count
        }
        else {
            dataArray.removeSubrange(0...dataArray.count-41)
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let timeInterval:TimeInterval = TimeInterval((dataArray[indexPath.row].E/1000).description) ?? 0
        let date = Date(timeIntervalSince1970: timeInterval)
        let dformatter = DateFormatter()
        dformatter.dateFormat = "HH:mm:ss"
        let textTime = dformatter.string(from: date)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! myTableViewCell
        cell.contentView.transform = CGAffineTransform(rotationAngle: .pi)
        if dataArray.count < 41 {
            cell.labelOfTime.text = textTime.description
            cell.labelOfPrice.text = (Float(dataArray[indexPath.row].p)!).description
            cell.labelOfAmount.text = (Float(dataArray[indexPath.row].q)!).description
        }else {
            cell.labelOfTime.text = textTime.description
            cell.labelOfPrice.text = (Float(dataArray[indexPath.row].p)!).description
            cell.labelOfAmount.text = (Float(dataArray[indexPath.row].q)!).description
        }
        return cell
    }
}

extension ViewController: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
                    if let jsonData = string.data(using: .utf8) {
                        do {
                            let json: JSON = try JSON(data: jsonData)
                            dataArray.append(dataDic(
                                e: json["data"]["e"].string ?? "N/A",
                                E: json["data"]["E"].int ?? 0,
                                s: json["data"]["s"].string ?? "N/A",
                                t: json["data"]["t"].int ?? 0,
                                p: json["data"]["p"].string ?? "N/A",
                                q: json["data"]["q"].string ?? "N/A",
                                b: json["data"]["b"].int ?? 0,
                                a: json["data"]["a"].int ?? 0,
                                T: json["data"]["T"].int ?? 0,
                                m: json["data"]["m"].string ?? "N/A",
                                M: json["data"]["M"].string ?? "N/A"
                                ))
                            //print(json["data"]["E"])
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
            print("Received text:\(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            print("Received data: \(String(describing: error))")
        }
    }
}
