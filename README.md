# Protocol One

Repository for the Roblox game **Protocol One** by Nexora Studios.  
Powered by [Rojo](https://github.com/rojo-rbx/rojo) **v7.6.1**.

---

## Overview

This repository contains the source code for *Protocol One* and is designed to be used with **Rojo** to sync files between **Roblox Studio** and **Visual Studio Code**.

---

## Prerequisites

Before starting, make sure you have:
- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- Roblox Studio

---

## Setup Guide

If you run into issues during setup, DM **RavenRain44** on Discord with details about the error.

### 1. Install Visual Studio Code

Download and install VS Code from the official website:  
https://code.visualstudio.com/Download

---

### 2. Install Rokit

1. Go to the latest Rokit release:  
   https://github.com/rojo-rbx/rokit/releases/latest
2. Download the archive matching your OS  
   - Windows: `rokit-X.X.X-windows-x86_64.zip`
3. Extract and install following the included instructions

---

### 3. Configure Visual Studio Code

1. Open **Visual Studio Code**
2. Click **File → Open Folder**
3. Create and open a folder for the project  
   - Example: `Documents/Code/ProtocolOne`
4. Open the **Extensions** tab and install:
   - **Luau Language Server**
   - **Rojo – Roblox Studio Sync**
   - **Selene** (optional)
   - **SyLua** (optional)

Do **not** create any files yet.

---

### 4. Clone the Repository

1. Open the VS Code terminal:  
   **Terminal → New Terminal**
2. Run the following command:

```bash
git clone https://github.com/RavenRain44/ProtocolOne.git .
```
Once complete, the project should be fully set up.

---

## Usage
### Connecting Rojo to Roblox Studio
1. Press `Ctrl + Shift + P` in VS Code
2. Type **Rojo**
3. Select **Rojo: Open Menu**
4. Choose **Install Roblox Studio Plugin**
5. Open the menu again and select the option with the green ▶ button
Then:
1. Restart **Roblox Studio**
2. Open the _Protocol One_ place
3. Go to the **Plugins** tab
4. Open the **Rojo** plugin
5. Click **Connect**

Alternatively, you can start Rojo manually:

```bash
rojo serve
```
Then connect from the Roblox Studio plugin.

### Development Workflow
- Files created in VS Code sync to Roblox Studio.
- Files created in Roblox Studio do not sync back by default.

---

### Project Structure
The repository is organized into three main folders:

#### `client`
- Syncs to: `St#rterPlayer/StarterPlayerScripts/Client`
- File naming: `*.client.lua`
	- Example: `FoodRarityColors.client.lua`

#### `server`
- Syncs to: `ServerScriptService/Server`
- File naming: `*.server.lua`
	- Example: `CookHandler.server.lua`

#### `shared`
- Syncs to: `ReplicatedStorage/Shared`
- File naming: `*.lua`
	- Example: `RecipeBook.lua`

If you are familiar with Roblox development, the separation should be self-explanatory.

---

### Known Issues & Help
- Some `require()` patterns may occasionally cause errors
- If you encounter issues:
	- Search the error message
	- Use ChatGPT
	- Refer to the official Rojo documentation: [https://rojo.space/docs/v7/](https://rojo.space/docs/v7/)
