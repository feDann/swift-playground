// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import AppKit

@main
struct Playground {
    static func main() {
        print("[INFO] Parsing Applications")
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications
        let appWindows = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: Any]]
        
        for app in apps {
            if app.isActive {
                let appProcess = app.processIdentifier 

                if let windows = appWindows {
                    for window in windows {
                        if let windowProcess = window[kCGWindowOwnerPID as String] as? pid_t,
                        windowProcess == appProcess {
                            guard let windowObject = Window(pid: windowProcess) else {
                                print("Error")
                                return 
                            }

                            print(windowObject.position)
                            print(windowObject.size)

                            windowObject.setSize(CGSize(width:3440, height:1440))
                        }

                    }
                }
            }



            

        }


    }
}

