# Deployment Guide - WebAR Image Tracking

Complete guide for deploying your WebAR application to production.

## 📋 Pre-Deployment Checklist

### Assets Ready
- [ ] `poster.png` - High-quality target image with distinct features
- [ ] `overlay.mp4` - Optimized video (H.264, under 50MB)
- [ ] `index.html` - Main application file
- [ ] All assets tested locally

### Performance Optimized
- [ ] Target image under 2000x2000px
- [ ] Video optimized for web (720p-1080p, H.264)
- [ ] Tested on target devices (iOS 14+, Android 10+)
- [ ] 60fps achieved on mid-range devices

### Browser Compatibility
- [ ] Tested on Chrome Android
- [ ] Tested on Safari iOS
- [ ] Camera permissions working
- [ ] Recording feature functional

## 🚀 Deployment Options

### Option 1: Static Hosting (Recommended)

Best for: Simple deployment, fast loading, global CDN

#### Netlify (Free)

1. **Install Netlify CLI**
   ```bash
   npm install -g netlify-cli
   ```

2. **Deploy**
   ```bash
   netlify deploy --prod
   ```

3. **Drag & Drop (Alternative)**
   - Visit [app.netlify.com/drop](https://app.netlify.com/drop)
   - Drag project folder
   - Get instant URL

**Configuration** (`netlify.toml`):
```toml
[build]
  publish = "."

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"
    Permissions-Policy = "camera=*, microphone=*"
```

#### Vercel (Free)

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Deploy**
   ```bash
   vercel --prod
   ```

**Configuration** (`vercel.json`):
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Permissions-Policy",
          "value": "camera=*, microphone=*"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        }
      ]
    }
  ]
}
```

#### GitHub Pages (Free)

1. **Create Repository**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/username/repo.git
   git push -u origin main
   ```

2. **Enable GitHub Pages**
   - Go to repository Settings
   - Pages section
   - Source: main branch
   - Save

3. **Access**
   - URL: `https://username.github.io/repo/`
   - Note: HTTPS required for camera access

### Option 2: Cloud Storage + CDN

#### AWS S3 + CloudFront

1. **Create S3 Bucket**
   ```bash
   aws s3 mb s3://your-webar-app
   aws s3 website s3://your-webar-app --index-document index.html
   ```

2. **Upload Files**
   ```bash
   aws s3 sync . s3://your-webar-app --acl public-read
   ```

3. **Create CloudFront Distribution**
   - Origin: S3 bucket
   - Viewer Protocol: Redirect HTTP to HTTPS
   - Compress Objects: Yes

4. **Configure Headers**
   - Add custom header: `Permissions-Policy: camera=*, microphone=*`

#### Google Cloud Storage

1. **Create Bucket**
   ```bash
   gsutil mb gs://your-webar-app
   gsutil web set -m index.html gs://your-webar-app
   ```

2. **Upload**
   ```bash
   gsutil -m rsync -r . gs://your-webar-app
   gsutil iam ch allUsers:objectViewer gs://your-webar-app
   ```

3. **Enable CDN**
   - Create Load Balancer
   - Backend: Cloud Storage bucket
   - Frontend: HTTPS with SSL cert

### Option 3: Traditional Web Server

#### Apache

1. **Upload Files**
   ```bash
   scp -r ./* user@server:/var/www/webar/
   ```

2. **Configure** (`.htaccess`):
   ```apache
   # Enable HTTPS redirect
   RewriteEngine On
   RewriteCond %{HTTPS} off
   RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]
   
   # Set headers
   Header set Permissions-Policy "camera=*, microphone=*"
   Header set X-Content-Type-Options "nosniff"
   
   # Enable compression
   <IfModule mod_deflate.c>
     AddOutputFilterByType DEFLATE text/html text/css application/javascript
   </IfModule>
   ```

#### Nginx

1. **Upload Files**
   ```bash
   scp -r ./* user@server:/usr/share/nginx/html/webar/
   ```

