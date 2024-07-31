# ccDevice
An expandable device system in computer craft. creating apps is below the images. now updated to use websockets instead of an in game server.

# setup
to install just run the below code on the device, it will bring you through the steps.
```
wget https://raw.githubusercontent.com/popcornman209/ccDevice/main/install.lua
install.lua
```
run this script and it should bring you through the install process, you need a running server to connect to to complete it.<br />
as for the server setup, just clone the server/ directory and run server.py

# photos
![rando image](photos/phone1.png)
![other rando image](photos/phone2.png)
![another rando image](photos/bank.png)

# creating an app
i will never update the phone/ directory, as there is no reason to, the second you turn it on it will update itself with the server.

### server side
files/ is just the phones filesystem, so it will look the same as it.<br />
programs/ is for updating, its all the related files, and the version. the phone will check if there is a newer version and auto update.<br />
store/ is for the app store<br />
bank/ is all bank accounts<br />

### phones
apps/ is how the phone lists all apps in the main apps menu<br />
data/ is for anything you need to save, bank accounts, color choices, anything settings wise for the most part<br />
files/ is where all lua files are, and files/settings/ is for any of the settings menus<br />
settingData/ is for any custom settings menu you make for your app, its the same as apps/ but displays in the settings app<br />
uninstall/ is the uninstall scripts, its just a list of any files the phone should delete if you want to uninstall your app.<br />

# examples of files
## client side
### bank accounts
```
{'name': 'Hello_human', 'key': '9565876', 'balance': 0, 'admin': False}
```
the name of the file is the id, and the rest is fairly self explanatory. the admin feature decides weather you have infinite money or not, you need this for the atm's.

### apps/
```
{
  name = "display name",
  file = "files/fileToRun.lua",
  id = "serverSideID",
  version = "1.0.0",
}
```
the file is what will run when you open the app<br />
id is the id used by the app pretty much everywhere, its used for updating. same with the version variable

### settingData/
```
{
  name = "display name",
  file = "files/settings/fileToRun.lua",
}
```
this is basically the same as the apps/ file, just missing all the updating as this should update with the app.

### uninstall/
```
{
    name = "banking",
    files = {
        "files/fileToRun.lua",
        "apps/Example",
        "uninstall/Example",
    },
}
```
the name is display name, and files is a list of any and all files related to this app that should be uninstalled with it.
