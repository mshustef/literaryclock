# literaryclock

This is a fork of elegantalchemist's literaryclock project. The instructions below have been updated to work with touchscreen Kindle versions and use the latest Kindle jailbreaking software. Specifically, I am working with the Kindle 10th Gen and all instructions have been tested on it.

The biggest difference to the original project is that this was intended as a gift to a non-tech-savvy friend. So I modified it to have minimal possibiity for error. Namely, there is no way to exit out of the app while its running (save for plugging in the Kindle and adding a stop file) and the app will automatically restart when the Kindle does. Touching the screen, pressing the power button, and closing the case lid all do nothing to stop the clock. 

Repurposing a Kindle into a clock which tells time entirely through real book quotes. A fascinating conversation piece as well as a beautiful and functional clock.

Non-destructive, the clock can be exited and the Kindle used as normal at any point.

Every time is from a real book quote and the current selection of quotes runs to slightly over 2300+ times for the 1440 minutes of a day. Every quote has the time preserved in it's original written format which means times can vary from 24h clock (1315h) to written format (twenty and seven past three). There are still a number of times still missing and some quotes are vague enough to be used to fill in some gaps.

<p align="center">
<img src="https://github.com/elegantalchemist/literaryclock/blob/main/images/literaryclockrunning.jpg" height="600">
</p>

## Materials
* **Kindle 10th Gen**
* **Computer** for use with SSH and transferring files

## Build Overview
The overview is fairly simple. Jailbreak the kindle, install KUAL, install USBNetLite, install Python. Use something like USB transfer to transfer all the files to the right place and then SSH into the kindle to set a cronjob.

That's it. Copy some files, then one CronJob + copy a file via SSH. I've tried to provide very detailed steps below - it might look more daunting before you get started.

The SSH is the hardest part by far but it's only needed for a small part

* **WARNING** None of this is what the kindle is designed to do and it's not hard to get it wrong and brick the Kindle. Do not proceed unless you are comfortable with this risk.

## **Step 1 - Make Some Images**
* Run the quote_to_image python script to generate your images in the 'images' folder. The script is designed to run in the same folder as the quotes csv file. There are various things you can do at this point - change fonts, link the files in different ways, etc.
* If you prefer to generate images without the author and title in them, you can change the line that says "include_metadata" to "False". These will be saved to /images/nometadata/ by default.
* You'll need to have Python and the Pillow module installed - `pip3 install pillow`. Installing Python is OS dependent but otherwise very straightfoward.
* The end result is you should have a folder containing 2,300+ images. This folder can be copied into the timelit folder so they run like .../timelit/images/.
* When it comes to copy the timelit folder across this can be done in one step, scripts and images all together.
* Generating the images should take less than 5 minutes. If this is a problem for you, I have included a zipped folder with all the metadata images also.
* There's also an older, PHP version of this script (requires Imagick and gd), which produces similar results. It's a bit less accurate and a chore to setup, so use at your own risk.

## **Step 2** - Jailbreak the kindle and install appropriate software - see the sources folder for these files
* **Optional but useful** Update the kindle amazon firmware to the newest, this helps with time and date setting in the background. Firmwares available here pay attention to your serial number. NOTE: Before doing so, ensure that the jailbreak software you are using has been updated to work with the firmware version or you will be unable to downgrade or jailbreak and will be stuck waiting until a new jailbreak software patch is released https://www.amazon.com/gp/help/customer/display.html?nodeId=GX3VVAQS4DYDE5KE
* **Jailbreak the kindle** https://kindlemodding.org will be your best friend here. Follow the 'Jailbreaking Your Kindle' section to install AdBreak or WinterBreak (depending on your firmware version). 
* **Post Jailbreak Steps** Perform these Post Jailbreak steps on your Kindle: 
    * **Set up a Hotfix** https://kindlemodding.org/jailbreaking/post-jailbreak/setting-up-a-hotfix/
    * **Install KUAL and MRPI** https://kindlemodding.org/jailbreaking/post-jailbreak/installing-kual-mrpi/
    * **Disable OTA Updates** https://kindlemodding.org/jailbreaking/post-jailbreak/disable-ota.html
* **Install USBNetLite** Use Marek's package at https://github.com/notmarek/kindle-usbnetlite/tree/master
    * Download the Update_usbnetlite_*.bin package from releases: https://github.com/notmarek/kindle-usbnetlite/releases
    * Place it into the mrpackages folder on the Kindle.
    * Launch KUAL on your kindle and run Helper->Install MR Packages


## **Step 3** - Install the scripts for this project
* Connect the Kindle to USB and you will see the storage on your computer available. This is /mnt/us/ in the linux filesystem so it's easier to copy and paste here over USB than trying to use rsync or SSH or whatever.
* Copy and paste over the timelit folder into /mnt/us/extensions so there now exists /mnt/us/extensions/timelit/ which contains the scripts, plus the images in their appropriate place /mnt/us/timelit/images
* Activate SSH over wifi by going to the KUAL launcher, clicking USBNetLite button, and then clicking enable SSH. 
* SSH into your kindle by entering ssh root@<kindle_ip_addr> into your terminal/PuTTY. You can find your Kindle IP by entering ";711" in the Kindle search bar. The default password is "kindle".
* Mount the root storage as read-write, then edit the crontab to add a cronjob, something like the below instruction set

```
mntroot rw
vi /etc/crontab/root
(add the below cronjob to the top of the crontab)
* * * * * /bin/sh /mnt/us/extensions/timelit/bin/timelit.sh
esc, ":wq" enter to save
mntroot ro
```

* This should be total extent of SSH/terminal needed - adding timelit.sh to a one minute cronjob.

## **Step 4** - Launch the clock
* From the kindle home screen, launch KUAL and then click 'Start Literary Clock'. Within a minute, the clock app will hijack your kindle screen and render all touches, button presses, etc. useless.

## **Step 5** - Stop the clock
* If necessary to stop the clock, restarting the kindle will not work. You can stop the clock by mounting the kindle to your computer and adding a file named "STOP" (with no extensions) to the root directory (/mnt/us). The app will stop within a minute and will automatically clean up the file for you. It may take up to a minute for the Kindle UI to relaunch - be patient. The clock app can then be restarted as normal.

## Uninstall
* All of the source files also have 'uninstall' variants to remove them from the Kindle if you wished to take it right back to the start.
* Delete all the folders and files you created yourself (but not the ones created by the updates like usbnet, python etc)
* Copy across the uninstall variants of each update one at a time and apply as an update, python, usbnet, launchapd, jailbreak.

## Credits
* The original project instructables by tjaap - https://www.instructables.com/Literary-Clock-Made-From-E-reader/
* Updated and modified scripts for running it by knobunc - https://github.com/knobunc/kindle-clock
* Hugely expanded list of quotes from JohannesNE - https://github.com/JohannesNE/literature-clock
* Original project ideas and crowdsourced quotes - the Guardian - http://litclock.mohawkhq.com/

## NSFW Warning
A number of the literary quotes contain NSFW language. I have little to no interest in filtering them out and they remain here unredacted. If you wanted to you could do a ctrl+f search and replace for common profanity through the quotes.
