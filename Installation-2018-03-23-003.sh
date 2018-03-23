# 20.03.2018  Installationsanleitung Datenlogger
# Image brennen auf SD-Karte (Win32 Disk Imager)
# Einstellungen anpassen, ssh Server aktivieren

sudo raspi-config
# Expand Filesystem, ect. 

# https://canox.net/2018/01/installation-von-grafana-influxdb-telegraf-auf-einem-raspberry-pi/

curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -

echo "deb https://repos.influxdata.com/debian stretch stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

sudo apt update

# telegraf wird installiert aber momentan nicht ben�tigt
sudo apt install influxdb telegraf

sudo systemctl enable influxdb
sudo systemctl start influxdb

#testen, beenden mit Exit
influx

CREATE USER "admin" WITH PASSWORD 'admin' WITH ALL PRIVILEGES
CREATE USER "rasp4" WITH PASSWORD 'rasp4' WITH ALL PRIVILEGES
CREATE USER "telegraf" WITH PASSWORD 'telegraf' WITH ALL PRIVILEGES
CREATE DATABASE "telegraf"
CREATE DATABASE "rasp4"

# Statt admin k�nnt ihr auch einen anderen Benutzernamen
# w�hlen und ihr solltet bei password ein sicheres Passwort vergeben.
# beenden mit Exit

sudo nano /etc/influxdb/influxdb.conf

# Hier m�ssen im Abschnitt [http] die folgende Zeilen �berpr�ft
# und gegebenenfalls muss die Raute # entfernt werden werden.

enabled = true
bind-address = �:8086�
auth-enabled = false
# evtl. true

sudo systemctl restart influxdb

# kann �bersprungen werden, wenn telegraf nicht genutzt wird, optional
sudo nano /etc/telegraf/telegraf.conf

# Die folgenden Eintr�ge in der Datei m�ssen angepasst werden:
database = "telegraf" # required
username = "telegraf" 
password = "telegraf"

# https://github.com/fg2it/grafana-on-raspberry/v5.0.3/grafana_5.3.3_armhf.deb

curl -LO https://github.com/fg2it/grafana-on-raspberry/releases/download/v5.0.3/grafana_5.0.3_armhf.deb

sudo apt-get update

sudo dpkg -i grafana_5.0.3_armhf.deb

sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Influx und Grafana ist nun installiert, Verbindung in Grafana anpassen

sudo apt-get install python-influxdb

# Datei anlegen
sudo wget https://github.com/M1Nattrodt/Datenlogger/blob/master/bootlogger.py
sudo chmod 755 /boot/bootlogger.py

# Autostart Arduino Logger
# zur Datei rc.local hinzuf�gen

sudo nano /etc/rc.local

	#exec 2> /tmp/rc.local.log      # send stderr from rc.local to a log file
	#exec 1>&2                      # send stdout to the same log file
	#set -x                         # tell sh to display commands before execution
	sleep 30 &&  /boot/bootlogger.py &
