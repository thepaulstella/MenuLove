import Cocoa
import Foundation
import ScriptingBridge

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var loveTrack: NSMenuItem!
  @IBOutlet weak var unloveTrack: NSMenuItem!
  @IBOutlet weak var currentArtist: NSMenuItem!
  @IBOutlet weak var currentSong: NSMenuItem!
  @IBOutlet weak var currentAlbum: NSMenuItem!
  
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  let iTunesApp = SBApplication(bundleIdentifier: "com.apple.iTunes") as iTunesApplication!
  
  var timer = Timer()
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    statusMenu.delegate = self
    
    let icon = NSImage(named: NSImage.Name(rawValue: "MenuIcon"))
    icon?.isTemplate = true
    statusItem.image = icon
    statusItem.menu = statusMenu
    
    scheduleTimer()
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  @objc func updateMenu() {
    switch iTunesApp {
    case .some(let iTunes):
      
      if (iTunes.currentTrack?.name != "") {
        currentArtist.isHidden = false
        currentSong.isHidden = false
        currentAlbum.isHidden = false
        
        if (iTunes.currentTrack?.loved ?? false) {
          loveTrack.isHidden = true
          unloveTrack.isHidden = false
        } else {
          loveTrack.isHidden = false
          unloveTrack.isHidden = true
        }
        
        currentArtist.title = "Artist: " + (iTunes.currentTrack?.artist)!
        currentSong.title = "Song: " + (iTunes.currentTrack?.name)!
        currentAlbum.title = "Album: " + (iTunes.currentTrack?.album)!
        
      } else if (iTunes.currentTrack?.name == "") {
        timer.invalidate()
        
        currentArtist.isHidden = true
        currentAlbum.isHidden = true
        loveTrack.isHidden = true
        unloveTrack.isHidden = true
        
        currentSong.title = "Not Playing"
      }
    case .none:
      print("iTunes not found.")
    }
  }
  
  func scheduleTimer() {
    if (!timer.isValid) {
      timer = Timer.scheduledTimer(
        timeInterval: 0.5, target: self, selector: #selector(self.updateMenu), userInfo: nil, repeats: true
      )
    }
  }
  
  func loveCurrentTrack() {
    let script = "tell application \"iTunes\"\n set loved of current track to true\n end tell"
    let appleScript = NSAppleScript(source: script)
    
    appleScript?.executeAndReturnError(nil)
  }
  
  func unloveCurrentTrack() {
    let script = "tell application \"iTunes\"\n set loved of current track to false\n end tell"
    let appleScript = NSAppleScript(source: script)
    
    appleScript?.executeAndReturnError(nil)
  }
  
  func skipCurrentTrack() {
    let script = "tell application \"iTunes\"\n next track\n end tell"
    let appleScript = NSAppleScript(source: script)
    
    appleScript?.executeAndReturnError(nil)
  }
  
  @IBAction func loveClicked(_ sender: Any) {
    loveCurrentTrack()
  }
  
  @IBAction func unloveClicked(_ sender: Any) {
    unloveCurrentTrack()
  }
  
  @IBAction func quitClicked(_ sender: Any) {
    NSApplication.shared.terminate(self)
  }
}

extension AppDelegate: NSMenuDelegate {
  func menuWillOpen(_ menu: NSMenu) {
    print(#function)
    switch iTunesApp {
    case .some(let iTunes):
      if (iTunes.currentTrack?.name != "") {
        if (!timer.isValid) {
          updateMenu()
          scheduleTimer()
        }
      } else if (iTunes.currentTrack?.name == "") {
        timer.invalidate()
        updateMenu()
      }
    case .none:
      print("")
    }
  }
}
