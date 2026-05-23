# Marvel Survivors — Documento de Desarrollo

**Materia:** Programación Avanzada — UDA  
**Alumno:** Jorge Tohme  
**Género:** Horde Survivor (estilo Vampire Survivors)  
**Motor:** Godot 4.5 (GDScript)

---

## Descripción del Proyecto

Marvel Survivors es un videojuego de supervivencia horde en perspectiva top-down. El jugador controla un personaje del universo Marvel que debe sobrevivir oleadas de enemigos durante 10 minutos. Al subir de nivel, puede seleccionar nuevas armas o mejorar las existentes. El objetivo es sobrevivir el mayor tiempo posible mientras la dificultad escala progresivamente.

---

## Arquitectura del Sistema de Armas

El sistema utiliza una jerarquía de clases:

```
BaseWeapon (Area2D)
├── BulletWeapon   — Proyectil que viaja hacia el enemigo más cercano
├── AxeWeapon      — Arma cuerpo a cuerpo que rota alrededor del jugador
└── AuraWeapon     — Campo de daño pasivo centrado en el jugador

WeaponController   — Gestiona el ciclo de disparo de UN arma
WeaponManager      — Orquesta MÚLTIPLES WeaponControllers
```

---

## Estado Actual

| Sistema | Estado |
|---|---|
| Movimiento del jugador | ✅ Completo |
| Cámara con zoom | ✅ Completo |
| Generación procedural del mundo | ✅ Completo |
| Obstáculos con NavMesh | ✅ Completo |
| Sistema de enemigos + elites | ✅ Completo |
| Spawner con dificultad escalable | ✅ Completo |
| XP + sistema de niveles | ✅ Completo |
| Gemas de experiencia con rareza | ✅ Completo |
| Estructura Magnet | ✅ Completo |
| HUD (barra XP, timer, nivel) | ✅ Completo |
| BaseWeapon + jerarquía de armas | ✅ Completo |
| Arma: Aura | ✅ Completo |
| Arma: Hacha (melee) | ✅ Completo |
| Arma: Bala (ranged) | ✅ Completo |
| WeaponController refactorizado | ✅ Completo |
| WeaponManager (múltiples armas) | ✅ Completo |
| UI de selección de upgrades | ✅ Completo |
| Sistema de tomos (stats del jugador) | ✅ Completo |
| Pantalla de Game Over | ✅ Completo |
| Menú principal | 🔧 En progreso |
| Personajes Marvel (assets) | ❌ Pendiente |
| Más armas temáticas Marvel | ❌ Pendiente |
| Sonido y música | ❌ Pendiente |
| Enemigos temáticos Marvel | ❌ Pendiente |
| Condición de victoria | ➖ No aplica (juego infinito) |
| Horda especial al minuto 10 | ❌ Pendiente |

---

## Tareas Detalladas

### FASE 1 — Sistema de Armas (completado)

- [x] Crear `BaseWeapon` con `class_name` y enum `WeaponType { MELEE, RANGED, AURA }`
- [x] Corregir `bullet.gd` — tenía código de aura en lugar de lógica de proyectil
- [x] Migrar `axe.gd` y `aura.gd` a `extends BaseWeapon`
- [x] Refactorizar `weapon_controller.gd` — eliminar duck-typing con `"is_melee" in temp`
- [x] Crear `weapon_manager.gd` — soporte para múltiples armas simultáneas

---

### FASE 2 — UI de Progresión (completado)

- [ ] Crear `UpgradeScreen` — overlay que pausa el juego al subir de nivel
- [ ] Generar 3 opciones aleatorias de upgrade en cada nivel
- [ ] Conectar señal `leveled_up` de `global.gd` con `UpgradeScreen`
- [ ] Cada opción muestra: nombre del arma, descripción, ícono
- [ ] Si el jugador ya tiene el arma → mostrar "Mejorar" en lugar de "Obtener"
- [ ] Al seleccionar upgrade → llamar `WeaponManager.add_weapon(...)` o `level_up_weapon(...)`
- [ ] Reanudar el juego después de la selección

**Armas a incluir como opciones de upgrade:**

| ID | Nombre | Tipo | Descripción |
|---|---|---|---|
| `aura` | Escudo Energético | AURA | Daño en área permanente alrededor del jugador |
| `axe` | Mjolnir | MELEE | Martillo que gira alrededor del jugador |
| `bullet` | Rayos de Iron Man | RANGED | Disparos que apuntan al enemigo más cercano |
| *(futuras)* | Flechas de Ojo de Halcón | RANGED | Múltiples proyectiles en abanico |
| *(futuras)* | Telaraña | MELEE | Ralentiza y daña enemigos cercanos |

