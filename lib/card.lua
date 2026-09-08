local Card = {cards = {}}

function Card.init(count)
	count = count or 1
	for i=1,4*13 do
		Card.cards[i] = count
	end
	Card.total = 4*13*count
end

function Card.take()
	local select = math.random(1,Card.total)

	for i,v in ipairs(Card.cards) do
		select = select-v
		if select <= 0 then
			Card.cards[i] = Card.cards[i]-1
			Card.total = Card.total-1
			return (i-1)//13+1, (i-1)%13+1
		end
	end
end

return Card
