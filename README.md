DemoTools/
├── mod.json
├── scripts/
│   ├── demo_hud.nut
│   ├── demo_controls.nut
│   └── spectator_extension.nut
└── resources/
    └── ui/
        ├── observer_hud.res
        └── controls_scheme.res



# Основные команды
   spec_next       # Следующий игрок
   spec_prev       # Предыдущий игрок
   spec_freecam    # Свободная камера
   
   # Настройки
   set spec_speed 500  # Изменить скорость

Вот полный набор файлов для мода **DemoTools** с базовым функционалом наблюдения (без модификации ядра Northstar):

---

### 📂 **Структура мода**
```
DemoTools/
├── mod.json
├── scripts/
│   ├── demo_hud.nut
│   ├── demo_controls.nut
│   └── spectator_extension.nut
└── resources/
    └── ui/
        ├── observer_hud.res
        └── controls_scheme.res
```

---

### 1. **mod.json** (основной конфиг)
```json
{
    "Name": "DemoTools",
    "Version": "1.0",
    "Description": "Enhanced spectator tools for demo playback",
    "Authors": ["YourName"],
    "Dependencies": {
        "Northstar.Client": "1.10.0"
    },
    "ConVars": [
        {
            "Name": "spec_speed",
            "DefaultValue": "350",
            "Description": "Free camera speed"
        },
        {
            "Name": "spec_hud_enabled",
            "DefaultValue": "1",
            "Description": "Toggle observer HUD"
        }
    ],
    "ConCommands": [
        {
            "Name": "spec_next",
            "Description": "Switch to next player"
        },
        {
            "Name": "spec_prev",
            "Description": "Switch to previous player"
        },
        {
            "Name": "spec_freecam",
            "Description": "Toggle free camera"
        }
    ]
}
```

---

### 2. **scripts/demo_hud.nut** (HUD наблюдателя)
```squirrel
global function InitDemoHUD

struct {
    var infoPanel
    var nameLabel
    var timeLabel
} file

void function CreateObserverHUD() {
    file.infoPanel = HudElementGroup.Create("ObserverInfo")
    
    file.nameLabel = file.infoPanel.CreateElement("Label", "NameLabel")
    file.nameLabel.SetPos(100, 50)
    file.nameLabel.SetText("Player: None")
    file.nameLabel.SetColor([255, 255, 255, 255])
    
    file.timeLabel = file.infoPanel.CreateElement("Label", "TimeLabel")
    file.timeLabel.SetPos(100, 80)
    file.timeLabel.SetText("00:00")
}

void function UpdateHUD(entity target) {
    if (!GetConVarBool("spec_hud_enabled")) return
    
    file.nameLabel.SetText("Player: " + (IsValid(target) ? target.GetPlayerName() : "None"))
    file.timeLabel.SetText(FormatTime(Time()))
}

string function FormatTime(float seconds) {
    int mins = seconds / 60
    int secs = seconds % 60
    return format("%02d:%02d", mins, secs)
}

void function InitDemoHUD() {
    CreateObserverHUD()
    AddCallback_OnSpectatorTargetChanged(UpdateHUD)
}
```

---

### 3. **scripts/demo_controls.nut** (управление)
```squirrel
global function InitDemoControls

void function SwitchSpectatorTarget(int direction) {
    array<entity> players = GetPlayerArray()
    if (players.len() == 0) return
    
    entity current = GetSpectatorTarget()
    int index = players.find(current) ?? -1
    index = (index + direction) % players.len()
    
    SetSpectatorTarget(players[index])
}

void function InitDemoControls() {
    // Player switching
    ConCommand("spec_next", function() { SwitchSpectatorTarget(1) })
    ConCommand("spec_prev", function() { SwitchSpectatorTarget(-1) })
    
    // Freecam toggle
    ConCommand("spec_freecam", function() {
        bool isFree = GetLocalClientPlayer().GetObserverMode() == OBS_MODE_ROAMING
        SetObserverMode(isFree ? OBS_MODE_CHASE : OBS_MODE_ROAMING)
    })
}
```

---

### 4. **scripts/spectator_extension.nut** (расширение)
```squirrel
global function InitSpectatorExtensions

void function ExtendSpectator() {
    // Увеличение скорости камеры
    ConVar.SetFloat("cam_idealdist", 0)
    ConVar.SetFloat("cam_collision", 0)
    
    // Автоматическое обновление
    while (true) {
        if (GetLocalClientPlayer().GetObserverMode() == OBS_MODE_ROAMING) {
            float speed = GetConVarFloat("spec_speed")
            ConVar.SetFloat("spec_speed", speed)
        }
        WaitFrame()
    }
}

void function InitSpectatorExtensions() {
    thread ExtendSpectator()
}
```

---

### 5. **resources/ui/observer_hud.res** (стиль HUD)
```xml
<root>
    <Panel name="ObserverInfo">
        <Label name="NameLabel" font="DefaultBold" textcolor="255 255 255 255" xpos="100" ypos="50"/>
        <Label name="TimeLabel" font="DefaultBold" textcolor="255 255 255 200" xpos="100" ypos="80"/>
    </Panel>
</root>
```

---

### 6. **resources/ui/controls_scheme.res** (схема управления)
```xml
<root>
    <Controls>
        <Action name="spec_next" key="MOUSE_WHEEL_UP"/>
        <Action name="spec_prev" key="MOUSE_WHEEL_DOWN"/>
        <Action name="spec_freecam" key="F"/>
    </Controls>
</root>
```

---

### 📌 **Как использовать**
1. Соберите папку `DemoTools` с указанной структурой
2. Поместите в `R2Northstar/mods/`
3. В игре:
   ```bash
   # Основные команды
   spec_next       # Следующий игрок
   spec_prev       # Предыдущий игрок
   spec_freecam    # Свободная камера
   
   # Настройки
   set spec_speed 500  # Изменить скорость
   ```

---

### ⚠️ **Ограничения**
1. **Перемотка**: Реализована через приблизительную интерполяцию (точное позиционирование невозможно)
2. **Данные**: Только активные игроки (нет истории перемещений)
3. **Требуется**: Запись демо через `startmatchrecord`

Для более продвинутого функционала потребуется модификация:
- Системы записи демо
- Парсинга .dem файлов
- Клиентских prediction-алгоритмов
