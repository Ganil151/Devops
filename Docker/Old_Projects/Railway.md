🛠️ **Railway CLI Commands Cheat Sheet**  
Welcome to the command bridge, Commander. Here's your **Railway CLI mission-ready command list**—tailored for **Django + Docker + Railway** on Windows 11 & VS Code.

---

## 🚀 **Project Lifecycle**

|Command|Purpose|
|---|---|
|`railway init`|Initialize a new Railway project in current folder|
|`railway up`|Deploy the project to Railway (auto-detects Docker/Nixpacks)|
|`railway down`|Stop the project (not delete)|
|`railway open`|Open the project dashboard in your browser|
|`railway login`|Authenticate CLI with your Railway account|
|`railway link`|Link current folder to an existing Railway project|
|`railway unlink`|Unlink local folder from a Railway project|

---

## 🗃️ **Database & Env Variables**

|Command|Purpose|
|---|---|
|`railway add plugin postgresql`|Add a PostgreSQL database plugin|
|`railway variables`|View all environment variables (including `DATABASE_URL`)|
|`railway run <cmd>`|Run a command with Railway’s environment vars (e.g. `python manage.py migrate`)|
|`railway run bash`|Open a shell session inside the Railway environment|

---

## 🔁 **Deployments & Logs**

|Command|Purpose|
|---|---|
|`railway status`|Show current deployment status|
|`railway logs`|View app logs (streamed from Railway)|
|`railway redeploy`|Trigger a redeploy of the current project|
|`railway environments`|List available environments (like `production`, `preview`)|
|`railway switch`|Switch between environments|

---

## 🔧 **Debug & Dev Tools**

|Command|Purpose|
|---|---|
|`railway dev`|Run your Railway project locally with synced environment vars|
|`railway shell`|Open an interactive shell into the running Railway container|
|`railway disconnect`|Detach plugins (like Postgres) from a project|

---

## ⚙️ **Deploy From GitHub (if connected)**

|Command|Purpose|
|---|---|
|`git push origin main`|Push your latest changes — will auto-deploy on Railway|
|_(No CLI required)_|Railway handles deploy on every push to your linked GitHub repo|

---

## 💣 Danger Zone

|Command|Purpose|
|---|---|
|`railway delete`|Delete the current project (with confirmation)|

---

## 🎯 Example Use Cases for Django

```bash
# Run DB migrations
railway run python manage.py migrate

# Create admin user
railway run python manage.py createsuperuser

# Open live logs
railway logs

# View current env variables
railway variables

# SSH into container
railway run bash
```

---

Would you like an alias file (`.bash_aliases`) for Windows Terminal or PowerShell to speed these up? Or a VS Code task runner setup to run them with hotkeys?

🟢 Ready for next mission.