# Troubleshooting Guide - WebAR Image Tracking

Common issues and solutions for the WebAR Image Tracking application.

## 📋 Table of Contents

1. [Setup Issues](#setup-issues)
2. [Camera & Permissions](#camera--permissions)
3. [Tracking Problems](#tracking-problems)
4. [Performance Issues](#performance-issues)
5. [Recording Problems](#recording-problems)
6. [Browser Compatibility](#browser-compatibility)
7. [Asset Loading](#asset-loading)
8. [Advanced Debugging](#advanced-debugging)

---

## 🔧 Setup Issues

### Issue: "OpenCV.js failed to load"

**Symptoms:**
- Infinite loading screen
- Console error: "Failed to load OpenCV.js"

**Solutions:**

1. **Check Internet Connection**
   ```javascript
   // OpenCV.js loads from CDN - requires internet
   // Check browser console for network errors
   ```

2. **Use Local OpenCV.js**
   - Download: https://docs.opencv.org/4.5.2/opencv.js
   - Place in project folder
   - Update index.html:
   ```html
   <!-- Change from: -->
   <script async src="https://docs.opencv.org/4.5.2/opencv.js"></script>
   
   <!-- To: -->
   <script async src="opencv.js"></script>
   ```

3. **Alternative CDN**
   ```html
   <script async src="https://cdn.jsdelivr.net/npm/@techstark/opencv-js@4.5.2/opencv.js"></script>
   ```

### Issue: "Failed to load target image (poster.png)"

**Symptoms:**
- Error message on screen
- Console: "Failed to load target image"

**Solutions:**

1. **Verify File Exists**
   ```bash
   # Check if file exists
   ls -la poster.png
   ```

2. **Check File Name** (case-sensitive on Linux/Mac)
   ```bash
   # Must be exactly "poster.png" (lowercase)
   mv Poster.png poster.png
   ```

3. **Verify CORS** (if on remote server)
   ```html
   <!-- In index.html, image loading -->
   img.crossOrigin = 'anonymous';  // Already included
   ```

4. **Test Image Format**
   ```bash
   # Convert to PNG if needed
   convert image.jpg poster.png
   ```

### Issue: "Failed to load overlay video (overlay.mp4)"

**Symptoms:**
- Video doesn't play when target found
- Console error about video loading

**Solutions:**

1. **Check File Format**
   ```bash
   # Verify it's MP4
   file overlay.mp4
   # Should show: MP4 video
   ```

2. **Convert to Compatible Format**
   ```bash
   ffmpeg -i input.mov -vcodec libx264 -acodec aac overlay.mp4
   ```

3. **Check Codec**
   ```bash
   # Use H.264 video codec
   ffmpeg -i overlay.mp4 -vcodec libx264 -acodec aac overlay_fixed.mp4
   ```

---

## 📷 Camera & Permissions

### Issue: "Camera access denied or unavailable"

**Symptoms:**
- Permission denied error
- Black screen instead of camera feed

**Solutions:**

1. **Grant Camera Permission**
   
   **Chrome (Desktop):**
   - Click camera icon in address bar
   - Select "Allow"
   - Refresh page
   
   **Chrome (Mobile):**
   - Settings → Site Settings → Camera
   - Find your site
   - Change to "Allow"
   
   **Safari (iOS):**
   - Settings → Safari → Camera
   - Select "Ask" or "Allow"

2. **Check HTTPS Requirement**
   ```
   Camera requires HTTPS or localhost
   ❌ http://192.168.1.100:8000  (won't work on iOS)
   ✅ https://192.168.1.100:8000 (works)
   ✅ http://localhost:8000       (works)
   ```

3. **Setup Local HTTPS** (for testing)
   ```bash
   # Using http-server with SSL
   npx http-server -S -C cert.pem -K key.pem
   
   # Generate self-signed cert
   openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem
   ```

### Issue: Camera shows but is rotated/flipped

**Symptoms:**
- Camera feed appears sideways or upside down
- Device rotation doesn't fix it

**Solutions:**

1. **Lock Orientation** (iOS)
   - Enable rotation lock
   - Hold device in portrait mode
   - Disable rotation lock

2. **Force Portrait Mode**
   ```css
   /* Add to index.html <style> section */
   @media (orientation: landscape) {
     body::before {
       content: "Please rotate device to portrait mode";
       position: fixed;
       top: 50%;
       left: 50%;
       transform: translate(-50%, -50%);
       background: rgba(0,0,0,0.9);
       color: white;
       padding: 2rem;
       border-radius: 10px;
       z-index: 9999;
     }
   }
   ```

---

## 🎯 Tracking Problems

### Issue: Target image not detected

**Symptoms:**
- "Searching for target" message persists
- No tracking even when pointing at image

**Solutions:**

1. **Improve Target Image Quality**
   - Use high-contrast images
   - Avoid plain colors or simple shapes
   - Include text, logos, or complex patterns
   - Ensure good lighting on printed target

2. **Adjust Detection Threshold**
   ```javascript
   // In index.html, line ~435
   // Lower threshold = more sensitive
   if (matches && matches.size() >= 10) {  // Current: 10
       // Try: >= 5 for more sensitive detection
   }
   ```

3. **Increase ORB Features**
   ```javascript
   // In index.html, line ~403 and ~558
   const orb = new cv.ORB(500);  // Current: 500
   // Try: 1000 for more features (slower but more accurate)
   ```

4. **Better Lighting**
   - Use even, diffused lighting
   - Avoid shadows on target
   - No glare or reflections
   - Indoor lighting often works best

5. **Print Quality**
   - Print on matte paper (not glossy)
   - Use color printer for better contrast
   - Larger print size = easier detection
   - No wrinkles or folds

### Issue: Tracking is jittery/shaky

**Symptoms:**
- Video overlay jumps around
- Unstable tracking even when steady

**Solutions:**

1. **Adjust One-Euro Filter** (more smoothing)
   ```javascript
   // In index.html, line ~242-256
   this.positionFilters = {
       x: new OneEuroFilter(1.0, 0.003, 1.0),  // Increase minCutoff
       y: new OneEuroFilter(1.0, 0.003, 1.0),  // Decrease beta
       z: new OneEuroFilter(1.0, 0.003, 1.0)
   };
   ```

2. **Increase Lost Frames Threshold**
   ```javascript
   // In index.html, line ~537
   if (this.lostFrames > 10) {  // Increase from 5 to 10
       // More persistent tracking
   }
   ```

3. **Add Frame Averaging**
   ```javascript
   // Store last N poses and average them
   // Add to ARImageTracker class
   this.poseHistory = [];
   this.maxPoseHistory = 5;
   
   // In updateAROverlay
   this.poseHistory.push(filteredPos);
   if (this.poseHistory.length > this.maxPoseHistory) {
       this.poseHistory.shift();
   }
   
   // Average positions
   const avgPos = this.poseHistory.reduce((acc, pos) => ({
       x: acc.x + pos.x / this.poseHistory.length,
       y: acc.y + pos.y / this.poseHistory.length,
       z: acc.z + pos.z / this.poseHistory.length
   }), {x: 0, y: 0, z: 0});
   ```

### Issue: Tracking lost frequently

**Symptoms:**
- Target found then immediately lost
- Frequent switching between found/searching

**Solutions:**

1. **Improve Target Visibility**
   - Ensure full target visible in frame
   - Maintain steady distance (arm's length)
   - Avoid extreme angles

2. **Adjust Match Distance**
   ```javascript
   // In index.html, line ~574
   if (match.distance < 50) {  // Current threshold
       // Try: < 70 for more lenient matching
       goodMatches.push_back(match);
   }
   ```

3. **Lower Minimum Matches**
   ```javascript
   // Line ~435
   if (matches && matches.size() >= 5) {  // Lower from 10
       // More tolerant tracking
   }
   ```

---

## ⚡ Performance Issues

### Issue: Low FPS / Laggy tracking

**Symptoms:**
- Choppy video overlay
- FPS below 30
- High CPU usage

**Solutions:**

1. **Reduce Frame Processing Size**
   ```javascript
   // In index.html, captureFrame() function
   tempCanvas.width = 320;   // Reduce from 640
   tempCanvas.height = 240;  // Reduce from 480
   ```

2. **Reduce ORB Features**
   ```javascript
   // Line ~403 and ~558
   const orb = new cv.ORB(250);  // Reduce from 500
   ```

3. **Skip Frames**
   ```javascript
   // Add to processFrame()
   this.frameCount = (this.frameCount || 0) + 1;
   
   // Only process every 2nd frame
   if (this.frameCount % 2 === 0) {
       // Process tracking
   }
   
   // Always render
   this.render();
   ```

4. **Close Other Apps**
   - Close browser tabs
   - Close other apps on phone
   - Free up memory

5. **Lower Video Quality**
   ```bash
   # Re-encode overlay video at lower quality
   ffmpeg -i overlay.mp4 -vf scale=640:360 -crf 28 overlay_low.mp4
   ```

### Issue: High memory usage / crashes

**Symptoms:**
- Browser crashes after a few minutes
- "Out of memory" errors
- Progressive slowdown

**Solutions:**

1. **Ensure Cleanup**
   ```javascript
   // Verify all cv.Mat objects are deleted
   // Check in detectAndMatch() function
   gray.delete();
   orb.delete();
   // etc.
   ```

2. **Add Memory Management**
   ```javascript
   // Add to processFrame()
   if (this.frameCount % 100 === 0) {
       // Periodic cleanup every 100 frames
       if (typeof cv !== 'undefined') {
           // Force OpenCV memory cleanup if available
       }
   }
   ```

3. **Reduce Video Resolution**
   ```javascript
   // In initializeCamera()
   video: {
       facingMode: 'environment',
       width: { ideal: 960 },   // Reduce from 1280
       height: { ideal: 540 }   // Reduce from 720
   }
   ```

---

## 🎥 Recording Problems

### Issue: Recording not working

**Symptoms:**
- Record button does nothing
- No download after stopping
- Console errors about MediaRecorder

**Solutions:**

1. **Check Browser Support**
   ```javascript
   // Test in console
   console.log(typeof MediaRecorder);  // Should be 'function'
   ```

2. **Try Different Codec**
   ```javascript
   // In startRecording(), line ~144
   // Change from:
   mimeType: 'video/webm;codecs=vp9'
   
   // To:
   mimeType: 'video/webm;codecs=vp8'
   // Or:
   mimeType: 'video/webm'
   ```

3. **Check Available Codecs**
   ```javascript
   // Test in console
   MediaRecorder.isTypeSupported('video/webm;codecs=vp9')
   MediaRecorder.isTypeSupported('video/webm;codecs=vp8')
   MediaRecorder.isTypeSupported('video/webm')
   ```

4. **Disable Audio** (if microphone unavailable)
   ```javascript
   // In startRecording()
   // Comment out audio stream
   // let audioStream = await navigator.mediaDevices.getUserMedia({ audio: true });
   let audioStream = null;
   ```

### Issue: Recording has black screen

**Symptoms:**
- Downloaded video is black
- Or shows only camera without AR overlay

**Solutions:**

1. **Check Composite Canvas**
   ```javascript
   // Verify composite canvas updates in render()
   this.compositeCtx.drawImage(this.video, ...);
   this.compositeCtx.drawImage(this.canvas, ...);
   ```

2. **Increase FPS**
   ```javascript
   // In startRecording()
   const canvasStream = compositeCanvas.captureStream(30);  // Lower from 60
   ```

### Issue: Recording file too large

**Symptoms:**
- Multi-GB recording files
- Slow downloads

**Solutions:**

1. **Limit Recording Duration**
   ```javascript
   // Add auto-stop after 30 seconds
   setTimeout(() => {
       if (isRecording) stopRecording();
   }, 30000);
   ```

2. **Use Better Codec**
   ```javascript
   mimeType: 'video/webm;codecs=vp9'  // Better compression
   ```

---

## 🌐 Browser Compatibility

### iOS Safari Issues

**Issue: Camera permission not working**

**Solution:**
- Must use HTTPS (not HTTP)
- Or use localhost
- Update iOS to 14.3+

**Issue: Video autoplay blocked**

**Solution:**
- Add playsinline attribute (already included)
- Mute video (already included)
- User gesture required (handled by Start button)

### Chrome Android Issues

**Issue: Performance worse than iOS**

**Solution:**
- Enable hardware acceleration:
  - chrome://flags
  - Enable "Override software rendering list"
  - Restart browser

**Issue: Orientation lock not working**

**Solution:**
```javascript
// Add screen orientation lock
if (screen.orientation && screen.orientation.lock) {
    screen.orientation.lock('portrait').catch(err => {
        console.log('Orientation lock failed:', err);
    });
}
```

### Firefox Issues

**Issue: MediaRecorder format different**

**Solution:**
```javascript
// Detect browser
const isFirefox = navigator.userAgent.includes('Firefox');

const mimeType = isFirefox 
    ? 'video/webm' 
    : 'video/webm;codecs=vp9';
```

---

## 📦 Asset Loading

### Issue: CORS errors

**Symptoms:**
- Console: "Cross-Origin Request Blocked"
- Assets fail to load

**Solutions:**

1. **Use Same-Origin Assets**
   - Keep all files in same directory
   - Don't load from external domains

2. **Enable CORS on Server**
   
   **Apache (.htaccess):**
   ```apache
   Header set Access-Control-Allow-Origin "*"
   ```
   
   **Nginx:**
   ```nginx
   add_header Access-Control-Allow-Origin *;
   ```

3. **Use Local Server** (not file://)
   ```bash
   # Don't open index.html directly
   # Use: python -m http.server 8000
   ```

### Issue: Slow asset loading

**Solutions:**

1. **Optimize Images**
   ```bash
   # Compress poster.png
   pngquant poster.png --quality=85-95 --output poster.png --force
   ```

2. **Optimize Video**
   ```bash
   # Reduce bitrate
   ffmpeg -i overlay.mp4 -b:v 2M -b:a 128k overlay_opt.mp4
   ```

3. **Use CDN** (for libraries)
   - Three.js and OpenCV.js already on CDN
   - Consider CDN for large assets in production

---

## 🔍 Advanced Debugging

### Enable Debug Logging

```javascript
// Add to ARImageTracker class
this.debug = true;

// In processFrame()
if (this.debug) {
    console.log('Matches:', matches.size());
    console.log('Keypoints:', keypoints.size());
    console.log('FPS:', Math.round(1000 / (timestamp - this.lastTimestamp)));
}
```

### Visualize Features

```javascript
// Draw detected features on canvas
if (this.debug && keypoints) {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    
    for (let i = 0; i < keypoints.size(); i++) {
        const kp = keypoints.get(i);
        this.ctx.beginPath();
        this.ctx.arc(kp.pt.x * 2, kp.pt.y * 2, 3, 0, 2 * Math.PI);
        this.ctx.fillStyle = 'red';
        this.ctx.fill();
    }
}
```

### Performance Monitoring

```javascript
// Add FPS counter
let frameCount = 0;
let lastTime = performance.now();

function showFPS() {
    frameCount++;
    const now = performance.now();
    
    if (now >= lastTime + 1000) {
        console.log('FPS:', frameCount);
        frameCount = 0;
        lastTime = now;
    }
}

// Call in processFrame()
showFPS();
```

### Browser Console Commands

```javascript
// Check WebGL support
console.log(!!document.createElement('canvas').getContext('webgl'));

// Check camera devices
navigator.mediaDevices.enumerateDevices().then(devices => {
    console.log(devices.filter(d => d.kind === 'videoinput'));
});

// Check MediaRecorder support
console.log('MediaRecorder:', typeof MediaRecorder !== 'undefined');

// Memory usage (Chrome)
console.log(performance.memory);
```

---

## 📞 Getting Help

If you're still experiencing issues:

1. **Check Browser Console**
   - Press F12 (desktop) or use remote debugging (mobile)
   - Look for error messages
   - Check network tab for failed requests

2. **Test Systematically**
   - Does camera work? → Permission issue
   - Does OpenCV load? → Network/CDN issue  
   - Does target load? → Asset issue
   - Are features detected? → Image quality issue
   - Does pose estimate? → Algorithm issue

3. **Minimal Test**
   - Create simple test with just camera
   - Add features one by one
   - Identify where it breaks

4. **Share Debug Info**
   ```javascript
   // Copy this output when reporting issues
   console.log({
       browser: navigator.userAgent,
       webgl: !!document.createElement('canvas').getContext('webgl'),
       mediaRecorder: typeof MediaRecorder !== 'undefined',
       opencv: typeof cv !== 'undefined',
       three: typeof THREE !== 'undefined'
   });
   ```

---

## ✅ Quick Checklist

When something doesn't work:

- [ ] HTTPS or localhost (required for camera)
- [ ] Camera permission granted
- [ ] OpenCV.js loaded successfully
- [ ] poster.png exists and loads
- [ ] overlay.mp4 exists and loads
- [ ] Target image is high quality
- [ ] Good lighting on target
- [ ] Browser console checked for errors
- [ ] Tested on supported browser version
- [ ] Internet connection active (for CDN)

---

**Still stuck? Check the README.md for more information or review the inline comments in index.html**

