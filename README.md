# Z-City Frost

Рабочий проект зимней survival-карты и связанного loot-addon для Garry's Mod / Z-City.

## Структура

- `map/gm_zcity_frost.vmf` — исходник карты для Hammer.
- `addons/zcity_frost_loot/` — серверный addon с loot-контейнерами.
- `.github/workflows/unpack-map.yml` — служебный workflow для обновления большой VMF-карты.

## Версии

Файлы имеют постоянные имена. История версий хранится в Git commits, поэтому больше не нужны имена вроде `v4`, `final`, `rework`.

## Карта

Открой:

`map/gm_zcity_frost.vmf`

в Hammer и компилируй как:

`gm_zcity_frost.bsp`

Для теста Z-City запускай игру минимум на 2 players, а не Singleplayer.

## Loot addon

Папку:

`addons/zcity_frost_loot`

нужно ставить в:

`garrysmod/addons/`

Контейнеры используют нативный `zbox_lootbox` Z-City и модели:

- `models/props_junk/wood_crate002a.mdl`
- `models/props_junk/wood_crate001a_damaged.mdl`
- `models/props_junk/wood_crate001a.mdl`
- `models/props_c17/FurnitureDresser001a.mdl`

Пересоздать лут:

`zc_frost_loot_respawn`
