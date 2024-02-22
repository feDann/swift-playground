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
        // let appWindows = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: Any]]
        
        for app in apps {
            if app.activationPolicy == NSApplication.ActivationPolicy.regular{
                print(app.localizedName ?? "Unnamed")
            }



            // let appProcess = app.processIdentifier 

            // if let windows = appWindows {
            //     for window in windows {
            //         if let windowProcess = window[kCGWindowOwnerPID as String] as? pid_t,
            //         windowProcess == appProcess {
            //             print(app.localizedName ?? "[Undefined Name]")
            //         }

            //     }
            // }

        }


    }
}

