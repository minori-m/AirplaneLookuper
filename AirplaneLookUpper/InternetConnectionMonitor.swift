//
// InternetConnectionMonitor.swift
// AWSS3Integration
//
// Created by Soham Paul
// Copyright © 2019 Personal. All rights reserved.
//
import UIKit
import Network
@available(iOS 12.0, *)
class InternetConnectionMonitor {
    static let shared = InternetConnectionMonitor()
    private init () { }
    var monitor: NWPathMonitor?
    var isMonitoring = false
    var didStartMonitoringHandler: (() -> Void)?
    var didStopMonitoringHandler: (() -> Void)?
    var netStatusChangeHandler: (() -> Void)?
    func startMonitoring() {
        guard !isMonitoring else { return }
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label:"InternetConnectionMonitor")
        monitor?.start(queue: queue)
        monitor?.pathUpdateHandler = { _ in
            self.netStatusChangeHandler?()
        }
        isMonitoring = true
        didStartMonitoringHandler?()
    }
    func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else { return }
        monitor.cancel()
        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
}
import SystemConfiguration
public class ReachabilityTest {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
