FireRate = 1 --Темп огня
MagazineCapacity = 1 --Вместительность магазина
WeaponState = 0 --Состояние оружия
Ammo = 0 --Количество патронов к этому оружию
AmmoInWeapon = 0 --Патроны в магазине оружия

---------CONST------------
_green = {0.71, 1, 0.71}
_yellow = {1, 0.82, 0.47}
_red = {1, 0.55, 0.55}
_crash = {1, 0.35, 0.35}

soundAssets = {
    ["Выстрел"] = 0,
    ["Выстрел_Глушитель"] = 1,
    ["Клин"] = 2,
    ["Перезарядка"] = 3,
}
--------CONST-----------

function updateSave()
    saved_data = JSON.encode({
        ["ammo"] = Ammo, 
        ["weaponState"] = WeaponState,
        ["ammoInWeapon"] = AmmoInWeapon 
    })
    if disableSave==true then saved_data="" end
    self.script_state = saved_data
end

function onload(saved_data)
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        WeaponState = loaded_data.weaponState
        Ammo = loaded_data.ammo
        AmmoInWeapon = loaded_data.ammoInWeapon
        printToAll(AmmoInWeapon)
    else
        FireRate = 1 --Темп огня
        WeaponState = 0 --Состояние оружия
        Ammo = 0 --Количество патронов к этому оружию
        AmmoInWeapon = 0 --Патроны в магазине оружия
    end
    MagazineCapacity = self.getGMNotes("")
    Wait.frames(adjustUISize, 10)
    updateButtonText("AmmoButton", Ammo)
    updateButtonText("ShootButton", AmmoInWeapon)
end

----UI----

function adjustUISize()
    local tokenWidth = self.getBoundsNormalized().size.x
    local adjustedWidth = 250 -- Ширина для трёхслотового оружия
        printToAll(tokenWidth)
    
    if tokenWidth < 5 then
        adjustedWidth = (250/2)+30 -- Ширина для двухслотового оружия
    end
    if tokenWidth < 2 then
        adjustedWidth = (250/3) -- Ширина для оружия на 1 слот
    end

    self.UI.setAttribute("ButtonsPanel", "width", adjustedWidth)
end

function updateButtonActivity(buttonName, isActive)
    self.UI.setAttribute(buttonName, "active", isActive)
    self.UI.setAttribute(buttonName, "textColor", "rgb(1,1,1)")
end

function updateButtonText(buttonName, valueStr)
    self.UI.setAttribute(buttonName, "text", valueStr)
    self.UI.setAttribute(buttonName, "textColor", "rgb(1,1,1)")
end

----WEAPON LOGIC----

function fixWeapon(player, param, id)
    local Name = self.getName("")
    if Player[player.color].admin then
        WeaponState = 0
        self.setColorTint({1,1,1})
        updateButtonActivity("FixButton", false)
        printToAll(Name .. ': - [84BEFF]Восстановлен[-]')
    else
        printToAll(Name .. ': - [FFFF96]Состояние[-]\n[[B4FFB4]Лёгкий износ[-]] - [FFFF96]Требуется[-] - [99ff33]«Набор для чистки оружия»[-]\n[[FFFF96]Средний износ[-]] - [FFFF96]Требуется[-] - [33ccff]«Оружейные детали»[-] и [99ff33]«Набор для чистки оружия»[-]\n[[FFA0A0]Тяжелый износ[-]] - [FFFF96]Требуется[-] - [99ff33]«Инструменты для грубой работы»[-] и [33ccff]«Оружейные детали»[-] + [99ff33]«Набор для чистки оружия»[-]')
    end
end

