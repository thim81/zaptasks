//
//  AppDelegate.swift
//  ZapTasks
//
//  Created by Tim Haselaars on 09/01/2025.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var panel: NSPanel?  // The reusable panel

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create a menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "bolt.circle", accessibilityDescription: "ZapTasks")
            button.action = #selector(statusBarButtonClicked)
        }
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let windowWidth: CGFloat = 300
        let windowHeight: CGFloat = 400

        // Get the current mouse location
        guard let screenHeight = NSScreen.main?.frame.height,
              let menuBarHeight = getMenuBarHeight() else {
            return
        }

        // Calculate the panel's position
        let mouseLocation = NSEvent.mouseLocation
        let windowX = mouseLocation.x - windowWidth / 2
        let windowY = screenHeight - windowHeight - menuBarHeight

        // Create the panel if it doesn’t exist
        if panel == nil {
            panel = getOrBuildPanel(size: NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight))
        }

        // Toggle panel visibility
        togglePanelVisibility(location: NSPoint(x: windowX, y: windowY))
    }

    func togglePanelVisibility(location: NSPoint) {
        guard let panel = panel else { return }
        if panel.isVisible {
            panel.orderOut(nil) // Hide the panel
        } else {
            panel.setFrameOrigin(location)
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func getMenuBarHeight() -> CGFloat? {
        guard let desktopFrame = NSScreen.main?.visibleFrame,
              let screenFrame = NSScreen.main?.frame else {
            return nil
        }
        return screenFrame.height - desktopFrame.height
    }

    func getOrBuildPanel(size: NSRect) -> NSPanel {
        if let existingPanel = panel {
            return existingPanel
        }

        let contentView = ContentView()
        let newPanel = NSPanel(
            contentRect: size,
            styleMask: [.nonactivatingPanel],  // Non-activating panel (doesn't show in app switcher)
            backing: .buffered,
            defer: false
        )
        newPanel.isFloatingPanel = true
        newPanel.level = .floating  // Keeps the panel above other windows
        newPanel.titleVisibility = .hidden
        newPanel.titlebarAppearsTransparent = true
        newPanel.styleMask.remove(.resizable)  // Remove resizing
        newPanel.styleMask.remove(.closable)  // Remove close button
        newPanel.hasShadow = true
        newPanel.isOpaque = false
        newPanel.backgroundColor = NSColor.clear

        // Only include one collection behavior
        newPanel.collectionBehavior = [.canJoinAllSpaces]  // Appear on all Spaces
        // Alternatively:
        // newPanel.collectionBehavior = [.moveToActiveSpace]  // Follow active Space

        newPanel.contentView = NSHostingView(rootView: contentView)
        newPanel.isReleasedWhenClosed = false
        return newPanel
    }
}