2. **Configure** (`/etc/nginx/sites-available/webar`):
   ```nginx
   server {
     listen 443 ssl http2;
     server_name webar.example.com;
     
     ssl_certificate /path/to/cert.pem;
     ssl_certificate_key /path/to/key.pem;
     
     root /usr/share/nginx/html/webar;
     index index.html;
     
     # Headers
     add_header Permissions-Policy "camera=*, microphone=*";
     add_header X-Content-Type-Options "nosniff";
     add_header X-Frame-Options "DENY";
     
     # Compression
     gzip on;
     gzip_types text/html text/css application/javascript video/mp4;
     
     location / {
       try_files $uri $uri/ /index.html;
     }
     
     # Cache assets
     location ~* \.(mp4|png|jpg)$ {
       expires 30d;
       add_header Cache-Control "public, immutable";
     }
   }
   ```

3. **Enable Site**
   ```bash
   sudo ln -s /etc/nginx/sites-available/webar /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

## 🔒 Security Configuration

### HTTPS Required

Camera and microphone access require HTTPS. Options:

1. **Let's Encrypt (Free SSL)**
   ```bash
   # Certbot for Apache
   sudo certbot --apache -d webar.example.com
   
   # Certbot for Nginx
   sudo certbot --nginx -d webar.example.com
   ```

2. **Cloudflare (Free SSL + CDN)**
   - Add site to Cloudflare
   - Update DNS to Cloudflare nameservers
   - Enable SSL (Full or Strict)

### Required Headers

```
Permissions-Policy: camera=*, microphone=*
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000
```

### Content Security Policy (Optional)

```html
<!-- Add to index.html <head> -->
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://docs.opencv.org;
  style-src 'self' 'unsafe-inline';
  media-src 'self' blob:;
  connect-src 'self';
  img-src 'self' data: blob:;
">
```

## ⚡ Performance Optimization

### Asset Optimization

1. **Compress Images**
   ```bash
   # Using ImageMagick
   convert poster.png -quality 85 -strip poster.png
   
   # Using pngquant
   pngquant --quality=85-95 poster.png --output poster.png --force
   ```

2. **Optimize Video**
   ```bash
   # FFmpeg - Web-optimized MP4
   ffmpeg -i overlay.mp4 \
     -vcodec libx264 \
     -preset slow \
     -crf 23 \
     -vf scale=1280:720 \
     -acodec aac \
     -b:a 128k \
     -movflags +faststart \
     overlay_optimized.mp4
   ```

3. **Enable Compression** (gzip/brotli)
   
   **Nginx:**
   ```nginx
   gzip on;
   gzip_types text/html text/css application/javascript;
   brotli on;
   brotli_types text/html text/css application/javascript;
   ```
   
   **Apache:**
   ```apache
   <IfModule mod_deflate.c>
     AddOutputFilterByType DEFLATE text/html text/css application/javascript
   </IfModule>
   ```

### CDN Configuration

Use CDN for static assets:

```html
<!-- Update index.html if needed -->
<script src="https://cdn.jsdelivr.net/npm/three@0.128.0/build/three.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@techstark/opencv-js@4.5.2/opencv.js"></script>
```

### Caching Strategy

1. **Long-term Cache** (assets)
   ```
   poster.png: Cache-Control: max-age=31536000
   overlay.mp4: Cache-Control: max-age=31536000
   ```

2. **Short Cache** (HTML)
   ```
   index.html: Cache-Control: max-age=3600
   ```

## 📱 Mobile Optimization

### PWA Setup (Progressive Web App)

1. **Create `manifest.json`**
   ```json
   {
     "name": "WebAR Image Tracking",
     "short_name": "WebAR",
     "description": "AR Image Tracking Application",
     "start_url": "/",
     "display": "standalone",
     "background_color": "#667eea",
     "theme_color": "#667eea",
     "orientation": "portrait",
     "icons": [
       {
         "src": "icon-192.png",
         "sizes": "192x192",
         "type": "image/png"
       },
       {
         "src": "icon-512.png",
         "sizes": "512x512",
         "type": "image/png"
       }
     ]
   }
   ```

2. **Add to `index.html`**
   ```html
   <link rel="manifest" href="manifest.json">
   <meta name="theme-color" content="#667eea">
   <meta name="apple-mobile-web-app-capable" content="yes">
   <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
   ```

3. **Service Worker** (optional for offline support)
   ```javascript
   // sw.js
   self.addEventListener('install', (e) => {
     e.waitUntil(
       caches.open('webar-v1').then((cache) => {
         return cache.addAll([
           '/',
           '/index.html',
           '/poster.png',
           '/overlay.mp4'
         ]);
       })
     );
   });
   ```

## 🧪 Testing in Production

### Pre-Launch Tests

1. **SSL/HTTPS**
   ```bash
   curl -I https://your-domain.com
   # Check for: HTTP/2 200
   ```

2. **Headers**
   ```bash
   curl -I https://your-domain.com | grep -i permissions
   # Should show: Permissions-Policy: camera=*, microphone=*
   ```

3. **Mobile Testing**
   - Chrome DevTools mobile emulation
   - BrowserStack for real devices
   - Physical device testing

### Performance Testing

1. **Lighthouse Audit**
   ```bash
   npm install -g lighthouse
   lighthouse https://your-domain.com --view
   ```
   
   Target scores:
   - Performance: 90+
   - Accessibility: 95+
   - Best Practices: 100
   - SEO: 90+

2. **WebPageTest**
   - Visit [webpagetest.org](https://www.webpagetest.org/)
   - Test from mobile devices
   - Check: First Contentful Paint < 1.5s

## 📊 Monitoring & Analytics

### Basic Analytics

Add to `index.html` before `</head>`:

```html
<!-- Google Analytics 4 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### Custom Events

