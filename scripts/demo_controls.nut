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
