# Dynamic Island for Roblox

[English](README.md) | [中文](README_CN.md)

A modern notification system inspired by iOS Dynamic Island, designed for Roblox games.

## Features

- **Multiple Notifications**: Display up to 3 notifications simultaneously
- **Smart Queue**: Automatic queue management with priority support
- **Interactive Animations**: Smooth transitions and jelly effects
- **Theme Support**: Built-in dark and light themes
- **Touch Optimized**: Fully responsive on mobile and desktop
- **Draggable**: Move the island anywhere on screen

## Installation

```lua
local DynamicIsland = loadstring(game:HttpGet("YOUR_SCRIPT_URL"))()
```

## Quick Start

```lua
-- Show a notification
_G.ShowIslandNotification("Title", "Content", "success", 3)

-- Available types: success, error, warning, info
```

## API Reference

### ShowIslandNotification
```lua
_G.ShowIslandNotification(title, content, type, duration, priority)
```

**Parameters:**
- `title` (string): Notification title
- `content` (string): Notification content
- `type` (string): Notification type - "success", "error", "warning", or "info"
- `duration` (number): Display duration in seconds (default: 3.5)
- `priority` (number): Queue priority (default: 1, high priority: >5)

### ToggleTheme
```lua
_G.DynamicIsland.ToggleTheme()
```
Switch between dark and light themes.

### ToggleVisibility
```lua
_G.DynamicIsland.ToggleVisibility()
```
Show or hide the Dynamic Island.

### Destroy
```lua
_G.DynamicIsland.Destroy()
```
Clean up and remove the Dynamic Island.

## Configuration

```lua
local Config = {
    DemoMode = false,
    DefaultNotifDuration = 3.5,
    MaxQueueSize = 20,
    MaxConcurrentNotifications = 3,
    NotificationSpacing = 10,
}
```

## Interactions

- **Single Click**: Trigger menu (K key)
- **Double Click**: Toggle theme
- **Drag**: Move the island
- **Hover**: Show close button

## Examples

### Basic Notifications
```lua
_G.ShowIslandNotification("Success", "Operation completed", "success")
_G.ShowIslandNotification("Error", "Something went wrong", "error")
_G.ShowIslandNotification("Warning", "Please be careful", "warning")
_G.ShowIslandNotification("Info", "New message received", "info")
```

### Custom Duration
```lua
_G.ShowIslandNotification("Loading", "Please wait...", "info", 10)
```

### High Priority
```lua
_G.ShowIslandNotification("Critical", "Urgent message", "error", 5, 10)
```

### Multiple Notifications
```lua
for i = 1, 5 do
    _G.ShowIslandNotification("Message " .. i, "Content", "info", 3)
    task.wait(0.2)
end
```

## Browser Support

- Desktop (Windows, macOS, Linux)
- Mobile (iOS, Android)
- Tablet devices

## Performance

- Optimized memory management
- Automatic cleanup of expired notifications
- Efficient tween handling
- No memory leaks

## Technical Details

- **UI Framework**: Roblox GUI
- **Animation**: TweenService
- **Mobile Support**: Touch and drag optimized
- **Security**: Environment validation included

## Contributing

Contributions are welcome. Please ensure code quality and test thoroughly before submitting.

## License

MIT License - Feel free to use in your projects.

## Author

**xiaomao**

## Changelog

### Version 1.0
- Initial release
- Multi-notification support (up to 3 concurrent)
- Interactive animations
- Theme system
- Notification queue with priority
- Mobile optimization
- Drag and drop functionality

## Support

For issues or questions, please open an issue on GitHub.

---

**Note**: This is a client-side script. Ensure proper security measures when implementing in production environments.

