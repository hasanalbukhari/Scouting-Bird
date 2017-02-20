//
//  Log.swift
//  La3eeb
//
//  Created by Hasan S. Al-Bukhari on 11/13/16.
//  Copyright © 2016 La3eeb. All rights reserved.
//

import UIKit
import MessageUI
import Foundation
import CocoaLumberjack
//import Fabric
//import Crashlytics

#if DEBUG
let ddLogLevelConsole: DDLogLevel = DDLogLevel.all
let ddLogLevelApple: DDLogLevel = DDLogLevel.off
let ddLogLevelFile: DDLogLevel = DDLogLevel.off
let ddLogLevelCrashlytics: DDLogLevel = DDLogLevel.off
#else
let ddLogLevelConsole: DDLogLevel = DDLogLevel.off
let ddLogLevelApple: DDLogLevel = DDLogLevel.info
let ddLogLevelFile: DDLogLevel = DDLogLevel.off
let ddLogLevelCrashlytics: DDLogLevel = DDLogLevel.off
#endif

class Log: NSObject, MFMailComposeViewControllerDelegate {

    class func err(_ message: String?) {
        DDLogError(Log.format(message: message, level: .error))
    }
    
    class func warn(_ message: String?) {
        DDLogWarn(Log.format(message: message, level: .warning))
    }
    
    class func info(_ message: String?) {
        DDLogInfo(Log.format(message: message, level: .info))
    }
    
    class func debug(_ message: String?) {
        DDLogDebug(Log.format(message: message, level: .debug))
    }
    
    class func ver(_ message: String?) {
        DDLogVerbose(Log.format(message: message, level: .verbose))
    }
    
    var fileLogger: DDFileLogger!
    
    override init() {
        super.init()
        
        // init file logger
        fileLogger = DDFileLogger()
        
        self.configureLogging()
    }
    
    // Configure CocoaLumberjack
    func configureLogging() {
        
        // Add loggers
        // TTY = Xcode console
        let consoleLogger: DDTTYLogger = DDTTYLogger.sharedInstance()
        
        // add logger
        DDLog.add(consoleLogger, with: ddLogLevelConsole)
        
        // ASL = Apple System Logs
        DDLog.add(DDASLLogger.sharedInstance(), with: ddLogLevelApple)
        
        // File logger
        // Configure file Logger
        fileLogger.maximumFileSize = 1024 * 1024
        fileLogger.rollingFrequency = 3600.0 * 24.0
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        
        // Add file logger
        DDLog.add(fileLogger, with: ddLogLevelFile)
        
        // Crashlytics logger
//        Fabric.with([Crashlytics.self])
        
        // Initialize Logger
//        let crashlyticsLogger = CrashlyticsLogger.sharedInstance
        
        // Add crashlytics logger
//        DDLog.add(crashlyticsLogger, with: ddLogLevelCrashlytics)
        
        Log.info("Lumberjack logging started ...")
    }
    
    // Crashlytics custom logger.
    class CrashlyticsLogger : DDAbstractLogger
    {
        static let sharedInstance = CrashlyticsLogger()
        
        override func log(message logMessage: DDLogMessage!) {
            
//            CLSLogv(Log.format(message: logMessage.message, level:logMessage.level), getVaList([]))
        }
    }
    
    // logging messages formatter
    class func format(message: String?, level: DDLogLevel) -> String! {
        
#if DEBUG
            return message ?? "nil"
#else
        
        var lvlString: String
        switch level {
        case DDLogLevel.error:
            lvlString = "error"
            break
        case DDLogLevel.warning:
            lvlString = "warn"
            break
        case DDLogLevel.info:
            lvlString = "info"
            break
        case DDLogLevel.debug:
            lvlString = "debug"
            break
        case DDLogLevel.verbose:
            lvlString = "verbo"
            break
        default:
            lvlString = "none"
        }
        
        let leadingSpaces: String = String(repeating: " ", count: 5 - lvlString.characters.count)
        
        return "\(leadingSpaces)\(lvlString) :: \(message ?? nil)"
#endif
    }
    
    func errorLogData() -> NSMutableArray
    {
        Log.info("Collecting logging files data")
        
        let maximumLogFilesToReturn: UInt = min(fileLogger.logFileManager.maximumNumberOfLogFiles, 10)
        let errorLogFiles: NSMutableArray = NSMutableArray(capacity: Int(maximumLogFilesToReturn))
        var sortedLogFileInfos: [DDLogFileInfo] = fileLogger.logFileManager.sortedLogFileInfos
        
        for i in 0...min(sortedLogFileInfos.count, Int(maximumLogFilesToReturn)) {
            let logFileInfo: DDLogFileInfo = sortedLogFileInfos[i]
            do {
                let fileData: NSData = try NSData(contentsOfFile: logFileInfo.filePath)
                errorLogFiles.add(fileData)
            } catch {
                Log.err("Logging file #\(i) + : file not found!")
            }
        }
        return errorLogFiles
    }
    
    func composeEmailWithDebugAttachment(launcher: UIViewController) {
        Log.info("Try to send log file by email.")
        if MFMailComposeViewController.canSendMail() {
            
            let errorLogData: NSMutableData = NSMutableData()
            for errorLogFileData in self.errorLogData() {
                errorLogData.append(errorLogFileData as! NSData as Data)
            }
            
            let mailViewController: MFMailComposeViewController =  MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
            
            mailViewController.setSubject("La3eeb log file")
            mailViewController.setToRecipients(["hasanal_bukhari@hotmail.com"])
            
            mailViewController.addAttachmentData(errorLogData as Data, mimeType: "text/plain", fileName: "errorLog.txt")
            
            launcher.present(mailViewController, animated: true, completion: nil)
            
        } else {
            Log.info("Couldn't open mail app. probably because no email account is set.")
            
            let message: String = "Sorry, your issue can't be reported right now. This is mostly because no mail accounts are set up on your mobile device."
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            launcher.present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if result == MFMailComposeResult.sent
        {
            fileLogger.rollLogFile(withCompletion: {
                
                let paths: [DDLogFileInfo] = self.fileLogger.logFileManager.unsortedLogFileInfos
                
                for logFileInfo in paths {
                    
                    do {
                        try FileManager.default.removeItem(atPath: logFileInfo.filePath)
                    } catch {
                        Log.err("One log file not found on reset ...")
                    }
                    
                    logFileInfo.reset()
                }
                
                Log.info("Finished resetting log files ...")
            })
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
