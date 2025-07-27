# pitrs_hud_v2

pitrs_hud_v2 is a dynamic and immersive heads-up display system built for both ESX and QBCore frameworks. With a modern design and full voice system integration, it offers real-time player status, minimap customization, voice proximity, and more — all synced with the server to ensure data persistence and RP immersion.

<img width="685" height="302" alt="{E2E79112-7B19-419C-A261-9FA83368EE6B}" src="https://github.com/user-attachments/assets/01b8f14c-3989-47a3-8309-5821406fe41c" />

<img width="486" height="211" alt="{D74C63D2-37AB-42E6-8A08-EE258DE89A83}" src="https://github.com/user-attachments/assets/54e30ad6-5268-49a5-bec3-443ebb394e36" />


### ✨ Features
🧠 Live Player Status Sync

Health, armor, hunger, thirst, stamina, and oxygen all update in real time

Syncs with the server on disconnect, reconnect, or spawn

Automatically saves on resource stop or player drop

### 🎤 Voice Integration with PMA-Voice

Voice proximity display: Whisper, Normal, Shouting

Talking indicator synced with actual voice activity

Toggle modes with customizable keybind (F11 by default)

### 🗺️ Custom Minimap & Compass

Repositioned minimap for modern layout

Directional compass (North, East, etc.) based on player heading

Auto-toggle minimap when entering or exiting a vehicle

### 📍 Live Location Display

Shows current street and area/zone name

Auto-updates every half second for accuracy

### ⏸️ Pause Menu Integration

Automatically hides HUD when pause menu is open

Seamless fade in/out when resuming gameplay

### 🛠️ Framework-Agnostic Design

Fully supports ESX 

Automatically detects and adapts to the active framework

Uses MySQL or player metadata to store health and armor

### 🧩 Modular & Configurable

Easily toggle HUD visibility with /hud

Fully expandable — ready for job icons, money display, or other stats



### 📦 Resource Info

|||
| --- | --- |
|**Code is accessible**|Yes|
|**Subscription-based**|No|
|**Lines (approximately)**|~1 201|
|**Requirements**|ox_lib,oxmysql,esx,pma-voice|
|**Support**|Yes|
