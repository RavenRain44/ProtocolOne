# Protocol One
Repository for the game Protocol One by Nexora Studios. Powered by [Rojo](https://github.com/rojo-rbx/rojo) 7.6.1.

## Getting Started
This repository is for the roblox game Protocol One. It uses Rojo to communicate between Roblox Studio and Visual Studio Code.

## Setup
If you run into any issues during the installation process, DM RavenRain44 on Discord with the issue.

#### Step 1. Install Visual Studio Code

Click on [this link](https://code.visualstudio.com/Download) to install visual studio code. From the official website.

#### Step 2. Get Rokit

Go to [this GitHub Repository](https://github.com/rojo-rbx/rokit/releases/latest) and scroll down to get the `rokit-X.X.X-windows-x86_64.zip` (assuming you are on windows)

If you aren't on windows, get the release that matches your computer. For Linux users, good luck. ;)

#### Step 3. Setup Visual Studio Code

Open your Visual Studio Code

In the top left, click `File -> Open Folder`, then create and open the folder to hold the project files.
I recommend making a "Code" folder in your "Documents" folder and then another folder inside your new "Code" folder labelled "ProtocolOne".
Once inside the new folder, press the "Open" button.

Don't make any files yet.

Next, click on the extensions tab on the left bar (looks like 4 blocks with 1 rotated)

Download the extensions: (* = optional)
- Luau language Server
- Rojo - Roblox Studio Sync
- Selene*
- SyLua*

#### Step 4. Finally, import the repository.

If you don't already have it, get [git](https://git-scm.com/install/) from the official website and go through the installation process.
After this, you will most likely need to restart your computer to verify changes.

Then, go back to Visual Studio Code and open the terminal from the top left by clicking `Terminal -> New Terminal`.
A terminal should pop up from the bottom. In this terminal, do the following command:
```bash
git clone https://github.com/RavenRain44/ProtocolOne.git . 
```

After this, everything should be set up.

## Usage

Assuming that you followed the setup and had no problems or errors, you should be able to start programming.

### Connect to Roblox

To connect your Rojo with roblox, you must install the Roblox Studio plugin using Visual Studio Code. 
- Press `ctrl + shift + P` and type "Rojo"
- Select the `Rojo: Open Menu` option
- Select the `Install Roblox Studio Plugin`
- Repeat the first two steps
- Select the bottom option with the green play button

Next, restart your roblox studio and then open the project (in our case it would be Protocol One)

Then, go to the plugins tab and open the new `Rojo` plugin

Finally, select the `Connect` option and that will connect to your Visual Studio Code

Optionally, you can open a terminal and do the command ```rojo serve``` to start the sync and then connect on Roblox Studio.

### Programming in Visual Studio Code

Anything file you create will be automatically created in Roblox Studio. 

This is NOT vice versa however.

Consequently, all files created in Roblox Studio do NOT go into Visual Studio Code (although there is an option to sync code changes).

#### Creating Files

There are 3 main folders `client`, `server`, and `shared`.

The `client` folder automatically ports to the `StarterPlayer/StarterPlayerScripts/Client` folder.
- To make a file, it follows the naming scheme of `*.client.lua`. (* is the file name, for example `FoodRarityColors.client.lua`)

The `server` folder automatically ports to the `ServerScriptService/Server` folder.
- To make a file, it follows the naming scheme of `*.server.lua`. (* is the file name, for example `CookHandler.server.lua`)

The `shared` folder automatically ports to the `ReplicatedStorage/Shared` folder.
- To make a file, it follows the naming scheme of `*.lua`. (* is the file name, for example `RecipeBook.lua`)

If you know basic Roblox Studio programming, you should know the differences between the three. 

#### Known Problems

If you are having problems, I would recommend looking it up or using ChatGPT. Also see the [rojo documentation](https://rojo.space/docs/v7/) for reference.

- I haven't looked too far into it, but I know doing the `require()` syntax throws an error sometimes.
