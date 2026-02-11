# 🌐 Guide: Build a Professional Portfolio Website for Free

While GitHub shows *how* you code, a personal website shows *who* you are. It's your digital headquarters—fully customizable, professional, and accessible to non-technical recruiters.

---

## 🚀 The DevOps Approach: Static Sites & GitOps

Forget Wix or Squarespace. As a DevOps engineer, you should build your site using **Infrastructure as Code** principles.

**The Stack:**
*   **Content**: Markdown (just like your docs)
*   **Engine**: Static Site Generator (Hugo, Jekyll, or Gatsby)
*   **Hosting**: GitHub Pages, Netlify, or Vercel (Free tiers)
*   **CI/CD**: Git-triggered deployments

---

## 1. Choose Your Engine

### ⚡ Hugo (Recommended)
*   **Pros**: Blazing fast, single binary installation, huge theme library.
*   **Best for**: DevOps engineers who want speed and simplicity.

### 💎 Jekyll
*   **Pros**: Native support on GitHub Pages.
*   **Best for**: Those who want the absolute simplest integration with GitHub.

### ⚛️ Gatsby/Next.js
*   **Pros**: React-based, highly dynamic.
*   **Best for**: Frontend-focused engineers or complex interactive sites.

---

## 2. Step-by-Step: The 15-Minute Hugo Launch

We will use **Hugo** + **GitHub Pages** for this example.

### Step 1: Install Hugo
```bash
# MacOS
brew install hugo

# Windows (Chocolatey)
choco install hugo -confirm

# Linux (Debian)
sudo apt-get install hugo
```

### Step 2: Create a New Site
```bash
hugo new site my-portfolio
cd my-portfolio
git init
```

### Step 3: Pick a Theme
Don't build from scratch. Use a theme like **PaperMod** or **Stack**.
```bash
git submodule add https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
echo "theme: 'PaperMod'" >> hugo.yaml
```

### Step 4: Create Content
Create your first post or "About" page.
```bash
hugo new posts/hello-world.md
```
*Edit the file in `content/posts/hello-world.md` and set `draft: false`.*

### Step 5: Test Locally
```bash
hugo server -D
# Open http://localhost:1313
```

---

## 3. Deploying with GitHub Actions (CI/CD)

Automate your deployment. Every `git push` should publish your site.

1.  Create a **public** GitHub repository (e.g., `my-portfolio`).
2.  Push your code to it.
3.  In your repo, go to **Settings > Pages**.
4.  Source: **GitHub Actions**.
5.  GitHub will suggest a Hugo workflow. Click **Configure**.
6.  Commit the default workflow file.

**That's it!** GitHub will now build your site and deploy it to `https://your-username.github.io/my-portfolio`.

---

## 4. What to Include

Recruiters spend about 30 seconds on your site. Make it clear.

### 🏠 Home Page
*   **Headline**: "Cloud/DevOps Engineer specializing in AWS & Automation."
*   **Call to Action**: "View Projects" or "Download Resume."

### 📂 Projects
*   case studies of your "Golden Projects."
*   Architecture diagrams.
*   Links to the GitHub repo and live demo.

### 📝 Blog (The "Secret Weapon")
Writing about what you learn proves you have deep understanding.
*   *"How I reduced Docker image size by 40%"*
*   *"My journey learning Kubernetes"*

### 📄 Resume
*   A downloadable PDF version.
*   An HTML version for SEO.

---

## 5. Pro Tip: Custom Domain 🏷️

Nothing says "Professional" like your own `.com` or `.dev` domain.

1.  Buy a domain from Cloudflare or Namecheap (~$10/year).
2.  In GitHub Pages settings, add your Custom Domain (e.g., `www.ganil.dev`).
3.  GitHub will give you DNS records to add to your domain registrar.
4.  **HTTPS is free** and automatic with GitHub Pages.

---

## 🛠️ Next Steps

1.  [ ] Browse [Hugo Themes](https://themes.gohugo.io/) and pick one.
2.  [ ] Launch your "Hello World" site locally.
3.  [ ] Push to GitHub and enable Pages.
4.  [ ] (Optional) Buy a domain name.
