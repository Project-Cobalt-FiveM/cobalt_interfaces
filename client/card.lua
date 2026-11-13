local nui <const> = require 'client.nui'

local Card <const> = {}

local open = false

---@param card CardData fields read on the server by cobalt_core
---@param photo? string nui-img URL of the holder's headshot
function Card.show(card, photo)
    open = true
    nui.send('cardShow', {
        style = card.style,
        kind = card.kind,
        citizenid = card.citizenid,
        firstname = card.firstname,
        lastname = card.lastname,
        birthdate = card.birthdate,
        gender = card.gender,
        nationality = card.nationality,
        issued = card.issued,
        grantedBy = card.grantedBy,
        photo = photo,
    })
end

function Card.hide()
    if not open then return end

    open = false
    nui.send('cardHide')
end

return Card
