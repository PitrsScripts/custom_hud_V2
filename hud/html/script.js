window.addEventListener('message', function (event) {
    if (event.data.type === "toggleHUD") {
        const hud = document.getElementById('hud');
        const micIcon = document.querySelector('.mic-icon');

        if (event.data.visible) {
            hud.style.visibility = 'visible';
            hud.style.opacity = '1';
            if (micIcon) {
                micIcon.style.visibility = 'visible';
                micIcon.style.opacity = '1';
            }
        } else {
            hud.style.visibility = 'hidden';
            hud.style.opacity = '0';
            if (micIcon) {
                micIcon.style.visibility = 'hidden';
                micIcon.style.opacity = '0';
            }
        }
    }

    if (event.data.type === "toggleHUDIcons") {
        const hud = document.getElementById('hud');
        const micIcon = document.querySelector('.mic-icon');
        const compassBar = document.querySelector('.bar.compass');
        const locationBar = document.querySelector('.bar.location');
        const minimapInfo = document.getElementById('minimap-info');

        if (event.data.visible) {
            if (hud) {
                hud.style.visibility = 'visible';
                hud.style.opacity = '1';
            }
            if (micIcon) {
                micIcon.style.visibility = 'visible';
                micIcon.style.opacity = '1';
            }
            if (compassBar) {
                compassBar.style.visibility = 'visible';
                compassBar.style.opacity = '1';
            }
            if (locationBar) {
                locationBar.style.visibility = 'visible';
                locationBar.style.opacity = '1';
            }
            if (minimapInfo) {
                minimapInfo.style.visibility = 'visible';
                minimapInfo.style.opacity = '1';
            }
        } else {
            if (hud) {
                hud.style.visibility = 'hidden';
                hud.style.opacity = '0';
            }
            if (micIcon) {
                micIcon.style.visibility = 'hidden';
                micIcon.style.opacity = '0';
            }
            if (compassBar) {
                compassBar.style.visibility = 'hidden';
                compassBar.style.opacity = '0';
            }
            if (locationBar) {
                locationBar.style.visibility = 'hidden';
                locationBar.style.opacity = '0';
            }
            if (minimapInfo) {
                minimapInfo.style.visibility = 'hidden';
                minimapInfo.style.opacity = '0';
            }
        }
    }

    if (event.data.type === "updateHUD") {
        const healthElement = document.getElementById('health');
        const hungerElement = document.getElementById('hunger');
        const thirstElement = document.getElementById('thirst');
        const staminaElement = document.getElementById('stamina');
        const oxygenElement = document.getElementById('oxygen');
        const staminaBar = document.querySelector('.bar.stamina');
        const oxygenBar = document.querySelector('.bar.oxygen');
        const micBar = document.querySelector('.bar.mic');
        const compassBar = document.querySelector('.bar.compass');
        const locationBar = document.querySelector('.bar.location');
        const directionElement = document.getElementById('direction');
        const staminaValue = Math.round(event.data.stamina);
        const healthValue = Math.round(event.data.health);
        const hungerValue = Math.round(event.data.hunger);
        const thirstValue = Math.round(event.data.thirst);
        const oxygenValue = Math.round(event.data.oxygen !== undefined ? event.data.oxygen : 100);

        if (healthElement) healthElement.textContent = `${healthValue}%`;
        if (hungerElement) hungerElement.textContent = `${hungerValue}%`; 
        if (thirstElement) thirstElement.textContent = `${thirstValue}%`;
        if (staminaElement) staminaElement.textContent = `${staminaValue}%`;
        if (oxygenElement) oxygenElement.textContent = `${oxygenValue}%`;

        updateProgressCircle('health', healthValue, '#7a0000');
        updateProgressCircle('hunger', hungerValue, '#fced6a');
        updateProgressCircle('thirst', thirstValue, '#74C0FC');
        updateProgressCircle('stamina', staminaValue, '#a4ff3b');
        updateProgressCircle('oxygen', oxygenValue, '#00bfff');

        if (event.data.armor > 0) {
            document.querySelector('.armor').style.display = 'flex';
            document.getElementById('armor').textContent = `${event.data.armor}%`;
            updateProgressCircle('armor', event.data.armor, '#002966');
        } else {
            document.querySelector('.armor').style.display = 'none';
        }


        if (event.data.isUnderwater || (oxygenValue < 100 && oxygenValue > 0)) {
            oxygenBar.style.display = 'flex';
        } else {
            oxygenBar.style.display = 'none';
        }

        updateMicIndicator(event.data.isMicActive, event.data.micMode);
        micBar.style.display = 'flex';

        if (event.data.isInVehicle) {
            staminaBar.style.display = 'none';

            setVehicleHUDPosition(); 
            setVehicleMicPosition();
            setVehicleCompassPosition();  
            setVehicleLocationPosition(); 
            showMinimapInfo();

            updateMinimapInfo(event.data.street, event.data.area, event.data.direction);
        } else {
            staminaBar.style.display = 'flex';
            resetHUDPosition();  
            resetMicPosition();  
            resetCompassPosition();  
            resetLocationPosition(); 
            hideMinimapInfo();
        }

        const compassDirectionElement = document.getElementById('compass-direction');
        if (compassDirectionElement) {
            const directionText = event.data.direction;
            compassDirectionElement.textContent = directionText;
        }
    }
});


