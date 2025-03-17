import Foundation
import SwiftUI
import Combine

class NetworkSpeedService: ObservableObject {
    enum TestPhase: Int, CaseIterable {
        case idle
        case ping
        case download
        case upload
        case completed
        case failed
    }
    
    struct SpeedTestResult: Identifiable {
        let id = UUID()
        let date: Date
        let downloadSpeed: Double
        let uploadSpeed: Double
        let ping: Int
    }
    
    // Test state
    @Published var isRunning = false
    @Published var testPhase: TestPhase = .idle
    
    // Test progress
    @Published var downloadProgress: Double = 0.0
    @Published var uploadProgress: Double = 0.0
    
    // Test results
    @Published var downloadSpeed: Double = 0.0
    @Published var uploadSpeed: Double = 0.0
    @Published var ping: Int = 0
    
    // History
    @Published var testHistory: [SpeedTestResult] = []
    
    // Private
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    // MARK: - Public Methods
    
    func startTest() {
        guard !isRunning else { return }
        
        // Reset state
        isRunning = true
        testPhase = .idle
        downloadProgress = 0.0
        uploadProgress = 0.0
        
        // For this demo we'll simulate a speed test
        simulateTest()
    }
    
    func cancelTest() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private Methods
    
    private func simulateTest() {
        // Simulate ping test
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self, self.isRunning else { return }
            
            self.testPhase = .ping
            self.simulatePingMeasurement()
        }
    }
    
    private func simulatePingMeasurement() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self, self.isRunning else { return }
            
            // Generate a realistic ping value (10-80ms)
            self.ping = Int.random(in: 10...80)
            
            // Move to download test
            self.testPhase = .download
            self.simulateDownloadTest()
        }
    }
    
    private func simulateDownloadTest() {
        downloadProgress = 0.0
        
        // We'll simulate a test that takes about 8 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] timer in
            guard let self = self, self.isRunning else {
                timer.invalidate()
                return
            }
            
            // Increment progress
            self.downloadProgress += 0.05 + Double.random(in: 0...0.02)
            
            // Add some variability to the animation
            if self.downloadProgress >= 1.0 {
                self.downloadProgress = 1.0
                timer.invalidate()
                
                // Generate a realistic download speed (20-500 Mbps)
                self.downloadSpeed = Double.random(in: 50...300)
                
                // Move to upload test
                self.testPhase = .upload
                self.simulateUploadTest()
            }
        }
    }
    
    private func simulateUploadTest() {
        uploadProgress = 0.0
        
        // We'll simulate a test that takes about 8 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] timer in
            guard let self = self, self.isRunning else {
                timer.invalidate()
                return
            }
            
            // Increment progress
            self.uploadProgress += 0.05 + Double.random(in: 0...0.02)
            
            // Add some variability to the animation
            if self.uploadProgress >= 1.0 {
                self.uploadProgress = 1.0
                timer.invalidate()
                
                // Generate a realistic upload speed (5-50 Mbps)
                self.uploadSpeed = Double.random(in: 10...60)
                
                // Complete the test
                self.completeTest()
            }
        }
    }
    
    private func completeTest() {
        testPhase = .completed
        isRunning = false
        
        // Save results to history
        let result = SpeedTestResult(
            date: Date(),
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed,
            ping: ping
        )
        testHistory.append(result)
        
        // Keep only the last 20 tests
        if testHistory.count > 20 {
            testHistory.removeFirst(testHistory.count - 20)
        }
    }
    
    // MARK: - In a real app you would implement actual network calls
    
    private func realMeasurePing(serverURL: URL, completion: @escaping (Int) -> Void) {
        // In a real implementation, you would:
        // 1. Send multiple small packets to the server
        // 2. Measure the round-trip time
        // 3. Calculate the average ping
    }
    
    private func realDownloadTest(serverURL: URL, progress: @escaping (Double) -> Void, completion: @escaping (Double) -> Void) {
        // In a real implementation, you would:
        // 1. Download a large file from the server
        // 2. Measure the time it takes
        // 3. Calculate the speed in Mbps
        // 4. Report progress along the way
    }
    
    private func realUploadTest(serverURL: URL, progress: @escaping (Double) -> Void, completion: @escaping (Double) -> Void) {
        // In a real implementation, you would:
        // 1. Upload a large file to the server
        // 2. Measure the time it takes
        // 3. Calculate the speed in Mbps
        // 4. Report progress along the way
    }
} 