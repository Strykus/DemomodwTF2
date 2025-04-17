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
