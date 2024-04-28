import Foundation
import os

extension String: Error {}

func print(_ items: String...,
                  log: OSLog = .default,
                  fileName: String = #file,
                  function: String = #function,
                  line: Int = #line) {
#if DEBUG
    let separator = " "
    let fileNameString = fileName.split(separator: "/").last ?? "-"
    let functionString = function.split(separator: "(").first ?? "-"
    let logString: CVarArg = "\(fileNameString):\(functionString)():\(line)] \(items.map { "\($0)" }.joined(separator: separator))"
    // https://stackoverflow.com/questions/45908875/apple-iphone-debugging-with-console-private
    os_log(.debug, log: log, "%{public}@", logString)
#else
    // Swift.print("RELEASE MODE")
#endif
}
