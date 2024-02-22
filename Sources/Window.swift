import SwiftUI


extension AXValue {

    static func from (value: Any, type: AXValueType) -> AXValue? {
        return withUnsafePointer(to: value) { ptr in
            AXValueCreate(type, ptr)
        }
    }



}


extension AXUIElement {

    func getValue (_ attribute: NSAccessibility.Attribute) -> AnyObject? {
        var value: AnyObject?

        if AXUIElementCopyAttributeValue(self, attribute as CFString , &value) == .success {
            return value
        }
        return nil
    }

    @discardableResult
    func setValue(_ attribute: NSAccessibility.Attribute, value: AnyObject) -> Bool {
        let result = AXUIElementSetAttributeValue(self, attribute as CFString, value)
        return result == .success
    }

    @discardableResult
    func setValue(_ attribute: NSAccessibility.Attribute, value: Bool) -> Bool {
        return setValue(attribute, value: value as CFBoolean)
    }

    @discardableResult
    func setValue(_ attribute: NSAccessibility.Attribute, value: CGPoint) -> Bool {
        guard let axValue = AXValue.from(value: value, type: .cgPoint) else { return false }
        return self.setValue(attribute, value: axValue)
    }

    @discardableResult
    func setValue(_ attribute: NSAccessibility.Attribute, value: CGSize) -> Bool {
        guard let axValue = AXValue.from(value: value, type: .cgSize) else { return false }
        return self.setValue(attribute, value: axValue)
    }

    func performAction(_ action: String) {
        AXUIElementPerformAction(self, action as CFString)
    }

    func getElementAtPosition(_ position: CGPoint) -> AXUIElement? {
        var element: AXUIElement?
        let result = AXUIElementCopyElementAtPosition(self, Float(position.x), Float(position.y), &element)
        guard result == .success else { return nil }
        return element
    }
}


class Window {

    let window : AXUIElement
    var windowId: CGWindowID = CGWindowID(0)
    let app: NSRunningApplication?
    var pid: pid_t = 0

    var role: NSAccessibility.Role? {
        guard let value = self.window.getValue(.role) as? String else { return nil }
        return NSAccessibility.Role(rawValue: value)
    }

    var subrole: NSAccessibility.Subrole? {
        guard let value = self.window.getValue(.subrole) as? String else { return nil }
        return NSAccessibility.Subrole(rawValue: value)
    }

    var position: CGPoint {
        var point: CGPoint = .zero
        guard let value = self.window.getValue(.position) else { return point }
        // swiftlint:disable force_cast
        AXValueGetValue(value as! AXValue, .cgPoint, &point)    // Convert to CGPoint
        // swiftlint:enable force_cast
        return point
    }

    @discardableResult
    func setPosition(_ position: CGPoint) -> Bool {
        return self.window.setValue(.position, value: position)
    }

    var size: CGSize {
        var size: CGSize = .zero
        guard let value = self.window.getValue(.size) else { return size }
        // swiftlint:disable force_cast
        AXValueGetValue(value as! AXValue, .cgSize, &size)      // Convert to CGSize
        // swiftlint:enable force_cast
        return size
    }
    @discardableResult
    func setSize(_ size: CGSize) -> Bool {
        return self.window.setValue(.size, value: size)
    }

    // The constructor could fail to create the Object, for example if the AXUIElement passed is not a window
    init?(element: AXUIElement, pid: pid_t? = nil ) {
        var pid: pid_t? = pid
        self.window = element;
        
        self.pid = pid ?? 0
        if pid == nil {
            AXUIElementGetPid(self.window, &self.pid)
            pid = self.pid
        }

        self.app = NSWorkspace.shared.runningApplications.first(where: { $0.processIdentifier == pid })
        
        guard _AXUIElementGetWindow(self.window, &self.windowId) == .success else { return nil }
        guard self.role == .window || self.subrole == .standardWindow else { return nil } // if the returned role is different from any of this two the object passed is surely not a window

    }

    convenience init?(pid: pid_t) { // might create problems?
        let element = AXUIElementCreateApplication(pid)
        guard let window = element.getValue(.focusedWindow) else { return nil }
        // swiftlint:disable force_cast
        self.init(element: window as! AXUIElement, pid: pid)
        // swiftlint:enable force_cast
    }
    



}