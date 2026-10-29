# Royal Feast

The King's birthday is approaching, and he demands a royal feast. With no supply of food left, the village's chef is sent on a treacherous path to find 5 legendary ingredients, holding nothing but a spatula and dreams of a big bonus. Meeting Ah-ha! Collective’s brief, we created Royal Feast, an adventure puzzle game on the journey of a young chef to find ingredients for the King's feast. 

## Clone and open

Clone using this repository's URL:

```sh
git clone https://github.com/Duc5/Royal-Feast.git Royal-Feast
cd Royal-Feast
```

## Controls

| Action | Input |
| --- | --- |
| Move | WASD |
| Aim | Mouse |
| Attack / reflect | Left click |
| Dodge | Left Shift |
| Jump / hop from an updraft | Space |
| Interact / pick up stone | E |
| Throw stone | Right click |
| Optional hint | H |
| Journal | J |
| Map | M |
| Pause | Escape |

## Project structure

| Directory | Contents |
| --- | --- |
| `scenes/` | Main scene, player, regions, actors, objects, and UI |
| `scripts/` | Movement, combat, interactions, puzzles, world state, and UI logic |
| `data/` | dialogue |
| `assets/` | Runtime assets, custom artwork, and source-asset licences |

The entry scene is `scenes/main.tscn`. Region maps are editable scenes under `scenes/regions/` and use 16×16 TileMapLayers.


## Credits

Artwork, pixel font, music, and selected sounds: **Ninja Adventure by Pixel-boy & AAA**.

## Puzzle solution
Riverwood Forest: Left click the tree near the river 3 times to create a bridge, walk over the other side of the river to gather the Dewcrown mushroom
Whispering Peak: Pick up rocks near the valley, right click them to throw, after some trial and error you will find some wind regions that levitate the rock up, jump between those regions to get to the other side
Emberwood Forge: You must use the spatula to reflect fireballs and redirect it to hit all 3 of the furnace switches, once all 3 have recieved a fireball, the gate will open to collect the Cinderheart pepper 