function updateProgressCircle(elementType, value, color) {
    const icon = document.querySelector(`.${elementType}-icon`);
    if (icon) {
        icon.style.setProperty('--progress', `${value}%`);
        icon.style.setProperty('--progress-color', color);
    }
}


function updateLocation(locationName) {
    const locationElement = document.getElementById('location');

    if (locationElement) {
        locationElement.textContent = locationName;
    }
}


function updateDirection(directionText) {
    const directionElement = document.getElementById('direction');
    const directionIcon = document.querySelector('.direction-icon i');

    if (directionElement) {
        directionElement.textContent = directionText;
    }

    if (directionIcon) {
        directionIcon.className = getDirectionIcon(directionText);
    }
}


function getDirectionIcon(direction) {
    switch(direction) {
        case 'Sever':
            return 'fa-solid fa-arrow-up fa-sm';
        case 'Severovýchod':
            return 'fa-solid fa-arrow-up-right fa-sm';
        case 'Východ':
            return 'fa-solid fa-arrow-right fa-sm';
        case 'Jihovýchod':
            return 'fa-solid fa-arrow-down-right fa-sm';
        case 'Jih':
            return 'fa-solid fa-arrow-down fa-sm';
        case 'Jihozápad':
            return 'fa-solid fa-arrow-down-left fa-sm';
        case 'Západ':
            return 'fa-solid fa-arrow-left fa-sm';
        case 'Severozápad':
            return 'fa-solid fa-arrow-up-left fa-sm';
        default:
            return 'fa-solid fa-arrow-up fa-sm';
    }
}


function setCompassPosition(x, y) {
    const compassElement = document.querySelector('.bar.compass .icon');
    if (compassElement) {
        compassElement.style.position = 'absolute';
        compassElement.style.left = `${x}px`;
        compassElement.style.top = `${y}px`;
    }
}


function setCompassTextPosition(x, y) {
    const compassTextElement = document.getElementById('compass');
    if (compassTextElement) {
        compassTextElement.style.left = `${x}px`;
        compassTextElement.style.top = `${y}px`;
    }
}

function setLocationPosition(x, y) {
    const locationElement = document.querySelector('.bar.location');
    if (locationElement) {
        locationElement.style.position = 'absolute';
        locationElement.style.left = `${x}px`;
        locationElement.style.top = `${y}px`;
    }
}

function setVehicleHUDPosition() {
    const hud = document.getElementById('hud');
    if (hud) {
        hud.style.transform = 'translate(320px, -32px)';
    }
}

function resetHUDPosition() {
    const hud = document.getElementById('hud');
    if (hud) {
        hud.style.transform = 'none'; 
    }
}

function setVehicleMicPosition() {
    const micIcon = document.querySelector('.mic-icon');
    if (micIcon) {
        micIcon.style.transform = 'translateX(150%)';
        micIcon.style.left = '-95px';
        micIcon.style.bottom = '50px'; 
    }
}

function resetMicPosition() {
    const micIcon = document.querySelector('.mic-icon');
    if (micIcon) {
        micIcon.style.transform = 'none';  
        micIcon.style.left = '15px'; 
        micIcon.style.bottom = '70px';  
    }
}


