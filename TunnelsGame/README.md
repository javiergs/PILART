#  _TUNNELS GAME_

# Table Of Contents

1. [Godot File Types](https://github.com/javiergs/PILART/edit/main/TunnelsGame/README.md#godot-file-types)
2. [Project File Explanation](https://github.com/javiergs/PILART/edit/main/TunnelsGame/README.md#project-file-explanations)
3. [Set Up](https://github.com/javiergs/PILART/blob/main/TunnelsGame/README.md#set-up)

# Godot File Types
There are three file types in the godot editor. [***Scenes***](https://github.com/javiergs/PILART/edit/main/TunnelsGame/README.md#scenes) and [***Scripts***](https://github.com/javiergs/PILART/edit/main/TunnelsGame/README.md#scripts)

### Scenes

Scenes are the visual 3D models in godot used to design things that will be seen by a user and are the files that end with .tscn. 

A scene is made up of:
- Nodes: Can be seen as a folder of other 3D objects which can contain scenes of their own
- Bodies: The physical body of a player, possible enemies, or other objects
- Mesh Instance: The visual surrounding a body
- Canvas Layer: Similar to an overlay on the screen with no physical properities in the game other than clickable buttons

>[!TIP]
>![image](https://github.com/user-attachments/assets/fbf733ee-8555-4a39-9a4a-b80882c70e66)
>
>This is what the game scene looks like, it is comprised different level nodes containing cities and tunnels which each have their own scenes, a canvas layer named "textbox" which controls pop up instructions and the pause menu, and a player body for what the user will control. 

>[!NOTE]
>In this project, all the scenes are contained in the "Scenes" folder with normal_view_map and vr_map being the primary scenes


### Scripts

Scripts are the attached code files that run the behavior of their respective node and are the files that end with .gd. 

In a script there are two special godot functions that are automatically called: 
- _ready(): runs once when the game starts
- _process(): runs whenever the frame changes 

>[!TIP]
>Scipts are written with a syntax similar to python

# Project File Explanations


# Set up

## Needed Resources
To begin using the tunnels game, download the following:

1. [Godot Game Engine](https://godotengine.org/)
2. [Blender](https://www.blender.org/)
3. [Tunnels Game code](https://github.com/javiergs/PILART/tree/main/TunnelsGame)
4. [Godot XR tools](https://github.com/GodotVR/godot-xr-tools)


Follow the instructions below to set up and run the Tunnels game (tips with pictures on what to look for down below)
...

    1. Unzip the "TunnelsGame" folder.
    2. In the godot engine click the import button on the top left.
    3. Locate and double click the TunnelsGame folder in the godot filesystem to enter the folder
    4. Click on "Select Current Folder" on the bottom left of the filesystem
    5. Click on "Import and Edit" to open the project
    6. Go to project settings in the "Project" tab in the top left corner
    7. Search for "blender" and under the "FileSystem" and "Import" tab, ensure the first checkbox under Blender is on
    8. Under the "plugins" tab, make sure both plugins' enabled checkboxes are enabled and close those settings
    9. Go to editor settings in the "Editor" tab in the top left corner
    10. Search for "blender" and under "FileSystem" and "Import", click on "Blender 3 Path" 
    11. Find where your "Blender[version number]" folder is located and click on "Select Current Folder" to tell the Godot where your blender program is located
    12. Finally, press the play button on the top right corner to preview the game
...
>[!IMPORTANT]
>If the VR experience is wanted, search for the "prototipo_mapa_final.tscn" file in the godot filesystem in the bottom left, right click and "Set as Main Scene" before pressing play

>[!TIP]
>Step 2 button:
>
>![image](https://github.com/javiergs/PILART/assets/113921844/d7bb8f5f-b4a7-42b1-8ae5-d0567b2a91cd)

>[!TIP]
>Project and Editor Tabs:
>
>![image](https://github.com/javiergs/PILART/assets/113921844/afe92bba-be0c-4136-9f10-fc233f9cd126)

>[!TIP]
>Step 8 image:
>
>![image](https://github.com/javiergs/PILART/assets/113921844/7f0609ea-89cc-45d9-9ba7-e117754b643e)



> [!TIP]
> If there are any errors when first opening the project, simply press "Reload Current Project" under the "Project" tab in the top left.

> [!TIP]
> When looking for your blender folder, my path was C:/Program Files/Blender Foundation/Blender 4.1, yours may be similar.

