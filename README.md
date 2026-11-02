# Z-City Frost

Рабочий проект зимней survival-карты и связанных addon'ов для Garry's Mod / Z-City.

## Структура

- `map/gm_zcity_frost.vmf` — исходник карты для Hammer.
- `addons/zcity_frost_loot/` — серверный addon с loot-контейнерами.
- `addons/zcity_frost_cold/` — система холода, обогрева и респавна у последнего огня.
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

Пересоздать лут:

`zc_frost_loot_respawn`

## Cold system

Папку:

`addons/zcity_frost_cold`

нужно ставить в:

`garrysmod/addons/`

Логика по умолчанию:

- шкала холода 0–100;
- на улице 0→100 примерно за 8 минут без тёплой одежды;
- в помещении — примерно за 25 минут;
- одежда Z-City с `WarmSave` замедляет замерзание;
- активный огонь уменьшает шкалу;
- после 100% даётся 120 секунд, в течение которых игрок ещё может двигаться и искать тепло;
- если согреться и опустить шкалу ниже 95%, критическая стадия отменяется;
- после 120 секунд начинается короткая фаза засыпания;
- смерть от холода возвращает игрока к последнему зарегистрированному источнику огня.

Основные настройки:

`zc_frost_cold_outdoor_time 480`

`zc_frost_cold_indoor_time 1500`

`zc_frost_cold_grace_time 120`

`zc_frost_cold_sleep_time 12`

`zc_frost_cold_heat_recovery 1.75`

`zc_frost_cold_heat_radius 300`

`zc_frost_cold_checkpoint_time 12`

Быстрый тест:

`zc_frost_cold_set 100`
