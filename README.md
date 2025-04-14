# Slick Escape

**Project:** Slick Escape  
**Author:** DrChicken2424  

**Play the Game:** [Slick Escape Demo](https://www.roblox.com/games/98115389918774/Slick-Escape-Demo)

## Overview

*Slick Escape* is a 2.5D stealth-based game built on the Roblox platform. The game challenges players to navigate through levels while avoiding enemy detection.

## Features

- **Stealth Mechanics:**  
  Players must avoid enemy vision zones and try to freeze in place when detected.

- **Dynamic Enemy AI:**  
  Enemies patrol specific waypoints but switch into a chasing state upon detecting player movement.

- **Level Progression & Tutorials:**  
  Each level increases in difficulty with unique environmental challenges such as slippery ice zones. Tutorial messages guide players through gameplay mechanics.

- **Visual & Audio Effects:**  
  Screen shakes, camera lock, and UI transitions enhance the immersive experience.

- **Modular Code Structure:**  
  The code is organized into clear modules (such as `EnemyModule`, `PlayerUtils`, `SafeZoneTracker`, etc.) separating client and server responsibilities for improved maintainability.

## Project Structure

The project follows a modular folder layout with clear separation between different aspects of the game. Some key directories are:

- **ServerScriptService**  
  Contains server-only scripts that manage authoritative game logic (e.g., enemy AI, level management, leaderstats, respawn handling).

- **ReplicatedStorage/Modules**  
  Holds shared modules which are used by both client and server scripts such as `EnemyModule.lua`, `PlayerUtils.lua`, and `SafeZoneTracker.lua`.

- **StarterGui**  
  Contains UI elements for the main menu, settings, tutorial, death screen, win screen, and level complete screens.

- **StarterPlayer**  
  Contains scripts that run on the client for handling player movement, camera control, and other client-specific functionality.

## Usage

- **Starting the Game:**  
  Upon launch, players are presented with a main menu where they can start the game or navigate to settings.  
  - Press the "Start" button to begin, which triggers the spawn, resets the player level, and starts gameplay.  
  - Adjust sound and music using the settings menu.

- **Gameplay:**  
  Navigate through levels using the standard WASD controls. Press SHIFT to dash.  
  Avoid enemy detection and use the safe zones to progress to the next level.  
  Each level provides increasing challenges with unique mechanics (e.g., ice sliding).

- **Tutorials & UI:**  
  Tutorials are displayed during the first levels using a typewriter effect and character viewport previews.  
  A win screen and level complete UI are displayed as appropriate.

## Credits

- **DrChicken2424:**  
  Developer and author of *Slick Escape*.
---

*Thank you for checking out Slick Escape!*
