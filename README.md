# DNR AI Hub

This folder contains two custom resources converted from the T1ger series to be standalone/QBCore compatible with modern interactions and persistence.

---

## 1. DNR Carlift (`dnr-carlift`)

A persistent carlift system that allows mechanics/admins to place lifts that remain across server restarts.

### Features
- **Persistence**: Lifts are saved to the database (`dnr_carlifts` table).
- **Admin Menu**: Dedicated menu to spawn persistent or temporary lifts.
- **Interactions**: Uses `qb-target` for all lift controls (Up, Down, Stop, Delete).

### Commands
- `/carlift`: Opens the management menu (Restricted to ACE permissions).

### Permissions
To allow a player or group to use the `/carlift` menu, add the following to your `server.cfg`:

```cfg
# Grant a group permission
add_ace group.admin command.carlift allow

# Or grant a specific player permission
add_principal identifier.license:your_license_here group.admin
```

### Setup
1. Ensure `oxmysql` is installed and running.
2. The script will automatically create the `dnr_carlifts` table on startup.
3. Ensure `qb-target` and `ox_lib` are started before this resource.

---

## 2. DNR Tow Missions (`dnr-towmissions`)

A breakdown mission system for tow truck drivers.

### Features
- **Tow Menu**: An `ox_lib` context menu to manage jobs.
- **Towing Logic**: Refined flatbed towing system for attaching/detaching vehicles.
- **NPC Missions**: Randomly generated breakdown locations with payout rewards.

### Commands
- `/towmenu`: Opens the job management menu (Request Job / Cancel Job).
- `/tow`: Toggles the attachment of the nearest vehicle to your flatbed.
- `/starttow`: Directly starts a random breakdown mission.

### Usage
1. Use a flatbed vehicle.
2. Open `/towmenu` and select **Request Job**.
3. Follow the GPS blip to the breakdown location.
4. Position your flatbed in front of the vehicle.
5. Use `/tow` to attach the vehicle.
6. Drive to the destination marked on your GPS.
7. Detach the vehicle at the target zone to receive your reward.

### Setup
1. Configure mission locations and rewards in `config.lua`.
2. Ensure `ox_lib` is started before this resource.

---

## Installation
1. Move both folders into your `resources/` directory.
2. Add the following to your `server.cfg`:
```cfg
ensure dnr-carlift
ensure dnr-towmissions
```
