## Instructions For AR Projects
### How to open project files
1. Open OneDrive Link and download project file (unzip if needed)
2. Go to Unity Hub -> Projects Tab, then click Add, and locate the project files in your file explorer
3. This should open up the project with the correct packages and settings (if not let me know)

### Must Do Before Building Project
In order for the plane detection to work on a Meta Quest, you must give the headset your preconfigured Spatial Data before building the project.
Before completing these steps, make sure your headset is updated to the latest version, because some of this functionality was only experimental
up until a recent update.
1. Go to Quick Settings -> Settings -> Physical Space -> Space Setup
2. Click "Set Up" and the headset will guide you through that process

## Overview of OpenXR AR Project
*Has Ray Interaction, Controller Based*
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

## Overview of Meta All-In-One Scene Understanding Project
*Has Ray Interaction, Controller Based*
### Scene Understanding
Scene Understanding is a general term that describes the more in depth and practical construction of an XR scene provided by Meta's XR SDK's. By making every element (walls, furniture, objects, hands, head, eyes, etc.) an anchor, every aspect of the scene is easier to access, modify, and build. Most of this functionality comes from the Mixed Reality Utility Kit (MRUK) and its accompanying tools (see my AR Learning doc for more info). The most important of these tools are the MRUK, Effect Mesh, and Anchor Prefab Spawner.
### Tools Being Used
#### MRUK:
The MRUK handles the construction of the rooms and scenes. It makes every component of the scene an anchor, which improves raycasting, geographical precision, and prefab placement.
#### Effect Mesh:
The Effect Mesh is responsible for the meshes of each plane in the room, as well as their textures. The meshes are helpful in rendering and especially in physics interactions.
#### Anchor Prefab Spawner:
The Anchor Prefab Spawner allows you to replace any anchor in the room with a prefab, allowing you to overlay real world objects with virtual ones and much more. Although it is a little less practical, this is the closest we will get to Object Detection and overlay on the Quest 2.

## Overview of Hand Location Tracking and Exporting Project
*No Interaction, Hand Based*
### WebSockets 101
A WebSocket enables live, 2-way communication between a "Client" (headset) and a "Server" (computer/robot). A "Handshake" is performed to open the connection, and messages can be sent freely until the connection is manually closed by the Client or Server.
### Hand Tracking
The actual hand tracking is mostly handled through the hand tracking building block which adds all necessary components to the project. I wrote a script that is attached to the hand objects, in which hand location and rotation are determined by accessing the transform of the OVRHand component. I export these raw, three dimensional position and rotation values in a single message for each hand in the format [x,y,z,roll,pitch,yaw]. I chose this specific format because it matches the parameters of the movel() function, which will be used by the other SURP group to control the robot.
### WebSocket Data Streaming
I wrote a JavaScript program that creates a WebSocket Server on my computer which can open/close a WebSocket connection and handle incoming messages from a WebSocket Client. In the hand tracking script within Unity, I wrote code to initialize the headset as a WebSocket Client and send the hand's positional quadrant once per frame to be printed in the Terminal via the Web Socket Server. The destination of the WebSocket Server, and how the information is dealt with once received from the client can be altered within the JavaScript file.

## Learning and Project Documentation
[Augmented Reality Learning](https://docs.google.com/document/d/1lSMP8arB5uru4-At-8WbLQpiR-VjMdZmdBnzxvODu0s/edit?usp=sharing)

[SURP Overview](https://docs.google.com/document/d/16f_o1X2NrhacGVFAV2vseqfDpp6lOkFRui4BquvREY4/edit?usp=sharing)

