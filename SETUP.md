# Setup Guide - WebAR Image Tracking

## Required Assets

Before running the application, you need to provide two files:

### 1. Target Image: `poster.png`

This is the image that will be tracked by the AR system.

**Requirements:**
- **Format**: PNG or JPG (rename to `poster.png`)
- **Resolution**: Any size (will be auto-scaled)
- **Content**: High-contrast image with clear features
- **Examples**:
  - Company logo
  - Product packaging
  - Poster or artwork
  - Business card
  - Book cover

**Best Practices for Good Tracking:**
- ✅ Use images with distinct patterns and textures
- ✅ High contrast between elements
- ✅ Avoid plain colors or gradients
- ✅ Include text, logos, or geometric shapes
- ✅ Good lighting in testing environment
- ❌ Avoid reflective or glossy surfaces
- ❌ Don't use very simple images (plain circles, etc.)
- ❌ Avoid repeating patterns (can cause false matches)

**Example Sources:**
```bash
# Download a sample target image (if you don't have one)
# Option 1: Use a logo
curl -o poster.png https://example.com/your-logo.png

# Option 2: Use your own image
# Just rename it to poster.png and place in project root
```

### 2. Overlay Video: `overlay.mp4`

This is the video that will appear on the tracked target.

**Requirements:**
- **Format**: MP4 (H.264 codec recommended)
- **Resolution**: Any (will scale to target)
- **Duration**: Any length (will loop automatically)
- **Aspect Ratio**: Any (preserved during display)

**Recommendations:**
- 720p or 1080p for good quality
- Keep file size under 50MB for fast loading
- Use H.264 codec for best compatibility
- Include audio if desired (will be recorded)

**Example Videos to Try:**
```bash
# Create a sample video using FFmpeg (if installed)
ffmpeg -f lavfi -i testsrc=duration=10:size=1280x720:rate=30 \
       -f lavfi -i sine=frequency=1000:duration=10 \
       -pix_fmt yuv420p overlay.mp4

# Or download a sample video
curl -o overlay.mp4 https://example.com/sample-video.mp4
```

## Quick Setup Checklist

- [ ] Create or obtain target image
- [ ] Rename to `poster.png`
- [ ] Place in project root directory
- [ ] Create or obtain overlay video
- [ ] Rename to `overlay.mp4`
- [ ] Place in project root directory
- [ ] Start local web server
- [ ] Open in browser
- [ ] Grant camera permissions
- [ ] Point camera at printed target image

## File Structure

After setup, your directory should look like:

```
webar-image-tracking/
├── index.html          ✅ Provided
├── README.md           ✅ Provided
├── SETUP.md            ✅ This file
├── .gitignore          ✅ Provided
├── poster.png          ⚠️  YOU MUST PROVIDE
└── overlay.mp4         ⚠️  YOU MUST PROVIDE
```

## Testing Recommendations

### 1. Print the Target Image

For best results:
- Print `poster.png` on regular paper (A4 or Letter size)
- Ensure colors are vibrant and clear
- Avoid wrinkles or folds
- Use matte finish (not glossy)

### 2. Lighting Conditions

- Use even, diffused lighting (no harsh shadows)
- Avoid direct sunlight (causes glare)
- Indoor lighting works well
- Ensure target is well-lit

### 3. Camera Distance

- Start at arm's length (~50cm / 20 inches)
- Move closer or farther based on target size
- Keep target fully visible in frame
- Avoid extreme angles initially

### 4. Testing Process

1. **Desktop Testing** (development)
   ```bash
   # Start server
   python -m http.server 8000
   
   # Visit
   http://localhost:8000
   ```

2. **Mobile Testing** (production)
   ```bash
   # Find your local IP
   # Windows: ipconfig
   # Mac/Linux: ifconfig
   
   # Visit from phone
   http://192.168.1.XXX:8000
   ```

## Creating Sample Assets

