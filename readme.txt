SimpleCoords v4.4

Description
===========
SimpleCoords creates a movable window that displays the player's location as coordinates.
Many web sites and tools use these coordinates to help players find objects or characters in the game.

It also allows you to enter the coordinates you are looking for and display them on the minimap.
Starting with version 3.00, SimpleCoords is using the HereBeDragons library by Nevcairiel.

Operation
=========
Hold down the shift key to drag and move the window.
Click the coordinate window to open/close the input window.
You can enter destination coordinates in this window. Press ENTER/RETURN to place a marker on the map at the destination location.


Install
=======
1) Quit the World of Warcraft application.
2) Extract the files into your World of Warcraft/Interfaces/AddOns directory.
3) Launch World of Warcraft.
4) The new coordinate window will appear in the middle of the screen.
   Drag it to your prefered location.


Features
========
* Compatibility with World of Warcraft v8.3 (Visions of N'Zoth)
* Very small memory footprint
* Minimal CPU overhead. Only updates twice a second


To-Do:
======
* Option to Lock in place
* Hide inside instances
* Allow comma to switch between fields


VERSION HISTORY
===============

Sep 21, 20201 (4.35)
* Updated TOC for client 9.1
* Updated HereBeDragons lib to 2.06
* Implemented new frame background methods introduced in 9.1

Mar 10, 2021 (4.34)
* Updated TOC and version for WoW 9.05 (Shadowlands)

Nov 23, 2020 (4.33)
* Fix error when hiding the map dot
* Fix heartbeat tick issue that can slow down client

Nov 22, 2020 (4.32)
* Remove debugging messages

Nov 19, 2020 (4.31)
* Updated TOC and version for WoW 9.02 (Shadowlands)
* Reorganized library folder
* Updated HereBeDragons lib to GitHub version 260eb9e

Oct 18, 2020 (4.3)
* Updated TOC and version for WoW 9 (Shadowlands)
* Updated HereBeDragons lib to 2.04

Jan 15, 2020 (4.21)
* Updated TOC and version for WoW client v8.3 (Visions of N'Zoth)

Oct 5, 2019 (4.20)
* Updated HereBeDragons lib to 2.0

July 5, 2019 (4.10)
* Updated TOC and version for WoW client 8.2
* Changed sounds to use IDs instead of file paths
* Updated HereBeDragons lib to 2.01

July 18, 2018 (4.00)
* Updated TOC and version for WoW client 8.0
* Updated HereBeDragons lib to 2.0
* Rewrite for new mapping API


Jun 27, 2018 (3.10)
* Updated TOC and version for WoW client 7.3
* Updated HereBeDragons lib to 1.19

Mar 30, 2017 (3.02)
* Updated TOC and version for WoW client 7.2
* Updated HereBeDragons lib to 1.18

Nov 04, 2016 (3.01)
* Updated TOC and version for WoW client 7.1
* Updated HereBeDragons lib to 1.14

Jul 24, 2016 (3.00)
* Rewrote most of the addon
* Fewer event handlers, remaining handlers use less CPU
* Switched from Astrolabe (no longer maintained) to HereBeDragons coordinate lib

Jul 18, 2016 (2.23)
* Updated TOC and version for WoW client 7.0

Jun 23, 2015 (2.22)
* Updated TOC and version for WoW client 6.2
* Zone data not yet updated

Feb 24, 2015 (2.21)
* Updated TOC and version for WoW client 6.1

Dec 22. 2014 (2.2)
* Solved issue when entering Level 2 mine in Alliance garrison.
* Updated to latest Astrolabe library

Oct 28, 2014 (2.1)
* Ignores most non-numeric characters entered
* Treats commas as periods (decimal points) for those that feel the need to use a comma
* Updated to latest Astrolabe library

Oct 13, 2014 (2.03)
* Updated TOC and version for WoW client 6.0.2
* Updated to latest Astrolabe library

September 10, 2013 (2.02)
* Updated TOC and version for WoW client 5.4x
* Updated to latest Astrolabe library (160)

March 5, 2013 (2.01)
* Updated TOC and version for WoW client 5.2
* Updated to latest Astrolabe library (160)

November 27, 2012 (2.00)
* Updated TOC and version for WoW client 5.1
* Updated to latest Astrolabe library (159)

August 28, 2012 (1.98)
* Updated TOC and version for WoW client 5.x
* Updated to latest Astrolabe library (147)

December 28, 2011 (1.96)
* Updated TOC and version for WoW client 4.3x

June 28, 2011 (1.95)
* Updated TOC and version for WoW client 4.2x
* Updated to latest Astrolabe library (---)

Apr 29, 2011 (1.94)
* Updated TOC and version for WoW client 4.1x
* Updated to latest Astrolabe library (v125)


Dec 3, 2010 (1.93)
* Updated to latest (experimental) Astrolabe library (v122) with support for new zones
* Fixed problem with world map

Dec 3, 2010 (1.92) - beta
* Updated to latest (experimental) Astrolabe library
* NOTE: This build supports minimap only

Oct 29, 2010 (1.9)
* Updated TOC and version for WoW client 4.0x
* Changed "this" to "self" for local references
* Changed to new script syntax in XML


Dec 8, 2009 (1.8)
* Updated TOC and version for WoW client 3.3
* Updated to latest Astrolabe library (rev 108)

Aug 5, 2009 (1.6)
* Updated to latest Astrolabe library (rev 107)
* Updated TOC and version for WoW client 3.2
* Can now use spacebar to toggle between fields as well as tab

May 6, 2009 (1.53)
* Updated to latest Astrolabe library (rev 105)
* Updated TOC and version for WoW client 3.1

Sep 28, 2008 (1.4)
* Fixed error if you hit return with an empty input area
* Sound effect for opening, closing, and dropping an icon
* Hitting ENTER now removes focus from edit fields

Sep 27, 2008 (1.3)
* Updated for WoW client 3.0
* Updated Astrolabe to WotLK branch from svn (rev 91)  http://svn.esamynn.org/astrolabe/branches/wotlk_data_temp/

July 22, 2008 (version 1.22)
* Updated to Astrolabe version 83


April 2, 2008
* Updated to latest Astrolabe version.

March 25, 2008
* Adds dot on world map as well as minimap

March 22, 2008
* Updated for Patch 2.4
* Unclude lastest build of Astrolabe
* New tooltip to show shift-drag option
* Removes dot on map when you arrive
* New "bullseye" dot for target

November 13, 2007
* Updated for patch 2.3

June 22, 2007 - 1.01
* Now correctly disposes of arrow if the coordinate tray is closed with the arrow showing.

June 22, 2007 - 1.0
Initial release