Track AR usage:

```javascript
// In index.html, add to ARImageTracker class
updateTrackingStatus(found) {
    // ... existing code ...
    
    if (found && this.trackingLost) {
        // Track event
        if (typeof gtag !== 'undefined') {
            gtag('event', 'target_found', {
                'event_category': 'AR_Tracking',
                'event_label': 'Target Detected'
            });
        }
    }
}
```

### Error Tracking (Sentry)

```html
<!-- Add before other scripts -->
<script src="https://browser.sentry-cdn.com/7.0.0/bundle.min.js"></script>
<script>
  Sentry.init({
    dsn: 'YOUR_SENTRY_DSN',
    environment: 'production'
  });
</script>
```

## 🔄 CI/CD Setup

### GitHub Actions

`.github/workflows/deploy.yml`:

```yaml
name: Deploy WebAR

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Netlify
        uses: netlify/actions/cli@master
        with:
          args: deploy --prod
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

### GitLab CI

`.gitlab-ci.yml`:

```yaml
deploy:
  stage: deploy
  script:
    - apt-get update && apt-get install -y curl
    - curl -sL https://deb.nodesource.com/setup_16.x | bash -
    - apt-get install -y nodejs
    - npm install -g netlify-cli
    - netlify deploy --prod --auth $NETLIFY_AUTH_TOKEN --site $NETLIFY_SITE_ID
  only:
    - main
```

## 📝 Post-Deployment

### Documentation

1. **User Guide** - Create guide for end users
2. **API Documentation** - If exposing any APIs
3. **Troubleshooting** - Common issues and solutions

### Support

1. **Contact Form** - Add support contact
2. **FAQ Page** - Answer common questions
3. **Video Tutorial** - Show how to use AR app

### Maintenance

1. **Monitor Performance** - Weekly performance checks
2. **Update Dependencies** - Monthly security updates
3. **Browser Testing** - Test on new browser versions
4. **Asset Updates** - Refresh content as needed

## 🌐 Domain & DNS

### Custom Domain Setup

1. **Purchase Domain** (Namecheap, Google Domains, etc.)

2. **Configure DNS**
   ```
   # A Record (if IP available)
   @    A    123.45.67.89
   
   # CNAME (for hosting providers)
   @    CNAME    your-app.netlify.app
   www  CNAME    your-app.netlify.app
   ```

3. **SSL Certificate** (automatic with Netlify/Vercel)

## ✅ Go-Live Checklist

- [ ] All assets uploaded and optimized
- [ ] HTTPS enabled with valid SSL certificate
- [ ] Permissions headers configured
- [ ] Tested on iOS Safari (iPhone 12+)
- [ ] Tested on Chrome Android (Samsung S21+)
- [ ] Camera permission flow works
- [ ] Video recording functional
- [ ] Performance meets 60fps target
- [ ] Error tracking configured
- [ ] Analytics implemented
- [ ] Backup of all files created
- [ ] Documentation complete
- [ ] Support contact available

## 🎉 Success!

Your WebAR application is now live! Monitor performance and user feedback for continuous improvement.

**Next Steps:**
- Share QR code linking to app
- Create demo video
- Write launch blog post
- Submit to showcases/galleries
- Gather user testimonials

---

**Need help? Check:**
- README.md - Usage guide
- SETUP.md - Asset preparation
- index.html comments - Code documentation