function changeWeaponState(player, param, id)
    local Name = self.getName("")
    
    updateButtonActivity("FixButton", true)
    
    if WeaponState == 0 then
            WeaponState = WeaponState + 1
            self.setColorTint(_green)
            printToAll(Name .. ': - [B4FFB4]Лёгкий износ[-]')
    elseif WeaponState == 1 then
            WeaponState = WeaponState + 1
            self.setColorTint(_yellow)
            printToAll(Name .. ': - [FFFF96]Средний износ[-]')
    elseif WeaponState == 2 then
            WeaponState = WeaponState + 1
            self.setColorTint(_red)
            printToAll(Name .. ': - [FFA0A0]Тяжелый износ[-]')
    elseif WeaponState == 3 then
            WeaponState = WeaponState + 1
            self.setColorTint(_crash)
            printToAll(Name .. ': - [FF6464]Испорчен[-]')
    end
end

function Reload()
    MagazineCapacity = tonumber(self.getGMNotes(""))
    if AmmoInWeapon == MagazineCapacity then
    elseif Ammo == 0 then
        printToAll('[FFA0A0]Нет боеприпасов для перезарядки![-]')
    else
        local Name = self.getName("")
        
        printToAll('[84BEFF]Перезарядка[-] - ' .. Name)
        printToAll(Name .. ': - [FFFF96]Использован[-] - «Магазин '.. Name ..'»')
        
        local bulletsToAdd = (AmmoInWeapon - MagazineCapacity) * -1
        AmmoInWeapon = AmmoInWeapon + math.min(Ammo, bulletsToAdd) 
        Ammo = math.max(Ammo-bulletsToAdd, 0)
        
        self.AssetBundle.playTriggerEffect(soundAssets["Перезарядка"])
        
        updateButtonText("AmmoButton", tostring(Ammo))
        updateButtonText("ShootButton", tostring(AmmoInWeapon))
    end
end

function changeValue(player, param, id)
    local step = 10
    if promote == true then
        if Player[player.color].admin == false then
            return
        end
    end
    --On rightclick
    if param == "-2" then
        if Ammo >= step then
            Ammo = Ammo - step
        else
            Ammo = 0
        end
    else
        Ammo = Ammo + step
    end
    updateButtonText("AmmoButton", Ammo)
end

function isWeaponBroken()
    local roll = math.random(0,100)
    local wedgeProbability = 0

    if WeaponState >= 4 then
        wedgeProbability = 100 --100% wedge chance
    elseif WeaponState == 3 then
        wedgeProbability = 45 --45% wedge chance
    elseif WeaponState == 2 then
        wedgeProbability = 25 --25% wedge chance
    elseif WeaponState == 1 then
        wedgeProbability = 15 --15% wedge chance
    elseif WeaponState == 0 then
        wedgeProbability = 5 --5% wedge chance
    end

    if wedgeProbability > roll then
        return true
    else
        return false
    end
end

function hasAmmo(ammoCount)
    if type(ammoCount) == "number" then
        if ammoCount > 0 then
            return true
        end
        return false
    end
end

-- Function returns amount of bullets that stayed in weapon magazine
function Shoot(ammoAmount, fireRate)
    if fireRate >= ammoAmount then
        return 0
    end
    return ammoAmount-fireRate
end

function tryShoot(player, param, id)
    local GMNotes = self.getGMNotes("")
    local Name = self.getName("")
    
    if isWeaponBroken() then
        self.AssetBundle.playTriggerEffect(soundAssets["Клин"])
        printToAll(Name .. ' - [FFA0A0]Заклинил[-]')
    else
        if hasAmmo(AmmoInWeapon) then
            self.AssetBundle.playTriggerEffect(soundAssets["Выстрел"])
            printToAll(Player[player.color].steam_name .. ': - [FFFF96]Стреляет[-] - '  .. Name)
            local ammoLeft = Shoot(AmmoInWeapon, FireRate)
            AmmoInWeapon = ammoLeft
            updateButtonText("ShootButton", ammoLeft)
        else            
            self.AssetBundle.playTriggerEffect(soundAssets["Клин"])
            printToAll(Name .. ' - [FFA0A0]Нет боеприпасов![-]')
        end
    end
end