function setVehicleArmorHungerThirstPosition() {
    const hungerBar = document.querySelector('.bar.hunger');
    const thirstBar = document.querySelector('.bar.thirst');

    if (hungerBar) {
        hungerBar.style.transform = 'translateX(8px)'; 
    }

    if (thirstBar) {
        thirstBar.style.transform = 'translateX(8px)'; 
    }
}

function resetVehicleArmorHungerThirstPosition() {
    const hungerBar = document.querySelector('.bar.hunger');
    const thirstBar = document.querySelector('.bar.thirst');

    if (hungerBar) {
        hungerBar.style.transform = 'none';
    }

    if (thirstBar) {
        thirstBar.style.transform = 'none';
    }
}


function resetAllTransforms() {
    const hungerBar = document.querySelector('.bar.hunger');
    const thirstBar = document.querySelector('.bar.thirst');
    const hud = document.getElementById('hud');
    const compassBar = document.querySelector('.bar.compass');
    const locationBar = document.querySelector('.bar.location');
    if (hungerBar) {
        hungerBar.style.transform = 'none';
    }
    if (thirstBar) {
        thirstBar.style.transform = 'none';
    }
    if (hud) {
        hud.style.transform = 'none';
    }
    if (compassBar) {
        compassBar.style.transform = 'none';
    }
    if (locationBar) {
        locationBar.style.transform = 'none';
    }
}



function setVehicleCompassPosition() {
    const compass = document.getElementById('compass');
    if (compass) {
        compass.style.setProperty('transform', 'translate(-37px, 15px)', 'important');
    }
}

function setVehicleCompassTextPosition() {
    const directionContainer = document.querySelector('.direction-container');
    if (directionContainer) {
        directionContainer.style.position = 'relative';
        directionContainer.style.transform = 'none';
        directionContainer.style.marginLeft = '10px';
        directionContainer.style.marginTop = '5px';
    }
}

function resetCompassPosition() {
    const compass = document.getElementById('compass');
    if (compass) {
        compass.style.transform = 'none';
    }
}

function resetCompassTextPosition() {
    const directionContainer = document.querySelector('.direction-container');
    if (directionContainer) {
        directionContainer.style.position = 'relative';
        directionContainer.style.transform = 'none';
        directionContainer.style.marginLeft = '8px';
        directionContainer.style.marginTop = '0';
    }
}

function setVehicleLocationPosition() {
    const location = document.getElementById('location');
    if (location) {
        location.style.setProperty('transform', 'translate(-37px, 15px)', 'important');
    }
}

function resetLocationPosition() {
    const location = document.getElementById('location');
    if (location) {
        location.style.transform = 'none';
    }
}


function showMinimapInfo() {
    const locationCompassWrapper = document.getElementById('location-compass-wrapper');
    if (locationCompassWrapper) {
        locationCompassWrapper.style.display = 'flex';
    }
}

function hideMinimapInfo() {
    const locationCompassWrapper = document.getElementById('location-compass-wrapper');
    if (locationCompassWrapper) {
        locationCompassWrapper.style.display = 'none';
    }
}

function updateMinimapInfo(streetName, areaName, direction) {
    const streetElement = document.getElementById('street-name');
    const areaElement = document.getElementById('area-name');
    const directionElement = document.getElementById('compass-direction');

    if (streetElement) {
        streetElement.textContent = streetName || 'Neznámá ulice';
    }

    if (areaElement) {
        areaElement.textContent = areaName || 'Neznámá oblast';
    }

    if (directionElement) {
        directionElement.textContent = direction || 'Sever';
    }
}


function updateMicIndicator(isMicActive, micMode) {
    const micIcon = document.querySelector('.mic-icon');
    if (micIcon) {
        micIcon.classList.remove('mic-active', 'mic-whisper', 'mic-normal', 'mic-shouting');
        if (isMicActive) {
            micIcon.classList.add('mic-active');
        }
        if (micMode === 'whisper') {
            micIcon.classList.add('mic-whisper');
        } else if (micMode === 'normal') {
            micIcon.classList.add('mic-normal');
        } else if (micMode === 'shouting') {
            micIcon.classList.add('mic-shouting');
        }
    }
}

window.addEventListener('message', function(event) {
    if (event.data.type === "updateHUD") {
        updateMicIndicator(event.data.isMicActive, event.data.micMode);
    }
});