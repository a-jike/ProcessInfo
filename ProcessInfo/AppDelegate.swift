//
//  AppDelegate.swift
//  ProcessInfo
//
//  Created by Atsushi Jike on 2019/03/14.
//  Copyright © 2019 Atsushi Jike. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("\(CPU().info())")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

public class CPU {
    public func info() {
        let HOST_BASIC_INFO_COUNT = MemoryLayout<host_basic_info>.stride/MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(HOST_BASIC_INFO_COUNT)
        let hostInfo = host_basic_info_t.allocate(capacity: 1)
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: HOST_BASIC_INFO_COUNT) {
            host_info(mach_host_self(), HOST_BASIC_INFO, $0, &size)
        }
        
        print(result, hostInfo.pointee)
        hostInfo.deallocate()
        
        // mach/machine.h
//        public var max_cpus: integer_t /* max number of CPUs possible */
//        public var avail_cpus: integer_t /* number of CPUs now available */
//        public var memory_size: natural_t /* size of memory in bytes, capped at 2 GB */
//        public var cpu_type: cpu_type_t /* cpu type */
//        public var cpu_subtype: cpu_subtype_t /* cpu subtype */
//        public var cpu_threadtype: cpu_threadtype_t /* cpu threadtype */
//        public var physical_cpu: integer_t /* number of physical CPUs now available */
//        public var physical_cpu_max: integer_t /* max number of physical CPUs possible */
//        public var logical_cpu: integer_t /* number of logical cpu now available */
//        public var logical_cpu_max: integer_t /* max number of physical CPUs possible */
//        public var max_mem: UInt64 /* actual size of physical memory */
    }
}
