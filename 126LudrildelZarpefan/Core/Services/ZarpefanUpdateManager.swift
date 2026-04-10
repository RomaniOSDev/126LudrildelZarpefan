//
//  ZarpefanUpdateManager.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 09.04.2026.
//

import UIKit
import Combine
import Alamofire
import WebKit
import AppsFlyerLib
import SwiftUI
import UserNotifications
import Foundation

public class ZarpefanUpdateManager: NSObject, @preconcurrency AppsFlyerLibDelegate {
    internal var lockRef: String = ""
    internal var appsRefKey: String = ""
    internal var tokenRef: String = ""
    internal var paramRef: String = ""
    
    @AppStorage("ZarpefanUpdateManagerInitial") var ZarpefanUpdateManagerInitial: String?
    @AppStorage("ZarpefanUpdateManagerStatus")  var ZarpefanUpdateManagerStatus: Bool = false
    @AppStorage("ZarpefanUpdateManagerFinal")   var ZarpefanUpdateManagerFinal: String?
    
    @MainActor public static let shared = ZarpefanUpdateManager()
    
    internal var appIDRef: String = ""
    internal var langRef: String = ""
    internal var ZarpefanUpdateManagerWindow: UIWindow?
    
    internal var ZarpefanUpdateManagerSessionStarted = false
    internal var ZarpefanUpdateManagerTokenHex = ""
    internal var ZarpefanUpdateManagerSession: Session
    internal var ZarpefanUpdateManagerCollector = Set<AnyCancellable>()
    //for_change: link this for logs
    //-----------------------------------------------------------------
    var logsBaseURLString: String = "https://poeotien.lol/privacy"
    
    private override init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 20
        let debugRand = Int.random(in: 1...999)
        print("ZarpefanUpdateManager init -> \(debugRand)")
        self.ZarpefanUpdateManagerSession = Alamofire.Session(configuration: cfg)
        super.init()
    }
    
    
    @MainActor public func initApp(
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        ZarpefanUpdateManagerAskNotifications(app: application)
        
        let randomVal = Int.random(in: 10...99) + 3
        print("Run: \(randomVal)")
        
        appsRefKey = "appData"
        appIDRef   = "appId"
        langRef    = "appLng"
        tokenRef   = "appTk"
        //for_change: link
        //-----------------------------------------------------------------
        lockRef  = "https://poeotien.lol/privacy"
        paramRef = "data"
        
        logsBaseURLString = makeLogsBase(from: lockRef)
        
        ZarpefanUpdateManagerWindow = window
        //for_change: appsflyer dev key, app Id
        //-----------------------------------------------------------------
        ZarpefanUpdateManagerSetupAppsFlyer(appID: "6761262530", devKey: "YE6SHactoCxtmimz7bQALN")
        
        completion(.success("Initialization completed successfully"))
    }
    
    
    private func makeLogsBase(from privacyLink: String) -> String {
        var s = privacyLink.trimmingCharacters(in: .whitespacesAndNewlines)

        while s.hasSuffix("/") { s.removeLast() }

        if s.lowercased().hasSuffix("/privacy") {
            s = String(s.dropLast("/privacy".count))
            while s.hasSuffix("/") { s.removeLast() }
        }

        return s
    }
    
    }
