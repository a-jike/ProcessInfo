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
    @IBOutlet weak var memsizeLabel: NSTextField!
    @IBOutlet weak var ncpuField: NSTextField!
    @IBOutlet weak var brandField: NSTextField!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        print("\(CPU().hostBasicInfo())")
//        print("\(System.modelNumber())")
        
//        info()
//        let processInfo = ProcessInfo.processInfo
        
//        cpuName()
        print("model=\(model()), memsize=\(memsize()), ncpu=\(ncpu()), brandString=\(brandString())")
        memsizeLabel.stringValue = String(memsize()) + "GB"
        ncpuField.stringValue = String(ncpu())
        brandField.stringValue = brandString()
        
        /*
        print("arguments=\(processInfo.arguments)")
//        print("hostName=\(processInfo.hostName)")
        print("processName=\(processInfo.processName)")
        print("processIdentifier=\(processInfo.processIdentifier)")
        print("globallyUniqueString=\(processInfo.globallyUniqueString)")
//        print("operatingSystem=\(processInfo.operatingSystem)")
//        print("operatingSystemName=\(processInfo.operatingSystemName)")
        print("operatingSystemVersionString=\(processInfo.operatingSystemVersionString)")
        print("processorCount=\(processInfo.processorCount)")
        print("activeProcessorCount=\(processInfo.activeProcessorCount)")
        print("physicalMemory=\(processInfo.physicalMemory)")
        print("systemUptime=\(processInfo.systemUptime)")
        print("environment=\(processInfo.environment)")
 */
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func hardwareString() -> String {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var name2: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, &name2, 0)
        var hw_machine = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hw_machine, &size, &name2, 0)
        
        let hardware: String = String(cString: hw_machine)
        return hardware
    }
    
    func memsizeString() -> String {
        var name: [Int32] = [CTL_HW, HW_MEMSIZE]
        var name2: [Int32] = [CTL_HW, HW_MEMSIZE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, &name2, 0)
        var hw_memsize = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hw_memsize, &size, &name2, 0)
        
        let memsize: String = String(cString: hw_memsize)
        return memsize
    }
    
    fileprivate func hardware() -> String {
        var size: Int = 0
        sysctlbyname("hw.hardware", nil, &size, nil, 0)
        var hardware = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.hardware", &hardware, &size, nil, 0)
        return String.init(validatingUTF8: hardware) ?? ""
    }
    
    fileprivate func model() -> String {
        var size: Int = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String.init(validatingUTF8: model) ?? ""
    }
    
    /*
     $ sysctl hw | head
    hw.ncpu: 8
    hw.byteorder: 1234
    hw.memsize: 17179869184
    hw.activecpu: 8
    hw.physicalcpu: 4
    hw.physicalcpu_max: 4
    hw.logicalcpu: 8
    hw.logicalcpu_max: 8
    hw.cputype: 7
    hw.cpusubtype: 8
     */
    
    // メモリ搭載量
    private func memsize() -> Int {
        var length = size_t(MemoryLayout<size_t>.stride)
        var bytes = size_t(MemoryLayout<size_t>.stride)
        
        let result = sysctlbyname("hw.memsize", &bytes, &length, nil, 0)
        if result >= 0 {
            let  gigaBytes: size_t = 1073741824
            return Int(bytes / gigaBytes)
        }
        return 0
    }
    
    // CPUコア数
    private func ncpu() -> UInt {
        var length: size_t = 0
        var ncpu: UInt = 0
        
        length = MemoryLayout<UInt>.size
        sysctlbyname ("hw.ncpu", &ncpu, &length, nil, 0)
        
        return ncpu;
    }
    
    // CPU
    private func brandString() -> String {
        var size: Int = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var brand = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("machdep.cpu.brand_string", &brand, &size, nil, 0)
        return String.init(validatingUTF8: brand) ?? ""
    }
    
    // CPU名
    private func cpuName() {
        var length: size_t = 0
        var cpuType: cpu_type_t = 0
        var cpuSubtype: cpu_subtype_t = 0
        var is64bit: Bool = false
        var cpu64bit: Int = 0
        var err: Int32 = 0
        var cpuTypeString: String = ""
        var cpuSubtypeString: String = ""
        
        length = MemoryLayout<cpu_type_t>.size
        err = sysctlbyname("hw.cputype", &cpuType, &length, nil, 0)
        if err == 0 {
            switch cpuType {
            case CPU_TYPE_ARM:
                cpuTypeString = "ARM"
            case CPU_TYPE_X86:
                cpuTypeString = "Intel"
            case CPU_TYPE_POWERPC:
                cpuTypeString = "PowerPC"
            default:
                cpuTypeString = "Unknown"
            }
        }
        length = MemoryLayout<Int>.size
        err = sysctlbyname("hw.cpu64bit_capable", &cpu64bit, &length, nil, 0)
        if err != 0 {
            //x86
            sysctlbyname("hw.optional.x86_64", &cpu64bit, &length, nil, 0)
        }
        if err != 0 {
            //PPC
            sysctlbyname("hw.optional.64bitops", &cpu64bit, &length, nil, 0)
        }
        is64bit = cpu64bit == 1
        
        length = MemoryLayout<cpu_subtype_t>.size
        sysctlbyname("hw.cpusubtype", &cpuSubtype, &length, nil, 0)
        if cpuType == CPU_TYPE_X86 {
            // Intel
            // TODO: other Intel processors, like Core i7, i5, i3, Xeon?
//            switch cpuSubtype {
//
//            }
            cpuSubtypeString = is64bit ? "Intel Core 2" : "Intel Core" // If anyone knows how to tell a Core Duo from a Core Solo, please email tph@atomicbird.com
        } else if cpuType == 18 {
            // PowerPC
            switch cpuSubtype {
            case 9:
                cpuSubtypeString = "G3"
            case 10, 11:
                cpuSubtypeString = "G4"
            case 100:
                cpuSubtypeString = "G5"
            default:
                cpuSubtypeString = "Other"
            }
        } else {
            cpuSubtypeString = "Other";
        }
        print("cpuTypeString=\(cpuTypeString), cpuSubtypeString=\(cpuSubtypeString)")
    }
    
    private func info() {
        func blankof<T>(_ type:T.Type) -> T {
            let ptr = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
            let val = ptr.pointee
            ptr.deinitialize(count: 1)
            return val
        }
        func getHostBasicInfo() -> host_basic_info? {
            /// カーネル用のポートを取得する
            let hostPort = mach_host_self()
            /// ゼロ初期化済みのhost_basic_infoを用意
            var hostBasicInfo = blankof(host_basic_info.self)
            ///　HOST_BASIC_INFO_COUNTが定義されていないので自分で計算する
            var count = mach_msg_type_number_t(
                MemoryLayout<host_basic_info>.size / MemoryLayout<integer_t>.size
            )
            /// host_info()を呼び出して値を取得する
            var err = withUnsafePointer(to: &hostBasicInfo) { (pointer : UnsafePointer<host_basic_info_data_t>) -> host_basic_info_data_t in
                let raw = OpaquePointer(pointer)
                let host_info = host_info_t(raw)
                host_statistics(hostPort, HOST_BASIC_INFO, host_info, &count);
                
                return pointer.pointee
            }
            /// 問題なければhostBasicInfoを、あったらnilを返す
            return hostBasicInfo
        }
        
        guard let  basic_info = getHostBasicInfo() else {
            return
        }
        
        var max_cpus = basic_info.max_cpus  // 最大のCPU数
        var avail_cpus = basic_info.avail_cpus  // 現在利用できるCPUの数
        var memory_size = basic_info.memory_size    // メモリサイズ(byte)
        var cpu_type = basic_info.cpu_type  // CPU の種別1
        var cpu_subtype = basic_info.cpu_subtype    // CPU の種別2
        var cpu_threadtype = basic_info.cpu_threadtype  // CPU のスレッド種別
        var physical_cpu = basic_info.physical_cpu  // 現在利用できる物理的なCPUの数
        var physical_cpu_max = basic_info.physical_cpu_max  // 最大で利用できる物理的なCPUの数
        var logical_cpu = basic_info.logical_cpu    // 現在の論理的なCPUの数
        var logical_cpu_max = basic_info.logical_cpu_max    // 最大の論理的なCPUの数
        var max_mem = basic_info.max_mem    // 実際の物理メモリサイズ
        
        print("")
    }
}

final class System {
    class func info() {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = systemInfo.machine
        
    }
    class func modelNumber() -> String? {
        let name = "hw.machine"
        let cName = (name as NSString).utf8String //Cの文字列を作成
        
        var size: Int = 0 //size_tの代わりにInt
        sysctlbyname(cName, nil, &size, nil, 0)
        
        //取得したサイズでCCharの配列を初期化
        //*Xcode6-Beta4からCChar[]を[CChar]に変更
        var machine = [CChar](repeating: 0, count: size / MemoryLayout<CChar>.size)
        
        //値を取得
        sysctlbyname(cName, &machine, &size, nil, 0)
        
        //Stringに変換
        return NSString(bytes: machine, length: size, encoding: String.Encoding.utf8.rawValue) as String?
    }
}
