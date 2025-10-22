# Configuration Guide

## Environment Setup

### Xcode Project Setup

1. **Create New Xcode Project**
   - Open Xcode
   - File → New → Project
   - Choose "iOS" → "App"
   - Product Name: VEP
   - Interface: SwiftUI
   - Language: Swift
   - Use Core Data: ✓
   - Include Tests: ✓

2. **Add Existing Files**
   - Drag `ios/VEP/` folder into Xcode
   - Check "Copy items if needed"
   - Create groups
   - Add to target: VEP

3. **Project Settings**
   - Deployment Target: iOS 17.0+
   - Bundle Identifier: com.yourcompany.vep
   - Signing: Automatic (or Manual with certificates)

### Core Data Setup

The Core Data model is already defined in:
`ios/VEP/CoreData/VEP.xcdatamodeld/`

**Important:** The `.xcdatamodeld` folder must be added to Xcode as a Core Data model:
1. Open Xcode
2. File → Add Files
3. Select `VEP.xcdatamodeld`
4. Ensure "Copy items" is checked
5. Add to VEP target

### API Configuration

Configure the backend API URL in `APIClient.swift`:

```swift
// Development
private let baseURL = "https://dev.your-project.supabase.co"

// Production
private let baseURL = "https://your-project.supabase.co"
```

**Using Environment Variables:**

1. Add to Xcode scheme:
   - Product → Scheme → Edit Scheme
   - Run → Arguments → Environment Variables
   - Add: `API_BASE_URL` = `https://your-project.supabase.co`

2. Update APIClient:
```swift
init() {
    if let url = ProcessInfo.processInfo.environment["API_BASE_URL"] {
        self.baseURL = url
    } else {
        self.baseURL = "https://your-project.supabase.co"
    }
}
```

### Location Services Setup

Location permissions are configured in `Info.plist`.

**Required:**
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

**Testing Location:**
1. Simulator: Debug → Location → Custom Location
2. Device: Settings → Privacy → Location Services

### Network Security

HTTPS is enforced by default via `NSAppTransportSecurity` in Info.plist.

**For development with HTTP:**
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**Production:** Always use HTTPS only.

## Build Configuration

### Debug vs Release

**Debug Build:**
- Enables logging
- Uses development API
- Allows HTTP connections (if configured)
- Larger app size (includes debug symbols)

**Release Build:**
- Minimal logging
- Uses production API
- HTTPS only
- Optimized code
- Smaller app size

### Build Settings

Recommended settings in Xcode:

```
Swift Language Version: Swift 5
iOS Deployment Target: 17.0
Enable Bitcode: No
Build Active Architecture Only: Yes (Debug), No (Release)
```

## Dependencies

**Zero external dependencies required!**

All services use iOS native frameworks:
- Foundation
- SwiftUI
- CoreData
- CoreLocation
- Combine
- Network

This keeps the app lean and reduces security risks.

### Optional Dependencies

For production, consider:
- **Firebase** - Analytics, crash reporting
- **Keychain** - Secure token storage (replace UserDefaults)
- **Sentry** - Error tracking

## Security Configuration

### Token Storage

**Current:** UserDefaults (development)
**Production:** Keychain Services

Upgrade to Keychain:
```swift
import Security

class KeychainService {
    static func save(token: String) {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "auth_token",
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "auth_token",
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
```

### Core Data Encryption

Enable encryption for sensitive data:
```swift
let description = persistentContainer.persistentStoreDescriptions.first
description?.setOption(
    FileProtectionType.complete as NSObject,
    forKey: NSPersistentStoreFileProtectionKey
)
```

### Certificate Pinning

For production, implement certificate pinning:
```swift
class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Implement certificate validation
    }
}
```

## Testing Configuration

### Test Targets

Create two test targets:
1. **VEPTests** - Unit and integration tests
2. **VEPUITests** - UI tests

### Test Schemes

Configure test scheme:
- Product → Scheme → Edit Scheme
- Test → Options
- Code Coverage: ✓
- Coverage Targets: VEP

### CI/CD

Example GitHub Actions workflow:

```yaml
name: iOS CI
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_14.2.app
      - name: Build and Test
        run: |
          xcodebuild clean test \
            -project VEP.xcodeproj \
            -scheme VEP \
            -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
            -enableCodeCoverage YES
```

## Performance Configuration

### Optimization Settings

**Release Build:**
```
Optimization Level: Fastest, Smallest [-Os]
Swift Compilation Mode: Whole Module Optimization
Strip Debug Symbols: Yes
```

### Background Fetch

Enable background sync:
1. Add capability: Background Modes
2. Check: Background fetch
3. Implement:
```swift
func application(
    _ application: UIApplication,
    performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
) {
    Task {
        await SyncService.shared.syncPendingLogs()
        completionHandler(.newData)
    }
}
```

### Launch Performance

Optimize app launch:
1. Lazy load services
2. Cache authentication state
3. Defer non-critical initialization
4. Use background queues

## Deployment Configuration

### App Store Configuration

1. **Bundle ID:** com.yourcompany.vep
2. **Version:** 1.0.0
3. **Build:** 1
4. **Category:** Productivity
5. **Age Rating:** 4+

### Capabilities Required

- Location Services
- Background Modes (Location, Fetch)
- Network (automatic)

### Privacy Manifest

iOS 17+ requires privacy manifest:

```xml
<!-- PrivacyInfo.xcprivacy -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeLocation</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <true/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

### TestFlight

1. Archive build: Product → Archive
2. Upload to App Store Connect
3. Add to TestFlight
4. Invite testers
5. Collect feedback

## Troubleshooting

### Build Errors

**Error:** "Module 'VEP' not found"
**Fix:** Clean build folder (Cmd+Shift+K), rebuild

**Error:** "Core Data model not found"
**Fix:** Ensure `.xcdatamodeld` is in project with correct target membership

**Error:** "Location permission not working"
**Fix:** Check Info.plist has required keys, reset simulator/device location permissions

### Runtime Issues

**Issue:** App crashes on launch
**Check:** 
- Core Data model is accessible
- Info.plist is properly configured
- All required frameworks are linked

**Issue:** Network requests fail
**Check:**
- API URL is correct
- HTTPS/HTTP configuration matches server
- Auth token is set

**Issue:** Location not updating
**Check:**
- Permission granted
- Location services enabled
- `startTracking()` called

### Performance Issues

**Issue:** Slow sync
**Optimize:**
- Batch operations
- Reduce sync frequency
- Use background queue

**Issue:** High memory usage
**Fix:**
- Batch Core Data operations
- Release cached data
- Profile with Instruments

## Environment Variables

Use `.xcconfig` files for environment-specific configuration:

**Debug.xcconfig:**
```
API_BASE_URL = https://dev.your-project.supabase.co
LOG_LEVEL = debug
```

**Release.xcconfig:**
```
API_BASE_URL = https://your-project.supabase.co
LOG_LEVEL = error
```

Load in code:
```swift
#if DEBUG
let apiURL = "https://dev.your-project.supabase.co"
#else
let apiURL = "https://your-project.supabase.co"
#endif
```

## Next Steps

1. [ ] Create Xcode project
2. [ ] Add all source files
3. [ ] Configure Info.plist
4. [ ] Set up Core Data model
5. [ ] Configure API endpoints
6. [ ] Test in simulator
7. [ ] Test on device
8. [ ] Configure CI/CD
9. [ ] Submit to TestFlight
10. [ ] Collect feedback and iterate

Ready to build! 🚀
