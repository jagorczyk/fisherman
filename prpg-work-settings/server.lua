showWorkingGui = function(player, bool)
    triggerClientEvent(player, "settings->showGui", resourceRoot, bool)
end

setMoney = function(player, money)
    triggerClientEvent(player, "settings->setMoney", resourceRoot, money)
end

setTitle = function(player, title)
    triggerClientEvent(player, "settings->setTitle", resourceRoot, title)
end

setText = function(player, text)
    triggerClientEvent(player, "settings->setText", resourceRoot, text)
end

addMoney = function(player, money)
    triggerClientEvent(player, "settings->addMoney", resourceRoot, money)
end