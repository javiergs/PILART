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
- normal_view_map.tscn
    - The overall map scene of the game containing everything seen in the game
- player_car_normal.tscn
    - The car the user is controlling in the game
- textbox_instructions.tscn
    - The textbox and pause menu graphics
- textbox_instructions.gd
    - Controls the instructions and pause menu
- map_data.json
    - the data to configure a level that controls:
        - starting city
        - ending city
        - intersection sign names
        - city names
- low_poly_city.gd
    - code to keep track of when a player enters a city to know when the game ends
- car.gd
    - code to allow the player to control the car
- Global.gd
    - Global variables for the game

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


# Level Configuration

## Level Building Blocks
1. City Nodes: Different Cities
    - The roads surrounding the city node can be customized with three different roads to move:
        - The Corner road
        - The city exit: place where you want to create a connection to a tunnel
        - Regular Road: place/transform between different exits to be able to reach them
2. Ramp
   - A ramp is how the user can reach the tunnels from the city, since the city nodes are above the tunnels
3. Intersection
    - Location where the tunnels can split
    - In the intersection there are signs that can be written on within the map data json file.
4. Straight Tunnel
    - Closed Variant Available
5. Curved Tunnel
    - Closed Variant Available
  



## Building A 3D Level
![image](https://github.com/user-attachments/assets/1cab3757-b193-455d-875a-71c17adedb09)


To create a new level, you must first switch to the 3D tab, on the top of the screen, to see the physical level setup. The easiest way to create a new level is to copy and paste a 3D level node to duplicate it then using the four left options to alter the level. 


Starting from the cursor icon:
1. The cursor icon is the select option, to choose which nodes you want to edit since the node names are too similar to know which one you are editing.
>[!TIP]
>The next options all have directional options with:
> - Green: Z-Axis
> - Red: Y-Axis
> - Blue: X-Axis 
>
>![image](https://github.com/user-attachments/assets/86ca9953-7625-4bf2-8808-f26809796ae3)
>
> By holding the middle of the node and dragging, you can move the node freely in each direction
>
> By holding an arrow, you will move **only** in the direction of the respective arrows color
>
> By holding a square, you will be able to move in every direction **other than** the direction of the sqaures color

2. The four arrows indicate the move option, where you can translate the node
3. Next to that is the rotate option
4. Lastly, the scale option to make the node bigger

>[!TIP]
>When selecting a node to move it, make sure you click the top node group to move the entire object, otherwise some rendering mistakes may occur

>[!NOTE]
>When you need to add new nodes if you copy and paste the node you need to add, godot will automatically add a number to the end of that nodes name, which should continue the pattern to keep the code running
well. If it does not, make sure all the city and intersection nodes have the same naming pattern

You can add new nodes from dragging them into the 3D area from the file system in the bottom left or copy and paste them like described above, however, you must make sure they are under the correct level node. 

## Adding Level Data
After configuring your level in the 3D model, you must go into the script tab and change the max levels on line 183 in the map_behavior.gd file so the level can run 

Next, you should open the map_data.json file to add your levels data to correctly label the city's and intersection signs. The data should be input in this format for each level: 

```

"[LEVEL NUMBER]": {
    "start": "[SPAWING CITY NAME]",
    "goal": "[GOAL CITY NAME]",
    "cities": {
        "[CITY NODE NUMBER]": "[CITY NAME]",
        "2" : "Troya",
        ...
    },
    "intersections": {
        "[INTERSECTION NUMBER]": {
            "left_sign": {
                "left": {
        			"1": "[CITY NAME]",
    				"2": "[CITY NAME]",
    				"3": "[CITY NAME]"
    			},
            	"right": {
    				"1": "[CITY NAME]",
                    "2": "[CITY NAME]",
            		"3": "[CITY NAME]"
    			}
            },
            "right_sign": {
                "left": {
        			"1": "[CITY NAME]",
            		"2": "[CITY NAME]",
                	"3": "[CITY NAME]"
                },
                "right": {
                    "1": "[CITY NAME]",
                	"2": "[CITY NAME]",
                    "3": "[CITY NAME]"
                }
            },
            "middle_sign": {
                "left": {
            		"1": "[CITY NAME]",
        			"2": "[CITY NAME]",
            		"3": "[CITY NAME]"
                },
                "right": {
        			"1": "[CITY NAME]",
            		"2": "[CITY NAME]",
                	"3": "[CITY NAME]"
            	}
            }
        }
    }
},

```
>[!IMPORTANT]
> If the direction sign names are left as "", this will leave that sign blank. Therefore there should be exact a list of 1 - 3, if a sign is not being used simply make its city name an empty string to avoid invalid level loading
