Z-City Frost Cold System

Установка:
garrysmod/addons/zcity_frost_cold/

Поведение:
- отдельная шкала холода 0-100;
- на улице мёрзнешь быстрее, в зданиях медленнее;
- одежда Z-City с WarmSave реально замедляет замерзание;
- env_fire, vfire и зарегистрированные источники тепла согревают;
- после 100% начинается 120-секундное окно, в котором игрок ещё функционирует;
- если за это время согреться и опустить шкалу ниже 95%, критическая стадия отменяется;
- затем начинается короткая фаза засыпания и смерть;
- после смерти от холода игрок возвращается к последнему зарегистрированному огню;
- огонь становится checkpoint после непрерывного обогрева рядом с ним.

Основные cvar:
zc_frost_cold_outdoor_time 480
zc_frost_cold_indoor_time 1500
zc_frost_cold_grace_time 120
zc_frost_cold_sleep_time 12
zc_frost_cold_heat_recovery 1.75
zc_frost_cold_heat_radius 300
zc_frost_cold_checkpoint_time 12

Тест:
zc_frost_cold_set 100
zc_frost_checkpoint_here

API для будущего campfire/stove addon:
ZCFrost.RegisterHeatSource(entity, power, owner, checkpointEligible)
ZCFrost.SetCheckpoint(player, position, angle, sourceEntity)
