# Code Signing Guide for TimeWarrior MenuBar

This guide explains how to code sign the TimeWarrior MenuBar application for macOS distribution.

## Why Code Signing?

Code signing is important for:
- **macOS Gatekeeper**: Prevents "unidentified developer" warnings
- **User Trust**: Shows your app comes from a verified developer
- **App Distribution**: Required for notarization and App Store distribution

## Prerequisites

You need an Apple Developer account ($99/year) to obtain:
1. **Developer ID Application Certificate** - For apps distributed outside the App Store
2. **Apple ID** - For notarization (optional but recommended)

## Local Code Signing

### Step 1: Get Your Signing Identity

List your available signing identities:

```bash
security find-identity -v -p codesigning
```

Look for an identity like:
```
1) ABC123... "Developer ID Application: Your Name (TEAM_ID)"
```

### Step 2: Build and Sign

Use the `--sign` flag with your build script:

```bash
# Build universal binary and sign
./build.sh --universal --sign "Developer ID Application: Your Name (TEAM_ID)"

# Or just sign without universal build
./build.sh --sign "Developer ID Application: Your Name"
```

### Step 3: Verify Signature

Check the signature:

```bash
codesign -dvv build/TimeWarriorMenuBar.app
codesign --verify --verbose build/TimeWarriorMenuBar.app
```

## GitHub Actions Code Signing

To enable automatic code signing in GitHub Actions, you need to add three secrets to your repository.

### Step 1: Export Your Certificate

1. Open **Keychain Access**
2. Find your "Developer ID Application" certificate
3. Right-click → Export
4. Save as `.p12` file with a password
5. Convert to base64:

```bash
base64 -i YourCertificate.p12 | pbcopy
```

### Step 2: Add GitHub Secrets

Go to your repository: **Settings → Secrets and variables → Actions**

Add these secrets:

1. **MACOS_CERTIFICATE**
   - Value: The base64 string from above (paste from clipboard)

2. **MACOS_CERTIFICATE_PWD**
   - Value: The password you set when exporting the .p12 file

3. **MACOS_SIGNING_IDENTITY**
   - Value: Your full identity name, e.g., `Developer ID Application: Your Name (TEAM123)`

### Step 3: Push to Main/Master or Create a Tag

The GitHub Actions workflow will automatically sign your app when:
- Pushing to `main` or `master` branch
- Creating a version tag (e.g., `v1.0.0`)

If the secrets are not configured, the build will succeed but skip signing (with a helpful message).

## Notarization (Optional)

For even better user experience, you can notarize your app with Apple.

### Prerequisites

- Apple ID with app-specific password
- Xcode Command Line Tools

### Steps

1. Sign your app (as described above)

2. Create a notarization package:

```bash
cd macos/build
ditto -c -k --keepParent TimeWarriorMenuBar.app TimeWarriorMenuBar.zip
```

3. Submit for notarization:

```bash
xcrun notarytool submit TimeWarriorMenuBar.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password" \
  --wait
```

4. Staple the notarization ticket:

```bash
xcrun stapler staple TimeWarriorMenuBar.app
```

5. Verify:

```bash
spctl -a -vvv -t install TimeWarriorMenuBar.app
```

### Adding Notarization to GitHub Actions

Add these additional secrets:

- **APPLE_ID**: Your Apple ID email
- **APPLE_TEAM_ID**: Your team ID
- **APPLE_ID_PASSWORD**: App-specific password (create at appleid.apple.com)

Then modify the GitHub Actions workflow to include notarization steps after code signing.

## Troubleshooting

### "No identity found" Error

**Problem**: `codesign` can't find your certificate.

**Solution**:
1. Make sure you have a Developer ID Application certificate in Keychain Access
2. Use the exact identity name: `security find-identity -v -p codesigning`

### "Code object is not signed at all"

**Problem**: App wasn't signed successfully.

**Solution**:
1. Check that you used the `--sign` flag
2. Verify the identity name is correct
3. Ensure the certificate is valid and not expired

### "Developer cannot be verified" on User's Mac

**Problem**: App is signed but users still see warnings.

**Solution**: Notarize your app (see Notarization section above)

### GitHub Actions Signing Fails

**Problem**: CI signing step fails.

**Solution**:
1. Verify all three secrets are set correctly
2. Check certificate hasn't expired
3. Ensure the identity string exactly matches your certificate

## Testing Signed Apps

### Test Gatekeeper

```bash
# Quarantine the app (simulates download)
xattr -d com.apple.quarantine build/TimeWarriorMenuBar.app

# Try to run it
spctl -a -vvv -t install build/TimeWarriorMenuBar.app
```

### Test on Clean Machine

The best test is on a Mac that has never seen your developer certificate:
1. Copy the app to another Mac
2. Try to open it
3. Should open without "unidentified developer" warning if properly signed

## Additional Resources

- [Apple Code Signing Guide](https://developer.apple.com/documentation/security/code_signing_services)
- [Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Creating Distribution-Signed Code](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Procedures/Procedures.html)

## Summary

| Method | Gatekeeper | Distribution | Cost |
|--------|-----------|--------------|------|
| Unsigned | ⚠️ Warning | Email/Direct | Free |
| Signed | ✅ No Warning | Email/Direct | $99/year |
| Signed + Notarized | ✅✅ Best UX | Email/Direct/Web | $99/year |

For most users, **signing** is sufficient. **Notarization** provides the best user experience but requires additional setup.
