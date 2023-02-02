//  Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.

import Foundation

func logDiagnostic(message: String,
                   errorOrException: Any? = nil,
                   file: String = #file,
                   line: Int = #line,
                   function: String = #function) {
    Logger.diagnostic("\(file):\(line) : \(function)", message: message, errorOrException: errorOrException)
}

func logError(message: String,
              file: String = #file,
              line: Int = #line,
              function: String = #function) {
    Logger.error("\(file):\(line) : \(function)", message: message)
}

func logDebug(message: String,
              file: String = #file,
              line: Int = #line,
              function: String = #function) {
    Logger.debug("\(file):\(line) : \(function)", message: message)
}

func logVerbose(message: String,
                file: String = #file,
                line: Int = #line,
                function: String = #function) {
    Logger.verbose("\(file):\(line) : \(function)", message: message)
}

class Logger: NSObject {
    private static var _logLevel: LogLevel = .off
    class var logLevel: LogLevel {
        get {
            return _logLevel
        }
        set(logLevel) {
            _logLevel = logLevel
            if logLevel == .off {
                #if SNOWPLOW_DEBUG
                _logLevel = .debug
                #elseif DEBUG
                _logLevel = .error
                #else
                _logLevel = .off
                #endif
            }
        }
    }

    static var delegate: LoggerDelegate?

    class func diagnostic(_ tag: String, message: String, errorOrException: Any?) {
        log(.error, tag: tag, message: message)
        trackError(withTag: tag, message: message, errorOrException: errorOrException)
    }

    class func error(_ tag: String, message: String) {
        log(.error, tag: tag, message: message)
    }

    class func debug(_ tag: String, message: String) {
        log(.debug, tag: tag, message: message)
    }

    class func verbose(_ tag: String, message: String) {
        log(.verbose, tag: tag, message: message)
    }

    // MARK: - Private methods

    private class func log(_ level: LogLevel, tag: String, message: String) {
        if level.rawValue > logLevel.rawValue {
            return
        }
        if let delegate = delegate {
            switch level {
            case .off:
                // do nothing.
                break
            case .error:
                delegate.error(tag, message: message)
            case .debug:
                delegate.debug(tag, message: message)
            case .verbose:
                delegate.verbose(tag, message: message)
            }
            return
        }
        #if SNOWPLOW_TEST
        // NSLog doesn't work on test target
        let output = "[\(["Off", "Error", "Error", "Debug", "Verbose"][level.rawValue])] \(tag): \(message)"
        print("\(output.utf8CString)")
        #elseif DEBUG
        // Log should be printed only during debugging
        print("[\(["Off", "Error", "Debug", "Verbose"][level.rawValue])] \(tag): \(message)")
        #endif
    }

    private class func trackError(withTag tag: String, message: String, errorOrException: Any?) {
        var error: Error?
        var exception: NSException?
        if errorOrException is Error {
            error = errorOrException as? Error
        } else if errorOrException is NSException {
            exception = errorOrException as? NSException
        }

        // Construct userInfo
        var userInfo: [String : Any] = [:]
        userInfo["tag"] = tag
        userInfo["message"] = message
        userInfo["error"] = error
        userInfo["exception"] = exception

        // Send notification to tracker
        NotificationCenter.default.post(
            name: NSNotification.Name("SPTrackerDiagnostic"),
            object: self,
            userInfo: userInfo)
    }
}
