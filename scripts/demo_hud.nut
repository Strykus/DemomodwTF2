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
