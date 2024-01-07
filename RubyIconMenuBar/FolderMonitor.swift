//
//  AppDelegate.swift
//  FolderMonitor
//
//  Created by yuma on 2022/04/06.
//

import Foundation

class FolderMonitor {

    // File descriptor for the monitored folder
    private var monitoredFolderFileDescriptor: CInt = -1
    
    // DispatchQueue for folder monitoring
    private let folderMonitorQueue = DispatchQueue(label: "FolderMonitorQueue", attributes: .concurrent)
    
    // DispatchSource for file system events
    private var folderMonitorSource: DispatchSourceFileSystemObject?
    
    // URL of the folder to be monitored
    let url: Foundation.URL
    
    // Closure to be executed when the folder changes
    var folderDidChange: (() -> Void)?
    
    // Initialize FolderMonitor with a given URL
    init(url: Foundation.URL) {
        self.url = url
    }

    // Start monitoring the folder
    func startMonitoring() {
        // Check if already monitoring or file descriptor is invalid
        guard folderMonitorSource == nil && monitoredFolderFileDescriptor == -1 else {
            return
        }
        
        // Open the folder for monitoring
        monitoredFolderFileDescriptor = open(url.path, O_EVTONLY)
        
        // Create DispatchSource for file system events
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredFolderFileDescriptor,eventMask: .write,queue: folderMonitorQueue)
        
        // Set event handler to execute the folderDidChange closure
        folderMonitorSource?.setEventHandler { [weak self] in
            self?.folderDidChange?()
        }

        // Set cancel handler to clean up resources on cancellation
        folderMonitorSource?.setCancelHandler { [weak self] in
            guard let strongSelf = self else {
                return
            }
            close(strongSelf.monitoredFolderFileDescriptor)
            strongSelf.monitoredFolderFileDescriptor = -1
            strongSelf.folderMonitorSource = nil
        }

        // Resume the DispatchSource to start monitoring
        folderMonitorSource?.resume()
    }

    // Stop monitoring the folder
    func stopMonitoring() {
        folderMonitorSource?.cancel()
    }
}
