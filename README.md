# Bag-of-Tricks
A basic cards game imitating the "wizard" card game

the basic structure is this:
The card deck consists of cards in four colors (1-13), 4 black nils and 4 black jokers.
Each round the players get one more card, plus one card is dealt to determine the trump color. (1. round: one card, 2. round: two cards, ...)
The players have to decide how many of the possible tricks they can get.
to win a trick you have to have the highest card, with the first card played determining the suite to follow.
Black (nil and jokers) cards can be played any time.
If you have the coor of th suite, you have to follow, or play a black card.
If you don't have the color, you can play any card, including black or trump cards.
At the end of each round the estimated number of trcks is compared to the actual number of tricks and the players who've judged the number correctly get 20 points, plus 10 points for each trick.
If the estimated number of tricks is not equal to the actual number, the plauyer gets -10 points per trick difference.
