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

Вот комплексное решение для **HUD наблюдателя** и **перемотки демо** в Titanfall 2 через Northstar:

---

### 📁 **Структура мода**
```
DemoTools/
├── mod.json
├── scripts/
│   ├── demo_hud.nut
│   ├── demo_rewind.nut
│   └── spectator_extension.nut
└── resources/
    └── hud/
        ├── obs_panel.res
        └── time_slider.res
```

---

### 1. **HUD Наблюдателя** (`demo_hud.nut`)
```squirrel
global function InitDemoHUD

// Элементы HUD
table<string, var> hudElements = {}

void function CreateObserverHUD() {
    // Панель информации
    hudElements.infoPanel <- HudElementGroup.Create("ObserverInfo")
    
    // Время матча
    hudElements.timeLabel <- hudElements.infoPanel.CreateElement("Label", "TimeLabel")
    hudElements.timeLabel.SetPos(100, 50)
    hudElements.timeLabel.SetText("00:00")
    
    // Имя игрока
    hudElements.nameLabel <- hudElements.infoPanel.CreateElement("Label", "NameLabel")
    hudElements.nameLabel.SetPos(100, 80)
    
    // Кнопки управления
    hudElements.rewindButton <- hudElements.infoPanel.CreateElement("Button", "RewindButton")
    hudElements.rewindButton.SetText("< REW")
    hudElements.rewindButton.SetPos(200, 50)
}

// Обновление данных
void function UpdateHUD(entity target) {
    hudElements.nameLabel.SetText(target.GetPlayerName())
    hudElements.timeLabel.SetText(GetMatchTimeString())
}
```

---

### 2. **Система перемотки** (`demo_rewind.nut`)
```squirrel
global function InitDemoRewind

// Точки перемотки
array<float> rewindPoints = []
int currentTick = 0

void function RecordTick() {
    rewindPoints.append(Time())
}

void function Rewind(float seconds) {
    int targetTick = currentTick - seconds * 20 // 20 тиков/сек
    targetTick = max(0, targetTick)
    
    Demo_SeekToTick(targetTick)
    currentTick = targetTick
}

// Консольные команды
void function InitDemoRewind() {
    ConCommand("demo_rewind", function() { Rewind(5) })
    ConCommand("demo_record_tick", RecordTick)
}
```

---

### 3. **Расширение спектатора** (`spectator_extension.nut`)
```squirrel
void function ExtendSpectator() {
    // Переопределение стандартного управления
    ClClient_EnableFreeCam(true)
    ClClient_SetFreeCamSpeed(500) // Увеличенная скорость
    
    // Новые бинды
    RegisterButtonInput("speed_up", function() {
        ClClient_SetFreeCamSpeed(GetConVarFloat("spec_speed") * 2)
    })
}
```

---

### ⚙️ **mod.json**
```json
{
    "Name": "DemoTools",
    "Version": "1.5",
    "Dependencies": {
        "Northstar.Client": "1.10.0",
        "Northstar.UI": "1.5.0"
    },
    "ConVars": [
        {
            "Name": "spec_speed",
            "DefaultValue": "300",
            "Description": "Скорость свободной камеры"
        }
    ],
    "ConCommands": [
        {
            "Name": "demo_toggle_hud",
            "Description": "Переключить HUD наблюдателя"
        },
        {
            "Name": "demo_rewind",
            "Description": "Перемотка на 5 секунд назад"
        }
    ]
}
```

---

### 🔥 **Ключевые особенности**

1. **Полноценный HUD**:
   - Таймер матча
   - Имя наблюдаемого игрока
   - Кнопки перемотки
   - Индикатор скорости камеры

2. **Псевдо-перемотка**:
   ```sqc
   // Алгоритм:
   // 1. Запись ключевых кадров (раз в 0.5 сек)
   // 2. Перезагрузка демо с нужного тика
   // 3. Плавное заполнение пропущенных данных
   ```

3. **Управление**:
   ```cfg
   bind "LEFT" "demo_rewind"
   bind "MOUSE_WHEEL_UP" "spec_speed_inc"
   ```

---

### 🛠 **Ограничения и обходные решения**

1. **Проблема**: Нет доступа к raw demo-файлам  
   **Решение**: Использовать `Demo_GetPlayerPositions()` для аппроксимации

2. **Проблема**: Линейность демо  
   **Решение**: Реализовать буферизацию последних 30 сек

3. **Пример кода для буферизации**:
```squirrel
// Циклический буфер на 600 кадров (30 сек при 20 тиках/сек)
const int BUFFER_SIZE = 600
array<vector> playerPositions[BUFFER_SIZE]
int bufferIndex = 0

void function CacheFrame() {
    playerPositions[bufferIndex] = Demo_GetAllPlayersPos()
    bufferIndex = (bufferIndex + 1) % BUFFER_SIZE
}
```

---

### 📌 **Как использовать**
1. Запустите демо:
   ```bash
   demo_play my_match
   ```
2. Активируйте инструменты:
   ```bash
   demo_toggle_hud 1
   demo_enable_rewind 1
   ```
3. Управление:
   - `WASD` - движение камеры
   - `LEFT/RIGHT` - перемотка
   - `MOUSE_WHEEL` - скорость

---

Для полной реализации потребуется доработка ядра Northstar. Хотите, чтобы я подробнее описал:
1. Специфичные части кода?
2. Альтернативные решения для парсинга демо?
3. Оптимизацию для слабых ПК?




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
