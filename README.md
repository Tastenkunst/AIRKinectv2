# AIRKinectv2 ANE v1.0.2 (short: KV2)

---

**- Updated blog post for missing dlls - 06th May 2015: -** http://blog.tastenkunst.com/2015/04/24/released-airkinectv2-ane-v1-0-1/

**- Current package with dlls in bin - 06th May 2015: -** https://www.dropbox.com/s/82u6a1l4ryk9lf5/150506_AIRKINECTV2_ANE_EXAMPLES_v1.0.2.zip?dl=0

---

**- what is it? -**
			
The AIRKinectv2 ANE is a wrapper for Microsoft's body tracking SDK "Kinect v2 for Windows".
It is an Adobe AIR native extension (ANE) for Windows 8 and 8.1.

**- ready to try! -**

You can try this ANE free of charge to evaluate if it fits your needs!
If you choose to use our software commercially, just contact us via:

http://www.tastenkunst.com/#/contact

Read the EULA carefully before using this ANE. Once you decide to use KV2 commercially, 
you will get a seperate license agreement, that you need to agree to.

**- visit us online -**

+ Facebook: 				https://www.facebook.com/BeyondRealityFace
+ Twitter:	 				https://twitter.com/tastenkunst
+ website:					http://www.tastenkunst.com
+ blog:						http://blog.tastenkunst.com

---

**- getting started -**

Microsoft provides an excellent overview of the Kinect v2 SDK on their site:
http://kinectforwindows.org

For important information on technical specifications and hardware requirements please visit:
http://www.microsoft.com/en-us/kinectforwindows/purchase/sensor_setup.aspx

From their site download the official SDK **v2.0.1410.19000** (10/21/2014), install it
on your 64bit Windows 8.1 power horse and attach the Kinect to your USB3 controller.

Open the app **"SDK Browser v2 (Kinect for Windows)"** and run the first entry: 
"Kinect Configuration Verifier".

If you pass all the tests and see the images (color and depth) at
the very end of that app, you have installed the Kinect and the SDK properly.

Find the download link for the ANE examples packed in the README.md on GitHub:
(GitHub actually filters the following files from a commit without notice.
So download the linked packed from that README.md)
https://github.com/Tastenkunst/AIRKinectv2

In the bin folder of this ANE package you will find two files and a folder:
* Kinect20.VisualGestureBuilder.dll
* Microsoft.Kinect.VisualGestureBuilder.dll
* vgbtechs

You need to package those file into your AIR App-Installer and thus deliver those
files via the installer. 

**You will also need to put those 3 elements into PATH_TO_AIR_SDK_17_0_0/bin/ .**
Otherwise you won't be able to debug/try your app using adl.exe.

If you try to run the examples and ask yourself, why it isn't working, it is 
most likely the missing files in that damn PATH_TO_AIR_SDK_17_0_0/bin folder
(hours wasted so far, after switching to a new AIR SDK version: at least 2).

We included 4 examples in this package. To get you started we recommend
starting with KV2ExampleColorFrame, which is the simplest setup for the Kinect 
(only showing the HD camera), going on with KV2ExampleDepthFrame and from there to 
KV2ExampleAll, which includes all the stuff you are looking for.

You will find the API reference in the /docs/ folder.
			
---

**- Actionscript -**

We develop using FDT (http://www.fdt.powerflasher.com), so this package is a FDT-project, 
that can easily be imported into your FDT. Use the launcher in /launch/ folder to start the examples.

For all other coding IDEs (e.g. Flash Builder, FlashDevelop, Intellij) the classpath settings
are as follows:
* /src/						- the example source code 
* /lib/						- the SWC lib folder, add all included SWCs to your classpath
* /ane/						- the ANE lib folder, add all included ANEs to your classpath

Examples are included:
* App						- Choose one of the following examples in that App class. It is also the document class for the FLA in /bin/ (tested in Flash CC 2014.2)
* KV2ExampleColorFrame		- Shows how to setup a KV2Example.
* KV2ExampleDepthFrame		- Shows how to use KV2Config to get the wanted results.
* KV2ExampleAll				- Let's you try all the things, that can be done with the ANE.
* KV2ExampleWaterRipple		- A water effect example, that can be controlled using your hands.
* KV2ExampleSwipeGesture	- A swipe gesture (left/right and up/down) tracking example.

---

**- release notes -**
		
**v1.0.2 - 06.05.2015:**

+ Added: KV2ExampleSwipeGesture for swiping left/right and up/down.
+ Fixed: KV2Body.color was set in wrong color channel order. Now Matches BodyIndexframe color as it should have been.
+ Fixed: KV2ExampleWaterRipple _showSilhouette=true did not show the silhouette.
		 needed to add _kv2Config.enableDepthFrame = _showSilhouette;
		 	
**v1.0.1 - 23.04.2015:**

Release! We used this ANE in a couple of projects since we started developing it.
It is stable thanks to the great work Microsoft put into their SDK. This is the first
release with the first couple of examples. More will follow in the comming months.
If you want to add an example you created, feel free to send us ober a simplified
version and we will include it for all the other developers out there.
If you have any feedback, just drop us a line and let us know. 

Here is what you can do with this ANE:

The Kinect provides body tracking for up to 6 bodies at a time. Each body has
25 body joints which make up the skeleton. A body also provided hand states
(open/closed/lasso).

Also implemented are the different image data streams (color, depth, infrared,
long exposure infrared, body index frame) and their mappings into the different 
coordinate systems (color space, depth space (both pixels) and camera space (in meter)).

Limitations: If someone is asking you, only one Kinect can be used at a time. 
This is a restriction in the current Microsoft SDK. The Kinect really eats up the 
USB bandwidth, you will see that, if you enable all the image data options at once.

What's on our todo list:
* We already implemented the VisualGestureBuilder functionality, but deactivated it in the current build, because it needs further testing. Basically this is about tracking/detecting trained gestures (GBD/GBA files).
* Performance optimizations.
* More examples for you.

We hope you like this release and build cool stuff with it.
Happy coding!

**The Tastenkunst Team.**