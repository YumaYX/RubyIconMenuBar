//
//  AppDelegate.swift
//  RubyIconMenuBar
//
//  Created by yuma on 2022/04/06.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusBar: NSStatusBar?
    private var statusItem: NSStatusItem?
    let myMenu = NSMenu()
    
    var rbenvPath: URL? = nil
    
    var folderMonitor: FolderMonitor!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize the application
        let myWidth: CGFloat = 17
        statusBar = NSStatusBar.init()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem!.menu = myMenu
        
        statusItem?.button?.title = ""
        
        let imageView = NSImageView(frame: NSRect(x: 0, y: 8, width: myWidth, height: myWidth))
        let image = NSImage.init(imageLiteralResourceName: "ruby-logo.png")
        imageView.image = image
        
        let rubyMenuItem = NSMenuItem(
            title: "Go to ruby-lang.org..",
            action: #selector(openRubySite),
            keyEquivalent: ""
        )
        rubyMenuItem.target = self
        myMenu.addItem(rubyMenuItem)
        myMenu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: ""))
        
        let file = ".rbenv/version"
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        rbenvPath = homeDir.appendingPathComponent(file)
        
        statusItem?.button?.imagePosition = NSControl.ImagePosition.imageLeft
        statusItem?.button?.image = image
        
        handleChanges()
        
        folderMonitor = FolderMonitor(url: rbenvPath!)
        folderMonitor.folderDidChange = { [weak self] in
            self?.handleChanges()
        }
        folderMonitor.startMonitoring()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Cleanup code when the application is about to terminate
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func quit(_ sender: Any) {
        // Quit the application
        NSApplication.shared.terminate(self)
    }
    
    @objc func openRubySite() {
        // Open the Ruby-lang website
        if let url = URL(string: "https://www.ruby-lang.org/ja") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func handleChanges() {
        // Update the status item's title with the current Ruby version
        DispatchQueue.main.async {
            self.statusItem?.button?.title = "\(self.getCurrentRubyVer())"
        }
    }
    
    func getCurrentRubyVer() -> String {
        // Get the current Ruby version from the specified file
        do {
            let text = try String(contentsOf: rbenvPath!)
            return text.trimmingCharacters(in: .newlines)
        } catch {
            print(error)
        }
        return ""
    }
}
