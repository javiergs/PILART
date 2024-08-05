## Instructions For AR Projects
### How to open project files
1. Open OneDrive Link and download project file
2. Go to Unity Hub -> Projects Tab, then click Add, and locate the project files in your file explorer
3. This should open up the project with the correct packages and settings (if not let me know)

### Must Do Before Building Project
In order for the plane detection to work on a Meta Quest, you must give the headset your preconfigured Spatial Data before building the project.
Before completing these steps, make sure your headset is updated to the latest version, because some of this functionality was only experimental
up until a recent update.
1. Go to Quick Settings -> Settings -> Physical Space -> Space Setup
2. Click "Set Up" and the headset will guide you through that process

## Overview of AR Project
### Plane Detection
If you have done the Space Setup for your headset, the Plane Detection I have built will create a "virtual room" that mirrors the one you are 
currently in. A virtual plane will be built to the dimensions and orientation of all surfaces detected in your Space Setup, meaning you can 
interact with your real world environment using virtual objects. I have also added a Projectile Launcher to demonstrate this feature. You can 
launch blocks from your right hand which will bounce off the virtual walls or land on the furniture you have included in your Space Setup.

### Spatial Anchors
A Spatial Anchor defines a real world, geographical position and rotation for a virtual object. The position of Spatial Anchors are not defined
relative to the headset, so they have consistent precision within an environment regardless of the user's location and even across AR sessions. 
For example, if you wished to have a virtual minigolf course that wound through several rooms of your house, the exact location of the virtual 
holes would need to stay where you put them in the room even when you are moving from room to room, so a Spatial Anchor would be required.

### Video Player
The Video Player is a Spatially Anchored plane that can be spawned on any surface in the room, and can play any video you upload to the project. 
The video can be paused and played using the right ray interactor.

### Controls and Bindings
Left Top Trigger - Place Video Player <br/>
Left Bottom Trigger - Force Grab Objects <br/>
Right Top Trigger - Play/Pause Video Player <br/>
Right Bottom Trigger - Shoot Blocks

## Documentation/Timeline of Work
[SURP Overview]([url](https://docs.google.com/document/d/16f_o1X2NrhacGVFAV2vseqfDpp6lOkFRui4BquvREY4/edit?usp=sharing))
[Augmented Reality Learning]([url](https://docs.google.com/document/d/1lSMP8arB5uru4-At-8WbLQpiR-VjMdZmdBnzxvODu0s/edit?usp=sharing))

