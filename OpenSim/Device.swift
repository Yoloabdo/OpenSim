//
//  Device.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct Device {
    
    enum State: Int {
        case Shutdown = 1
        case Unknown = 2
        case Booted = 3
    }
    
    let UDID: String
    let type: String
    let name: String
    let runtime: String
    let state: State
    let applications: [Application]
    var applicationStates: [String: ApplicationState]
    
    init(UDID: String, type: String, name: String, runtime: String, state: State) {
        self.UDID = UDID
        self.type = type
        self.name = name
        self.runtime = runtime
        self.state = state
        
        let applicationPath = URLHelper.deviceURLForUDID(self.UDID).URLByAppendingPathComponent("data/Containers/Bundle/Application")
        do {
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(applicationPath, includingPropertiesForKeys: nil, options: [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles])
            self.applications = contents.map { Application(URL: $0) }.filter { $0 != nil }.map { $0! }
        } catch {
            self.applications = []
        }
        
        applicationStates = [String: ApplicationState]()
        if let applicationStateDict = NSDictionary(contentsOfURL: URLHelper.applicationStateURLForUDID(self.UDID)) as? [String: [String: AnyObject]] {
            applicationStateDict.forEach { (key, dict) in
                if let compatibilityInfoDict = dict["compatibilityInfo"] as? [String: AnyObject],
                    bundlePath = compatibilityInfoDict["bundlePath"] as? String,
                    sandboxPath = compatibilityInfoDict["sandboxPath"] as? String,
                    bundleContainerPath = compatibilityInfoDict["bundleContainerPath"] as? String {
                        applicationStates[key] = ApplicationState(
                            bundlePath: bundlePath,
                            sandboxPath: sandboxPath,
                            bundleContainerPath: bundleContainerPath
                        )
                }
            }
        }
    }
    
}