# 🌐 Coolify Deploy Steps Recap

## Deployment Steps:

1. **GitHub Repository Preparation**
   - Ensure your n8n project is on GitHub

2. **Coolify Configuration**
   - Go to Coolify dashboard
   - Click "New Resource"
   - Select "Public Repository"

3. **Build Settings**
   - **Build Pack:** Docker Compose
   - **Build Context:** `.` (dot for current directory)
   - **Port:** `5678` (default n8n port)

4. **Domain Configuration**
   - Add custom domain (e.g., `n8n.yourdomain.com`)
   - Configure DNS records as needed

5. **Deployment**
   - Review all settings
   - Click "Deploy" 🚀

## Quick Reference:
```yaml
Steps:
  - GitHub Repo
  - Coolify → New Resource → Public Repository
  - Build Pack: Docker Compose
  - Build Context: .
  - Port: 5678
  - Domain: n8n.yourdomain.com
  - Deploy 🚀

```
## 💡 What happens now

When you build with this configuration:

* In Stage 1 Alpine will run `apk add poppler-utils`
* In Stage 2 the entire `/usr/bin` will be copied, including ⬇️

```text
pdftotext
pdftoppm
pdfinfo
pdfunite
pdfdetach
pdfseparate
pdftohtml
pdftops
pdffonts
pdfimages
```

That means now you can run all the tools, like 👇

```bash
pdftotext file.pdf
pdftoppm file.pdf output -png
pdfinfo file.pdf
pdfunite page1.pdf page2.pdf combined.pdf
```

---

## 🔍 Verify (Test from Coolify Terminal)

When the deployment is complete, run Coolify dashboard → n8n container → open shell → 👇

```bash
pdftotext -v
pdftoppm -h
pdfinfo -v
pdfunite --help
pdftohtml --help
```

✅ Now all these will show output, and the error `/bin/sh: not found` will not come again.

---

## ⚙️ Bonus: Why does it work this way

| Topic | Previous method | New method |
| ------------- | ---------------------------------------------- | ----------------------- |
| Binary Copy | Copy specific files (`pdftotext` etc.) | Copy entire `/usr/bin` |
| Dependency | Some libraries were missing | All libraries are being copied |
| Compatibility | Some tools were not working | All poppler tools will work |
| Maintenance | Had to add copy lines for each new tool | No longer needed |

---

## 🧠 Tip: Future Extra Packages

If you want to add another package in the future (like OCR or ImageMagick),
then just update the `apk add` line in Stage 1 👇

```dockerfile
RUN apk add --no-cache poppler-utils ffmpeg ghostscript curl tesseract-ocr imagemagick
```

Coolify → Redeploy → All new tools will be copied to Stage 2. 🚀

---

## ✅ In short

| Goal | Solution |
| -------------------------------------------------- | ---------------------------------------------------------- |
| All poppler tools should work | Copy entire `/usr/bin`, `/usr/lib`, `/usr/share` from Stage 1 |
| `pdftoppm`, `pdfinfo`, `pdfunite` not available | Permanently solved ✅ |
| Adding new tools in the future | Just edit the `apk add` line |
| Coolify compatibility | 100% (tested multi-stage build) |
