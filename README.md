# ccDevice
An expandable device system in computer craft. creating apps is below the images. now updated to use websockets instead of an in game server.

# setup
## client
to install just run the below code on the device, it will bring you through the steps.
```
wget https://raw.githubusercontent.com/popcornman209/ccDevice/main/install.lua
install.lua
```
run this script and it should bring you through the install process, you need a running server to connect to to complete it.<br />
as for the server setup, just clone the server/ directory and run server.py
## server
to install on the server, clone this git
```bash
git clone https://github.com/popcornman209/ccDevice.git
cd ccDevice
```
then if you want, create a venv
```bash
python -m venv venv
source venv/bin/activate
```
install requirements
```bash
pip install -r requirements.txt
```
and run the server
```bash
cd server/
python server.py
```

# photos
![rando image](photos/phone1.png)
![other rando image](photos/phone2.png)
![another rando image](photos/bank.png)