### Option 1: Use Provided Samples

If you need quick test assets:

1. **Target Image**: Use any high-quality logo or poster
   - Search "company logo PNG" on Google
   - Download and rename to `poster.png`

2. **Overlay Video**: Use any short video clip
   - Screen recording of animation
   - Product demo video
   - Marketing clip

### Option 2: Create Custom Assets

**Create Target Image (Using GIMP/Photoshop):**
1. Create new image (1000x1000px)
2. Add text, logos, shapes
3. Use high contrast colors
4. Export as PNG
5. Save as `poster.png`

**Create Overlay Video (Using Any Video Editor):**
1. Create 720p or 1080p video
2. Add text, graphics, or footage
3. Keep duration 5-30 seconds
4. Export as MP4 (H.264)
5. Save as `overlay.mp4`

### Option 3: Quick Test Pattern

Create a simple test pattern programmatically:

**Generate Target Image (Python + PIL):**
```python
from PIL import Image, ImageDraw, ImageFont
import random

# Create image
img = Image.new('RGB', (800, 800), color='white')
draw = ImageDraw.Draw(img)

# Add geometric shapes
for i in range(10):
    x, y = random.randint(0, 700), random.randint(0, 700)
    draw.rectangle([x, y, x+100, y+100], 
                   fill=(random.randint(0, 255), 
                         random.randint(0, 255), 
                         random.randint(0, 255)))

# Add text
draw.text((400, 400), "AR TARGET", fill='black')

# Save
img.save('poster.png')
```

## Troubleshooting Setup

### Issue: Files Not Loading

**Check:**
```bash
# Verify files exist
ls -la *.png *.mp4

# Should show:
# poster.png
# overlay.mp4
```

### Issue: Wrong File Names

**Solution:**
```bash
# Rename files if needed
mv my-image.jpg poster.png
mv my-video.mp4 overlay.mp4
```

### Issue: Video Format Not Supported

**Convert using FFmpeg:**
```bash
# Convert any video to MP4 H.264
ffmpeg -i input.mov -c:v libx264 -c:a aac -movflags +faststart overlay.mp4
```

### Issue: Image Too Large

**Resize using ImageMagick:**
```bash
# Resize to 1000px width (maintains aspect ratio)
convert poster.png -resize 1000x poster.png
```

## Performance Tips

### Optimize Target Image

- Keep resolution under 2000x2000px
- Use JPEG for photos (PNG for graphics)
- Compress without losing quality
- Ensure clear features remain visible

### Optimize Overlay Video

- Use 720p for mobile (1280x720)
- Bitrate: 2-5 Mbps is sufficient
- Frame rate: 24-30 fps
- Duration: Under 30 seconds for quick loading

**FFmpeg Optimization:**
```bash
# Optimize video for web
ffmpeg -i input.mp4 \
  -vf scale=1280:720 \
  -c:v libx264 \
  -preset slow \
  -crf 23 \
  -c:a aac \
  -b:a 128k \
  -movflags +faststart \
  overlay.mp4
```

## Next Steps

Once assets are ready:

1. ✅ Verify both files are in project root
2. ✅ Start web server
3. ✅ Open in browser (Chrome/Safari)
4. ✅ Grant camera permission
5. ✅ Print target image
6. ✅ Point camera at printed target
7. ✅ Watch video overlay appear!
8. ✅ Tap record button to capture AR experience

## Support

If you encounter issues:

1. Check browser console (F12) for errors
2. Verify file names are exactly `poster.png` and `overlay.mp4`
3. Ensure web server is running
4. Test with different lighting conditions
5. Try different target images
6. Review README.md troubleshooting section

---

**Ready to start? Make sure you have:**
- [x] `index.html` (provided)
- [ ] `poster.png` (you provide)
- [ ] `overlay.mp4` (you provide)
- [ ] Web server running
- [ ] Camera-enabled device

**Happy AR Tracking! 🎯📱**

