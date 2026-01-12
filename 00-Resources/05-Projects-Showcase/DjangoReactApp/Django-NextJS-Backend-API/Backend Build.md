Install Python Latest Version or Current Project Version:
```bash
cd ~/Downloads   # Or wherever you have the Python source
wget https://www.python.org/ftp/python/3.12.3/Python-3.12.3.tgz
tar xvf Python-3.12.3.tgz
cd Python-3.12.3
./configure --enable-optimizations
make -j$(nproc)
sudo make altinstall

```
Create Environment:
```bash
python3 -m venv venv
# Then 
source venv/bin/activate
```
Install Django & Django-Ninja
```bash
pip install django django-ninja
```
Create `requirements.txt` file
```bash
pip freeze > requirements.txt
```
To install from requirements.txt file: 
```bash
pip install -r requirements.txt
```
Install rav 
```bash
pip install rav -y 
```
Configure rav.yaml file:
```bash
scripts:
  server:
    - cd src &&  python manage.py runserver 8001
  makemigrations:
    - cd src &&  python manage.py makemigrations
  migrate:
    - cd src &&  python manage.py migrate
```
Install NextJS
```bash
 npx create-next-app@latest
✔ What is your project named? … django-next-js-frontend
✔ Would you like to use TypeScript? … No / Yes
✔ Would you like to use ESLint? … No / Yes
✔ Would you like to use Tailwind CSS? … No / Yes
✔ Would you like your code inside a `src/` directory? … No / Yes
✔ Would you like to use App Router? (recommended) … No / Yes
✔ Would you like to use Turbopack for `next dev`? … No / Yes
✔ Would you like to customize the import alias (`@/*` by default)? … No / Yes 
```
Install Django Rest FrameWork
```bash
pip install djangorestframework
```
Add `'rest_framework'` to your `INSTALLED_APPS` setting.
```bash
INSTALLED_APPS = [
    ...
    'rest_framework',
]
```
If you're intending to use the browsable API you'll probably also want to add REST framework's login and logout views. Add the following to your root `urls.py` file.
```bash
urlpatterns = [
    ...
    path('api-auth/', include('rest_framework.urls'))
]
```
Create 2 Apps in the Backends folder:
```sh
django-admin startproject crud
#then
django-admin startproject api
```
Create a urls.py file in `/Backend/api.py` file:
```bash
# Backend/api/urls.py  

from django.urls import path  
from .views import *  

urlpatterns = [
  path('', home)
]
```
Edit `/Backend/api/views.py`
```bash
# Backend/api/views.py 

from django.shortcuts import render
from django.http import HttpResponse

def home(request):
  return HttpResponse("This is the homepage")
```
Then Edit: `Backend/crud/urls.py`
```python
# Backend/crud/urls.py  

from django.contrib import admin
from django.urls import path, include  

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('api.urls'))
]
```
Edit: `frontend/src/App.js`
```js
// frontend/src/App.js

import './App.css';  

function App() {
  return (
    <div className="App">
      <div>Badu Project</div>
    </div>
  );
} 

export default App;
```
Create `components` folder in the frontend
Then install Cors Headers in the backend folder
```python
python -m pip install django-cors-headers
```
Edit `/Backend/crud/settings.py`
```bash

INSTALLED_APPS = [
    ...,
    "corsheaders",
    ...,
]
```
And:
```
MIDDLEWARE = [
    ...,
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.common.CommonMiddleware",
    ...,
]
```
And:
```python
CORS_ALLOWED_ORIGINS = [
    'http://192.168.111.139:3000/',
    'http://192.168.111.139:8000/'
]
```
Create a requirements.txt React frontend:
```bash
npm list --depth=0 > react-requirements.txt
```
Edit: ``
```js
// @/frontend/src/index.js 

import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import { BrowserRouter as Router } from 'react-router-dom' <- Here<<

const root = ReactDOM.createRoot(document.getElementById('root'));

root.render(

  <Router>  //<---- Here ------<<
    <React.StrictMode>
      <App />
    </React.StrictMode>
  </Router> //<---- Here ------<<

);

// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals

reportWebVitals();
```
Create three js files in the components folder: 
- frontend/src/components/Home.js
- frontend/src/components/About.js
- frontend/src/components/Create.js
Then register the files in `frontend/src/App.js` file 
```js
// frontend/src/App.js  

import './App.css';
import { Routes, Route } from 'react-router-dom'
import Home from './components/Home';
import About from './components/About';
import Create from './components/Create';  

function App() {
  return (
    <div className="App">
      <Routes>
        <Route path='' element={<Home />} />
        <Route path='/about' element={<About />} />
        <Route path='/create' element={<Create />} />
      </Routes>
    </div>
  );
 }  

export default App;
```
Install Material UI from: (https://mui.com/material-ui/getting-started/installation/)
```bash
npm install @mui/material @emotion/react @emotion/styled
```
Install Material Icon:  (https://mui.com/material-ui/icons/)
```bash
npm install @mui/icons-material
```
Go to: (https://mui.com/material-ui/react-drawer/):
```js
// frontend/src/components/Navbar.js

import * as React from 'react';
import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import AppBar from '@mui/material/AppBar';
import CssBaseline from '@mui/material/CssBaseline';
import Toolbar from '@mui/material/Toolbar';
import List from '@mui/material/List';
import { Link, useLocation } from 'react-router-dom';
import Typography from '@mui/material/Typography';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import HomeIcon from '@mui/icons-material/Home';
import InfoIcon from '@mui/icons-material/Info';
import BorderColorIcon from '@mui/icons-material/BorderColor';  

const drawerWidth = 240;  

export default function Navbar() {
  const location = useLocation()
  const path = location.pathname
  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <AppBar position="fixed" sx={{ zIndex: (theme) => theme.zIndex.drawer + 1 }}>
        <Toolbar>
          <Typography variant="h6" noWrap component="div">
            Badu Application
          </Typography>
        </Toolbar>
      </AppBar>
      <Drawer
        variant="permanent"
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: { width: drawerWidth, boxSizing: 'border-box' },
        }}
      >
        <Toolbar />
        <Box sx={{ overflow: 'auto' }}>
          <List>
          
              <ListItem disablePadding>
              
                <ListItemButton component={Link} to="" selected={"" === path}>
                  <ListItemIcon>
                    <HomeIcon/>
                  </ListItemIcon>
                  <ListItemText primary={"Home"} />
                </ListItemButton>
                
              </ListItem>
                
              <ListItem disablePadding>
              
                <ListItemButton component={Link} to="/about" selected={"/about" === pat}h>
                  <ListItemIcon>
                    <InfoIcon/>
                  </ListItemIcon>
                  <ListItemText primary={"About"} />                  
                </ListItemButton>
                                                
              </ListItem>  

              <ListItem disablePadding>
              
                <ListItemButton component={Link} to="/create" selected={"/create" === path}>
                  <ListItemIcon>
                    <BorderColorIcon/>
                  </ListItemIcon>
                  <ListItemText primary={"Create"} />
                </ListItemButton>
                
              </ListItem>
              
          </List>

          <List>
            {['All mail', 'Trash', 'Spam'].map((text, index) => (
              <ListItem key={text} disablePadding>
                <ListItemButton>
                  <ListItemIcon>
                    {index % 2 === 0 ? <InboxIcon /> : <MailIcon />}
                  </ListItemIcon>
                  <ListItemText primary={text} />
                </ListItemButton>
              </ListItem>
            ))}
          </List>
        </Box>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <Toolbar />
      </Box>
    </Box>
  );
}
```