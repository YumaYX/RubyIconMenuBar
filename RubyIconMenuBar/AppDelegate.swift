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
    
    private var color: Bool?
    
    var rbenvPath: URL? = nil
    
    var imageView = NSImageView()
    
    var folderMonitor: FolderMonitor!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize the application
        color = false
        let myWidth: CGFloat = 14
        statusBar = NSStatusBar.init()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem!.menu = myMenu
        
        statusItem?.button?.title = ""
        
        imageView = NSImageView(frame: NSRect(x: 0, y: 5, width: myWidth, height: myWidth))
        imageView.imageScaling = .scaleAxesIndependently

        let image = NSImage.init(imageLiteralResourceName: "ruby-logo.png")
        if let image = NSImage(named: "ruby-logo.png") {
            imageView.image = image
            imageView.image?.size = imageView.frame.size
        }
        changeIconColor()
        
        let rubyMenuItem = NSMenuItem(
            title: "Go to ruby-lang.org..",
            action: #selector(openRubySite),
            keyEquivalent: ""
        )
        rubyMenuItem.target = self
        myMenu.addItem(rubyMenuItem)
        
        let rubyMenuItemColor = NSMenuItem(
            title: "Change Icon Color",
            action: #selector(changeIconColor),
            keyEquivalent: ""
        )
    
        rubyMenuItemColor.target = self
        myMenu.addItem(rubyMenuItemColor)
        
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
    
    @objc func changeIconColor() {

        imageView.image = nil
        if let image = NSImage(named: "ruby-logo.png") {
            imageView.image = image
            imageView.image?.size = imageView.frame.size
            if color! {
                statusItem?.button?.image = image.mono
                color = false
            }else {
                statusItem?.button?.image = image
                color = true
            }
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

extension NSImage {
    public var ciImage: CIImage? {
        guard let imageData = self.tiffRepresentation else { return nil }
        return CIImage(data: imageData)
    }
    
    public var mono: NSImage {
        guard let monoFilter = CIFilter(name: "CIPhotoEffectMono") else { return self }
        monoFilter.setValue(self.ciImage, forKey: kCIInputImageKey)
        guard let output = monoFilter.outputImage else { return self }
        let rep = NSCIImageRep(ciImage: output)
        let nsImage = NSImage(size: CGSize(width: 14,height: 14))
        nsImage.addRepresentation(rep)
        return nsImage
    }
}
