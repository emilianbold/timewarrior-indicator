#!/usr/bin/swift
//
// TimeWarrior MenuBar Indicator for macOS
// Copyright (c) 2025 Emilian Bold
// SPDX-License-Identifier: ISC
//

import Cocoa
import Foundation

// MARK: - Utilities
extension Process {
    /// Execute a command and return stdout as Data, or nil on failure
    static func execute(_ launchPath: String, arguments: [String] = []) -> Data? {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()

            guard task.terminationStatus == 0 else {
                return nil
            }

            return pipe.fileHandleForReading.readDataToEndOfFile()
        } catch {
            print("Error executing \(launchPath): \(error)")
            return nil
        }
    }
}

extension Data {
    /// Convert Data to trimmed String
    var asString: String? {
        String(data: self, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Configuration
struct Config {
    static var timewPath: String = {
        // Try to find timew using 'which'
        if let data = Process.execute("/usr/bin/which", arguments: ["timew"]),
           let path = data.asString, !path.isEmpty {
            return path
        }

        // Fallback to common locations
        let fallbackPaths = [
            "/usr/local/bin/timew",
            "/opt/homebrew/bin/timew",
            "/usr/bin/timew"
        ]

        for path in fallbackPaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }

        // Last resort fallback
        return "/usr/local/bin/timew"
    }()

    static var updateInterval: TimeInterval = 10.0
    static var tagLimit = 20
    static var defaultTag = "Work"
}

// MARK: - TimeWarrior Data Models
struct TimeWarriorActivity: Codable {
    let id: Int?
    let start: String
    let tags: [String]?
    let end: String?
}

// MARK: - TimeWarrior Manager
class TimeWarriorManager {

    // Check if timewarrior is currently tracking
    func isActive() -> Bool {
        guard let data = Process.execute(Config.timewPath, arguments: ["get", "dom.active"]),
              let output = data.asString else {
            return false
        }
        return output == "1"
    }

    // Fetch current activity details
    func fetchActivity() -> String? {
        guard isActive() else {
            return nil
        }

        // Get JSON data
        guard let data = Process.execute(Config.timewPath, arguments: ["get", "dom.active.json"]),
              let activity = try? JSONDecoder().decode(TimeWarriorActivity.self, from: data) else {
            return nil
        }

        // Get tags (use longest one)
        let tags = activity.tags?.sorted(by: { $0.count > $1.count }) ?? [Config.defaultTag]
        var displayTag = tags.first ?? Config.defaultTag

        if displayTag.count > Config.tagLimit {
            displayTag = String(displayTag.prefix(Config.tagLimit)) + "..."
        }

        // Calculate duration
        let duration = calculateDuration(from: activity.start)

        // Get daily total
        let totalTime = getDailyTotal()

        return "\(displayTag) \(duration) ⌛ \(totalTime)"
    }

    // Calculate duration from start time
    private func calculateDuration(from startString: String) -> String {
        // Format: 20231105T123456Z
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")

        guard let startDate = formatter.date(from: startString) else {
            return "00:00"
        }

        let now = Date()
        let interval = now.timeIntervalSince(startDate)

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        return String(format: "%02d:%02d", hours, minutes)
    }

    // Get daily total time
    private func getDailyTotal() -> String {
        guard let data = Process.execute(Config.timewPath, arguments: ["summary"]),
              let output = data.asString else {
            return "0:00:00"
        }

        let lines = output.components(separatedBy: .newlines)
        if lines.count >= 3 {
            return lines[lines.count - 3].trimmingCharacters(in: .whitespaces)
        }

        return "0:00:00"
    }

    // Stop tracking
    func stopTracking() {
        _ = Process.execute(Config.timewPath, arguments: ["stop"])
    }

    // Continue/restart tracking
    func continueTracking() {
        _ = Process.execute(Config.timewPath, arguments: ["continue"])
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var timer: Timer?
    let timewarrior = TimeWarriorManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "⏱️"
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Create the menu
        setupMenu()

        // Start periodic refresh
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: Config.updateInterval, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func setupMenu() {
        menu = NSMenu()

        let restartItem = NSMenuItem(title: "▶️ Restart tracking", action: #selector(restartTracking), keyEquivalent: "r")
        let stopItem = NSMenuItem(title: "⏹️ Stop tracking", action: #selector(stopTracking), keyEquivalent: "s")
        menu.addItem(restartItem)
        menu.addItem(stopItem)
        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        menu.addItem(quitItem)
    }

    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            refresh()
        }
    }

    @objc func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let activity = self.timewarrior.fetchActivity()

            DispatchQueue.main.async {
                if let button = self.statusItem.button {
                    if let activity = activity {
                        button.title = activity
                    } else {
                        button.title = "⏱️ No activity"
                    }
                }
            }
        }
    }

    @objc func stopTracking() {
        timewarrior.stopTracking()
        refresh()
    }

    @objc func restartTracking() {
        timewarrior.continueTracking()
        refresh()
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }
}

// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
