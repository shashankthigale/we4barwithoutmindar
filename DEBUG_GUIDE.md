# White Screen Debug Guide

## How to Debug the White Screen Issue

### Step 1: Open Browser Console

1. Press **F12** (or right-click → Inspect)
2. Go to **Console** tab
3. Click "Start AR Experience"

### Step 2: Check Console Messages

You should see messages in this order:

```
✅ CORRECT SEQUENCE:
1. "Starting AR Experience..."
2. "OpenCV.js ready" or "OpenCV.js detected and ready"
3. "Loading target image..." → "Reading poster.png"
4. "Requesting camera access..."
5. "Camera stream obtained: [camera name]"
6. "Starting video playback..."
7. "Video metadata loaded: {width: 1280, height: 720}"
8. "Camera initialization complete!"
9. "Hiding loading screen, showing AR container"
10. "Starting AR tracking..."
11. "Video element check: {videoWidth: 1280, ...}"
```

### Step 3: Identify the Problem

#### Problem A: Stops at Step 2 (OpenCV)

**Symptom:** No "OpenCV.js ready" message
**Cause:** OpenCV.js failed to load from CDN
**Solution:**

- Check internet connection
- Try refreshing the page
- Check browser console for network errors

#### Problem B: Stops at Step 3 (Target Image)

**Symptom:** "Failed to load target image (poster.png)"
**Cause:** Missing or incorrect poster.png file
**Solution:**

- Ensure `poster.png` exists in the same folder as index.html
- Check file name is exactly "poster.png" (lowercase)
- File should be a valid PNG or JPG image

#### Problem C: Stops at Step 5 (Camera)

**Symptom:** "Camera access denied or unavailable"
**Cause:** Camera permission denied or camera in use
**Solution:**

- Click "Allow" when browser asks for camera permission
- Check if another app is using the camera
- Try different browser (Chrome/Safari)
- On mobile: Settings → Safari/Chrome → Camera → Allow

#### Problem D: White Screen After Step 11

**Symptom:** All logs show success but screen is white
**Cause:** Video element or canvas rendering issue
**Solution:**

- Check "Video element check" values in console
- `videoWidth` should be > 0
- `paused` should be false
- `readyState` should be 4
- `srcObject` should be true

### Step 4: Common Issues & Fixes

#### Issue: "videoWidth: 0, videoHeight: 0"

**Fix:** Video metadata didn't load properly

```javascript
// Refresh the page and try again
// Or check if video file is corrupt
```

#### Issue: "paused: true"

**Fix:** Video didn't start playing

```javascript
// Camera might not have permission
// Or browser blocked autoplay
```

#### Issue: "srcObject: false"

**Fix:** Camera stream wasn't assigned

```javascript
// Camera access was denied
// Grant camera permission and refresh
```

#### Issue: White screen but console shows success

**Fix:** CSS/Display issue

1. Inspect element (right-click on white area)
2. Check if `#arContainer` has `display: block`
3. Check if `#videoElement` is visible
4. Look for any overlaying elements

### Step 5: Manual Checks

#### Check Video Element:

```javascript
// In browser console, type:
const video = document.getElementById("videoElement");
console.log({
  width: video.videoWidth,
  height: video.videoHeight,
  paused: video.paused,
  stream: video.srcObject,
});
```

#### Check AR Container:

```javascript
// In browser console, type:
const ar = document.getElementById("arContainer");
console.log({
  display: ar.style.display,
  className: ar.className,
  visible: ar.offsetWidth > 0,
});
```

#### Force Video to Show:

```javascript
// In browser console, type:
document.getElementById("arContainer").style.display = "block";
document.getElementById("videoElement").play();
```

### Step 6: Reset Everything

If nothing works:

1. Close all browser tabs
2. Clear browser cache (Ctrl+Shift+Delete)
3. Refresh the page (Ctrl+F5)
4. Allow camera permission again
5. Try in incognito/private mode

### Quick Checklist

- [ ] Internet connection is working
- [ ] `poster.png` exists in project folder
- [ ] `overlay.mp4` exists in project folder
- [ ] Browser console (F12) is open
- [ ] Camera permission granted
- [ ] No other app using camera
- [ ] Using supported browser (Chrome/Safari)
- [ ] On HTTPS or localhost (required for camera)

### Expected Console Output (Success)

```
Starting AR Experience...
OpenCV.js ready
OpenCV.js detected and ready
Loading target image...
Requesting camera access...
Camera stream obtained: HD Camera (USB)
Starting video playback...
Video metadata loaded: {width: 1280, height: 720}
Camera initialization complete!
Setting up 3D renderer...
Loading video overlay...
Processing target image...
Extracted 245 features from target image
Ready!
Hiding loading screen, showing AR container
Starting AR tracking...
Video element check: {
  videoWidth: 1280,
  videoHeight: 720,
  paused: false,
  readyState: 4,
  srcObject: true
}
```

If you see this, the app is working correctly!

### Still Not Working?

Share the console output with these details:

1. Browser name and version
2. Operating system
3. Device type (desktop/mobile)
4. Full console log
5. Any error messages

---

**Pro Tip:** The debug logs will show you EXACTLY where the process stops. Look for the last successful message in the console!
