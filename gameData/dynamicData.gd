extends Node
var playerTradeskillItems={"Simple Sharpening Stone":{"count":0,"name":"Simple Sharpening Stone","icon":"sharpeningStone.png","seen":false,"consumable":false},"Deluxe Sharpening Stone":{"count":0,"name":"Deluxe Sharpening Stone","icon":"deluxeSharpeningStone.png","seen":false,"consumable":false},"Tree Tannin":{"count":0,"name":"Tree Tannin","icon":"treeTannin.png","seen":false,"consumable":true},"Small Hide":{"count":0,"name":"Small Hide","icon":"smallHide.png","seen":false,"consumable":true},"Medium Hide":{"count":0,"name":"Medium Hide","icon":"mediumHide.png","seen":false,"consumable":true},"Large Hide":{"count":0,"name":"Large Hide","icon":"largeHide.png","seen":false,"consumable":true},"Leather Strip":{"count":0,"name":"Leather Strip","icon":"leatherStrip.png","seen":false,"consumable":true},"Leather Swatch":{"count":0,"name":"Leather Swatch","icon":"leatherSwatch.png","seen":false,"consumable":true},"Leather Bolt":{"count":0,"name":"Leather Bolt","icon":"leatherBolt.png","seen":false,"consumable":true},"Leather Padding":{"count":0,"name":"Leather Padding","icon":"leatherBolt.png","seen":false,"consumable":true},"Strong Thread":{"count":0,"name":"Strong Thread","icon":"leatherStrip.png","seen":false,"consumable":true},"Tadloc Hide":{"count":0,"name":"Tadloc Hide","icon":"tadlocHide.png","seen":false,"consumable":true},"Unicorn Mane":{"count":0,"name":"Unicorn Mane","icon":"unicornMane.png","seen":false,"consumable":true},"Unicorn Horn":{"count":0,"name":"Unicorn Horn","icon":"unicornHorn.png","seen":false,"consumable":true},"Rough Stone":{"count":0,"name":"Rough Stone","icon":"roughStone.png","seen":false,"consumable":true},"Small Brick of Ore":{"count":0,"name":"Small Brick of Ore","icon":"smallOre.png","seen":false,"consumable":true},"Rough Diamond":{"count":0,"name":"Rough Diamond","icon":"roughDiamond.png","seen":false,"consumable":true},"Copper Ore":{"count":0,"name":"Copper Ore","icon":"copperOre.png","seen":false,"consumable":true},"Copper Bar":{"count":0,"name":"Copper Bar","icon":"copperBar.png","seen":false,"consumable":true},"Silver Ore":{"count":0,"name":"Silver Ore","icon":"copperOre.png","seen":false,"consumable":true},"Silver Bar":{"count":0,"name":"Silver Bar","icon":"silverBar.png","seen":false,"consumable":true},"Gold Ore":{"count":0,"name":"Gold Ore","icon":"copperOre.png","seen":false,"consumable":true},"Gold Bar":{"count":0,"name":"Gold Bar","icon":"goldBar.png","seen":false,"consumable":true},"Platinum Ore":{"count":0,"name":"Platinum Ore","icon":"copperOre.png","seen":false,"consumable":true},"Platinum Bar":{"count":0,"name":"Platinum Bar","icon":"platinumBar.png","seen":false,"consumable":true},"Ethatrium Ore":{"count":0,"name":"Ethatrium Ore","icon":"copperOre.png","seen":false,"consumable":true},"Ethatrium Bar":{"count":0,"name":"Ethatrium Bar","icon":"ethatriumBar.png","seen":false,"consumable":true},"Topaz":{"count":0,"name":"Topaz","icon":"topaz.png","seen":false,"consumable":true},"Pearl":{"count":0,"name":"Pearl","icon":"pearl.png","seen":false,"consumable":true},"Peridot":{"count":0,"name":"Peridot","icon":"peridot.png","seen":false,"consumable":true},"Sapphire":{"count":0,"name":"Sapphire","icon":"sapphire.png","seen":false,"consumable":true},"Diamond":{"count":0,"name":"Diamond","icon":"peridot.png","seen":false,"consumable":true},"Garnet":{"count":0,"name":"Garnet","icon":"peridot.png","seen":false,"consumable":true},"Emerald":{"count":0,"name":"Emerald","icon":"peridot.png","seen":false,"consumable":true},"Alexandrite":{"count":0,"name":"Alexandrite","icon":"alexandrite.png","seen":false,"consumable":true},"Hessonite":{"count":0,"name":"Hessonite","icon":"hessonite.png","seen":false,"consumable":true},"Taaffeite":{"count":0,"name":"Taaffeite","icon":"copperBar.png","seen":false,"consumable":true},"Beginner's Arrow":{"count":0,"name":"Beginner's Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Handmade Arrow":{"count":0,"name":"Handmade Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Ash Arrow":{"count":0,"name":"Ash Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Silver Tip Ash Arrow":{"count":0,"name":"Silver Tip Ash Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Cedar Arrow":{"count":0,"name":"Cedar Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Silver Tip Cedar Arrow":{"count":0,"name":"Silver Tip Cedar Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Silentwood Arrow":{"count":0,"name":"Silentwood Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Silver Tip Silentwood Arrow":{"count":0,"name":"Silver Tip Silentwood Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Shadow Oak Arrow":{"count":0,"name":"Shadow Oak Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Silver Tip Shadow Oak Arrow":{"count":0,"name":"Silver Tip Shadow Oak Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Rainwood Arrow":{"count":0,"name":"Rainwood Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Silver Tip Rainwood Arrow":{"count":0,"name":"Silver Tip Rainwood Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Heartpiercer Arrow":{"count":0,"name":"Heartpiercer Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Ethatrium Tip Arrow":{"count":0,"name":"Ethatrium Tip Arrow","icon":"arrow_basic1.png","seen":false,"consumable":false},"Simple Arrowhead":{"count":0,"name":"Simple Arrowhead","icon":"offhand1.png","seen":false,"consumable":true},"Silver Arrowhead":{"count":0,"name":"Silver Arrowhead","icon":"offhand1.png","seen":false,"consumable":true},"Durable Arrowhead":{"count":0,"name":"Durable Arrowhead","icon":"offhand1.png","seen":false,"consumable":true},"Heartpiercer Arrowhead":{"count":0,"name":"Heartpiercer Arrowhead","icon":"offhand1.png","seen":false,"consumable":true},"Ethatrium Arrowhead":{"count":0,"name":"Ethatrium Arrowhead","icon":"offhand1.png","seen":false,"consumable":true},"Cedar Arrow Shaft":{"count":0,"name":"Cedar Arrow Shaft","icon":"offhand1.png","seen":false,"consumable":true},"Ash Arrow Shaft":{"count":0,"name":"Ash Arrow Shaft","icon":"offhand1.png","seen":false,"consumable":true},"Silentwood Arrow Shaft":{"count":0,"name":"Silentwood Arrow Shaft","icon":"offhand1.png","seen":false,"consumable":true},"Shadow Oak Arrow Shaft":{"count":0,"name":"Shadow Oak Arrow Shaft","icon":"offhand1.png","seen":false,"consumable":true},"Rainwood Arrow Shaft":{"count":0,"name":"Rainwood Arrow Shaft","icon":"offhand1.png","seen":false,"consumable":true},"Golden Oak Arrow Shaft":{"count":0,"name":"Golden Oak Arrow Shaft","icon":"offhand1.png","seen":false,"consumable":true},"Grey Feather":{"count":0,"name":"Grey Feather","icon":"offhand1.png","seen":false,"consumable":true},"Old Feather":{"count":0,"name":"Old Feather","icon":"offhand1.png","seen":false,"consumable":true},"Silver Feather":{"count":0,"name":"Silver Feather","icon":"offhand1.png","seen":false,"consumable":true},"Ghostraven Feather":{"count":0,"name":"Ghostraven Feather","icon":"offhand1.png","seen":false,"consumable":true},"Iridescent Feather":{"count":0,"name":"Iridescent Feather","icon":"offhand1.png","seen":false,"consumable":true},"Rough Branch":{"count":0,"name":"Rough Branch","icon":"offhand1.png","seen":false,"consumable":true},"Oak Branch":{"count":0,"name":"Oak Branch","icon":"offhand1.png","seen":false,"consumable":true},"Ash Branch":{"count":0,"name":"Ash Branch","icon":"offhand1.png","seen":false,"consumable":true},"Rainwood Branch":{"count":0,"name":"Rainwood Branch","icon":"offhand1.png","seen":false,"consumable":true},"Golden Oak Branch":{"count":0,"name":"Golden Oak Branch","icon":"offhand1.png","seen":false,"consumable":true},"Silentwood Branch":{"count":0,"name":"Silentwood Branch","icon":"offhand1.png","seen":false,"consumable":true},"Shadow Oak Branch":{"count":0,"name":"Shadow Oak Branch","icon":"offhand1.png","seen":false,"consumable":true},"Cedar Log":{"count":0,"name":"Cedar Log","icon":"offhand1.png","seen":false,"consumable":true},"Ash Log":{"count":0,"name":"Ash Log","icon":"offhand1.png","seen":false,"consumable":true},"Rainwood Log":{"count":0,"name":"Rainwood Log","icon":"offhand1.png","seen":false,"consumable":true},"Golden Oak Log":{"count":0,"name":"Golden Oak Log","icon":"offhand1.png","seen":false,"consumable":true},"Silentwood Log":{"count":0,"name":"Silentwood Log","icon":"offhand1.png","seen":false,"consumable":true},"Shadow Oak Log":{"count":0,"name":"Shadow Oak Log","icon":"offhand1.png","seen":false,"consumable":true},"Hemp Cord":{"count":0,"name":"Hemp Cord","icon":"leatherStrip.png","seen":false,"consumable":true},"Hemp Fiber":{"count":0,"name":"Hemp Fiber","icon":"leatherStrip.png","seen":false,"consumable":true},"Spider Silk Cord":{"count":0,"name":"Spider Silk Cord","icon":"leatherStrip.png","seen":false,"consumable":true},"Hemp Bowstring":{"count":0,"name":"Hemp Bowstring","icon":"leatherStrip.png","seen":false,"consumable":true},"Spider Silk Bowstring":{"count":0,"name":"Spider Silk Bowstring","icon":"leatherStrip.png","seen":false,"consumable":true},"Ethereal Fiber":{"count":0,"name":"Ethereal Fiber","icon":"leatherStrip.png","seen":false,"consumable":true},"Ethereal Cord":{"count":0,"name":"Ethereal Cord","icon":"leatherStrip.png","seen":false,"consumable":true},"Ethereal Bowstring":{"count":0,"name":"Ethereal Bowstring","icon":"leatherStrip.png","seen":false,"consumable":true},"Bat Wing":{"count":0,"name":"Bat Wing","icon":"leatherStrip.png","seen":false,"consumable":true},"Azuricite Ore":{"count":0,"name":"Azuricite Ore","icon":"azuricite_ore.png","seen":false,"consumable":true},"Azuricite Metal":{"count":0,"name":"Azuricite Metal","icon":"azuricite_metal.png","seen":false,"consumable":true},"Gemstone Mount":{"count":0,"name":"Gemstone Mount","icon":"leatherStrip.png","seen":false,"consumable":true},"Hammered Copper Band":{"count":0,"name":"Hammered Copper Band","icon":"leatherStrip.png","seen":false,"consumable":true},"Copper Buttons":{"count":0,"name":"Copper Buttons","icon":"leatherStrip.png","seen":false,"consumable":true},"Copper Chain":{"count":0,"name":"Copper Chain","icon":"leatherStrip.png","seen":false,"consumable":true},"Silver Buttons":{"count":0,"name":"Silver Buttons","icon":"leatherStrip.png","seen":false,"consumable":true},"Silver Chain":{"count":0,"name":"Silver Chain","icon":"leatherStrip.png","seen":false,"consumable":true},"Polished Gold Band":{"count":0,"name":"Polished Gold Band","icon":"leatherStrip.png","seen":false,"consumable":true},"Gold Buttons":{"count":0,"name":"Gold Buttons","icon":"leatherStrip.png","seen":false,"consumable":true},"Gold Chain":{"count":0,"name":"Gold Chain","icon":"leatherStrip.png","seen":false,"consumable":true},"Intricate Platinum Band":{"count":0,"name":"Intricate Platinum Band","icon":"leatherStrip.png","seen":false,"consumable":true},"Platinum Buttons":{"count":0,"name":"Platinum Buttons","icon":"leatherStrip.png","seen":false,"consumable":true},"Platinum Chain":{"count":0,"name":"Platinum Chain","icon":"leatherStrip.png","seen":false,"consumable":true},"Ornate Ethatrium Band":{"count":0,"name":"Ornate Ethatrium Band","icon":"leatherStrip.png","seen":false,"consumable":true},"Ethatrium Buttons":{"count":0,"name":"Ethatrium Buttons","icon":"leatherStrip.png","seen":false,"consumable":true},"Ethatrium Chain":{"count":0,"name":"Ethatrium Chain","icon":"leatherStrip.png","seen":false,"consumable":true},"Simple Metal Bar":{"count":0,"name":"Simple Metal Bar","icon":"leatherStrip.png","seen":false,"consumable":true},"Chrono Dust":{"count":0,"name":"Chrono Dust","icon":"peridot.png","seen":false,"consumable":true},"Spun Spider Silk":{"count":0,"name":"Spun Spider Silk","icon":"leatherStrip.png","seen":false,"consumable":true},"Spider Legs":{"count":0,"name":"Spider Legs","icon":"leatherStrip.png","seen":false,"consumable":true},"Worn Ghostwood":{"count":0,"name":"Worn Ghostwood","icon":"leatherStrip.png","seen":false,"consumable":true},"Pristine Ghostwood":{"count":0,"name":"Pristine Ghostwood","icon":"leatherStrip.png","seen":false,"consumable":true},"Drawknife":{"count":0,"name":"Drawknife","icon":"leatherStrip.png","seen":false,"consumable":false},"Fluffy Fiber":{"count":0,"name":"Fluffy Fiber","icon":"leatherStrip.png","seen":false,"consumable":true},"Soft Cloth Fiber":{"count":0,"name":"Soft Cloth Fiber","icon":"leatherStrip.png","seen":false,"consumable":true},"Soft Cloth Swatch":{"count":0,"name":"Soft Cloth Swatch","icon":"leatherStrip.png","seen":false,"consumable":true},"Comfy Quilt":{"count":0,"name":"Comfy Quilt","icon":"leatherStrip.png","seen":false,"consumable":true}}
var playerQuestItems={"Rat Ear":{"count":0,"name":"Rat Ear","icon":"leatherStrip.png","seen":false,"consumable":false},"Spider Web":{"count":0,"name":"Spider Web","icon":"spiderweb.png","seen":false,"consumable":false},"Rat King Head":{"count":0,"name":"Rat King Head","icon":"leatherStrip.png","seen":false,"consumable":false},"Stillwater Pirate Banner":{"count":0,"name":"Stillwater Pirate Banner","icon":"pirateBanner.png","seen":false,"consumable":false},"Smelly Beard":{"count":0,"name":"Smelly Beard","icon":"leatherStrip.png","seen":false,"consumable":true},"Maree's Finger Bone":{"count":0,"name":"Maree's Finger Bone","icon":"leatherStrip.png","seen":false,"consumable":true}}
