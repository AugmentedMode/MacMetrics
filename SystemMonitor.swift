import Foundation
import Darwin
import IOKit.ps

class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    @Published var memoryTotal: UInt64 = 0
    @Published var memoryUsed: UInt64 = 0
    @Published var cpuTemperature: Double = 0.0
    @Published var batteryCharge: Double = 0.0
    @Published var batteryCapacity: UInt64 = 0
    @Published var batteryMaxCapacity: UInt64 = 0
    @Published var batteryHealth: Double = 0.0
    @Published var batteryIsCharging: Bool = false
    @Published var networkUsageToday: UInt64 = 0
    @Published var networkUsageWeek: UInt64 = 0
    @Published var networkUsageMonth: UInt64 = 0
    @Published var cpuHistory: [Double] = Array(repeating: 0, count: 60)
    @Published var memoryHistory: [Double] = Array(repeating: 0, count: 60)
    @Published var temperatureHistory: [Double] = Array(repeating: 0, count: 60)
    @Published var batteryHistory: [Double] = Array(repeating: 0, count: 60)
    @Published var graphicsHistory: [Double] = Array(repeating: 0, count: 60)
    
    private var timer: Timer?
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
        timer?.fire()
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMetrics() {
        updateCPUUsage()
        updateMemoryUsage()
        updateCPUTemperature()
        updateBatteryInfo()
        updateNetworkUsage()
        updateGraphicsUsage()
        updateHistoricalData()
    }
    
    private func updateCPUUsage() {
        // Get system-wide CPU usage
        var cpuInfo = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let userTicks = Double(cpuInfo.cpu_ticks.0)
            let systemTicks = Double(cpuInfo.cpu_ticks.1)
            let idleTicks = Double(cpuInfo.cpu_ticks.2)
            let niceTicks = Double(cpuInfo.cpu_ticks.3)
            
            let totalTicks = userTicks + systemTicks + idleTicks + niceTicks
            let activeTicks = userTicks + systemTicks + niceTicks
            
            DispatchQueue.main.async {
                self.cpuUsage = (activeTicks / totalTicks) * 100.0
            }
        }
    }
    
    private func updateMemoryUsage() {
        var stats = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)
            let _ = UInt64(stats.free_count) * pageSize
            let active = UInt64(stats.active_count) * pageSize
            let inactive = UInt64(stats.inactive_count) * pageSize
            let wired = UInt64(stats.wire_count) * pageSize
            let compressed = UInt64(stats.compressor_page_count) * pageSize
            
            let used = active + inactive + wired + compressed
            
            var totalMemory: UInt64 = 0
            let hostPort = mach_host_self()
            var memoryInfo = host_basic_info_data_t()
            var count = mach_msg_type_number_t(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
            
            let kerr = withUnsafeMutablePointer(to: &memoryInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    host_info(hostPort, HOST_BASIC_INFO, $0, &count)
                }
            }
            
            if kerr == KERN_SUCCESS {
                totalMemory = UInt64(memoryInfo.max_mem)
            }
            
            DispatchQueue.main.async {
                self.memoryTotal = totalMemory
                self.memoryUsed = used
                self.memoryUsage = Double(used) / Double(totalMemory) * 100.0
            }
        }
    }
    
    private func updateCPUTemperature() {
        // Simulated temperature for demo purposes
        // In a real app, you'd use SMC keys to get actual temperature
        DispatchQueue.main.async {
            self.cpuTemperature = Double.random(in: 45...65)
        }
    }
    
    private func updateBatteryInfo() {
        let powerInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let powerSources = IOPSCopyPowerSourcesList(powerInfo).takeRetainedValue() as [CFTypeRef]
        
        if let powerSource = powerSources.first,
           let powerSourceDesc = IOPSGetPowerSourceDescription(powerInfo, powerSource).takeUnretainedValue() as? [String: Any] {
            
            let currentCapacity = powerSourceDesc[kIOPSCurrentCapacityKey] as? Int ?? 0
            let maxCapacity = powerSourceDesc[kIOPSMaxCapacityKey] as? Int ?? 0
            let designCapacity = 8694 // Simulated design capacity for demo
            let isCharging = (powerSourceDesc[kIOPSIsChargingKey] as? Bool) ?? false
            
            DispatchQueue.main.async {
                self.batteryCharge = Double(currentCapacity)
                self.batteryCapacity = UInt64(currentCapacity)
                self.batteryMaxCapacity = UInt64(maxCapacity)
                self.batteryHealth = Double(maxCapacity) / Double(designCapacity) * 100.0
                self.batteryIsCharging = isCharging
            }
        }
    }
    
    private func updateNetworkUsage() {
        // Simulated network usage for demo purposes
        DispatchQueue.main.async {
            self.networkUsageToday = UInt64(Float.random(in: 300...500) * 1024 * 1024)
            self.networkUsageWeek = UInt64(Float.random(in: 4...6) * 1024 * 1024 * 1024)
            self.networkUsageMonth = UInt64(Float.random(in: 25...35) * 1024 * 1024 * 1024)
        }
    }
    
    private func updateGraphicsUsage() {
        // Simulated graphics usage for demo purposes
        // Would need to use IOKit to get actual GPU metrics
    }
    
    private func updateHistoricalData() {
        DispatchQueue.main.async {
            // Update history arrays by removing oldest value and adding newest
            self.cpuHistory.removeFirst()
            self.cpuHistory.append(self.cpuUsage)
            
            self.memoryHistory.removeFirst()
            self.memoryHistory.append(self.memoryUsage)
            
            self.temperatureHistory.removeFirst()
            self.temperatureHistory.append(self.cpuTemperature)
            
            self.batteryHistory.removeFirst()
            self.batteryHistory.append(self.batteryCharge)
            
            let randomGraphicsUsage = Double.random(in: 0...40)
            self.graphicsHistory.removeFirst()
            self.graphicsHistory.append(randomGraphicsUsage)
        }
    }
} 