---

### FASE 2b — Sistema de Tomos (completado)

- [x] Agregar stats del jugador a `Global`: `damage_multiplier`, `quantity_bonus`, `knockback_multiplier`, `size_multiplier`
- [x] `Global.apply_tome(id)` — incrementa el stat correspondiente y emite `stats_changed`
- [x] `Global.reset()` — resetea todos los stats + XP + tiempo entre runs
- [x] `BaseWeapon._ready()` conecta `stats_changed` → `_on_stats_changed()` virtual
- [x] `AuraWeapon` — aplica `size_multiplier` al diámetro; `damage_multiplier` al daño; ignora quantity y knockback
- [x] `AxeWeapon` / `BulletWeapon` — aplican `size_multiplier` (scale), `damage_multiplier` y `knockback_multiplier` al disparar
- [x] `WeaponController` — `projectile_count + Global.quantity_bonus` al spawnear (AURA no llega a este path)
- [x] `enemy.take_damage(amount, knockback: Vector2)` — API cambiada, knockback es vector directo

**Tomos disponibles:**

| ID | Stat | Incremento | Aplica a |
|---|---|---|---|
| `damage` | `damage_multiplier` | +10% | Todas |
| `quantity` | `quantity_bonus` | +1 proyectil | MELEE, RANGED |
| `knockback` | `knockback_multiplier` | +25% | MELEE, RANGED |
| `size` | `size_multiplier` | +20% | Todas |

**Para agregar un tomo nuevo:** solo llamar `Global.apply_tome("id")` y definir el incremento en el `match` de `global.gd`.

---

### FASE 3 — Assets Marvel

- [ ] Reemplazar sprites Orc del jugador con personaje Marvel (Iron Man, Spider-Man, etc.)
- [ ] Crear/importar sprites de enemigos temáticos (Chitauri, Hydra, etc.)
- [ ] Ícono y sprite para cada arma
- [ ] Cambiar `ground.jpeg` / `stone.jpg` por texturas coherentes con el universo Marvel
- [ ] Splash screen / logo del juego

---

### FASE 4 — Pantallas y Flujo de Juego

- [ ] **Menú Principal** — botones: Jugar, Salir; logo del juego
- [ ] **Pantalla de Game Over** — tiempo sobrevivido, nivel alcanzado, reintentar
- [ ] **Pantalla de Victoria** — si el jugador sobrevive 10 minutos
- [ ] Transiciones entre escenas (fade in/out)

---

### FASE 5 — Contenido y Balance

- [ ] Agregar al menos 2 armas nuevas con temática Marvel
- [ ] Agregar tipo de enemigo 2 (más rápido, menos vida)
- [ ] Agregar tipo de enemigo 3 (a distancia)
- [ ] Boss al minuto 5 y al minuto 9
- [ ] Ajustar curva de dificultad según playtesting

---

### FASE 6 — Audio

- [ ] Música de fondo (loop de combate)
- [ ] SFX: disparo, impacto, level up, muerte de enemigo, game over
- [ ] AudioManager singleton para controlar volumen

---

### FASE 7 — Polish

- [ ] Partículas de impacto en enemigos
- [ ] Screen shake al recibir daño
- [ ] Números de daño flotantes
- [ ] Estandarizar comentarios en un solo idioma (español)
- [ ] Reemplazar magic numbers con constantes/exports
- [ ] Refactor: pantalla de muerte del jugador con animación

---

## Decisiones Técnicas Tomadas

### Sistema de Armas con class_name
Se utiliza herencia de GDScript mediante `class_name BaseWeapon` para que `WeaponController` pueda identificar el tipo de arma con `instance is BaseWeapon` y leer `weapon_type` directamente, eliminando el duck-typing previo con `"is_melee" in temp`.

### WeaponManager como orquestador
`WeaponManager` es un Node2D hijo del jugador que mantiene un diccionario `weapon_id → WeaponController`. Esto permite: agregar nuevas armas en runtime, hacer level-up de armas existentes, y consultar qué armas tiene el jugador actualmente.

### Generación procedural
El mundo, los obstáculos y las props se generan en runtime para dar variedad en cada partida. El NavMesh se hornea 2 frames después del spawn de obstáculos para garantizar estabilidad.
