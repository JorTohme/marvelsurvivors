# Sistema de Cofres y Objetos (Inspirado en Megabonk)

## 1. Mecánica de Oro
- **Obtención:** Los enemigos al morir otorgan oro directamente al jugador (se suma automático, no cae al piso como las gemas de XP).
- **HUD:** Se agregará un contador de oro actual.

## 2. Lógica de Cofres
- **Aparición (Spawn):** Los cofres se generan aleatoriamente en el mapa a medida que el jugador explora.
- **Interacción:** El jugador se acerca y los toca (como los imanes). Si tiene el oro suficiente, se abre la interfaz.
- **Escalado de Precio:** El costo del cofre aumenta exponencialmente o escalonadamente a lo largo de la partida.
  - *Ejemplo de progresión:* 8 -> 12 -> 20 -> 50 -> 100 -> 500 -> 1500 -> 6000.
- **Recompensa:** Al abrir un cofre, se muestra una pantalla con **3 objetos aleatorios**. El jugador puede elegir **1** o seleccionar la opción **"Ninguno/Saltar"**.

## 3. Sistema de Objetos (Items)
A diferencia de los Tomos (que se obtienen al subir nivel), los Objetos se obtienen exclusivamente en Cofres y tienen mecánicas propias. Hay dos grandes tipos:

### 3.1. Objetos Acumulativos (Stackables)
Sus efectos son pequeños, pero si agarrás varios, se suman.
- **Moneda de la Suerte:** +2% probabilidad de que los enemigos suelten el doble de oro.
- **Ganzúa Rota:** +1% probabilidad de que abrir un cofre no consuma tu oro (te sale gratis).
- **Mochila de Cuero:** +1 máximo de proyectiles (inspirado en el *Backpack* de Megabonk).
- **Yunque Pequeño:** +2 daño plano a todas las armas (inspirado en el *Anvil*).
- **Lente de Aumento:** +2% probabilidad de crítico adicional.
- **Anillo Magnético:** +15% de área de recolección de experiencia.
- **Botas Ligeras:** +10% de velocidad de movimiento.

### 3.2. Objetos Únicos (Non-stackables)
Tienen efectos especiales poderosos. Agarrar el mismo objeto dos veces no mejora su efecto (o directamente deja de salir en la pool una vez que lo tenés).
- **Guantes de Estática:** 10% de probabilidad de que al golpear a un enemigo, el daño salte a otros 3 enemigos cercanos.
- **Espejo Roto:** Tienes un 15% de probabilidad de esquivar cualquier daño por completo (inspirado en el *Mirror*).
- **Lámpara Sobrecargada:** Duplica la probabilidad de que se activen otros objetos (como los Guantes o el Espejo) (inspirado en *Overpowered Lamp*).
- **Botas de Plomo:** Inmunidad total al *knockback* de los enemigos, pero pierdes 5% de velocidad de movimiento.

### 3.3. Nuevas Ideas de Objetos (Pendientes por Programar)
- **Batería Portátil (Único):** Te otorga una carga máxima extra para el Dash/Salto (`jump_count + 1`).
- **Resorte Oxidado (Acumulable):** +10% a la distancia y velocidad del Dash (`jump_distance + 0.1`).
- **Reloj de Bolsillo (Acumulable):** Aumenta el tiempo de invulnerabilidad después de recibir un golpe un +15%.
- **Imán Sobrecargado (Único):** Las gemas de experiencia que queden fuera de la pantalla durante más de 10 segundos vuelan automáticamente hacia ti.
- **Pacto de Sangre (Único):** Aumenta todo tu daño un +50%, pero tu regeneración pasiva se bloquea (se vuelve 0) sin importar cuántos tomos de vitalidad tengas.
- **Armadura de Espinas (Acumulable):** Devuelve un 50% del daño recibido al enemigo que te golpeó.

---

## 4. Tareas de Implementación (Checklist)

- [ ] **1. Sistema de Oro:** Agregar la variable `oro` en `Global.gd` y sumarlo al matar enemigos. Actualizar el HUD.
- [ ] **2. Entidad Cofre:** Crear el nodo del cofre, que detecte colisiones con el jugador y calcule su precio actual.
- [ ] **3. UI de Cofre:** Pantalla parecida al *UpgradeScreen*, pero con 3 opciones de objetos + botón de "Cerrar/Ninguno".
- [ ] **4. Gestor de Objetos:** Un diccionario o script que mantenga qué objetos tiene el jugador y sus cantidades (para los acumulativos).
- [ ] **5. Integración de Efectos:** Conectar la lógica de los objetos (ej: si el jugador tiene los *Guantes de Estática*, calcular el rayo en el `take_damage` de los enemigos).
