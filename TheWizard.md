# TheWizard.md
Blueprint lengkap game Roblox: **Wizard Alchemy**

> Dokumen ini dibuat sebagai pegangan desain, produksi, dan implementasi untuk game wizard / alchemy / magic RPG di Roblox.  
> Fokusnya: progression yang bikin nagih, map pulau terpisah oleh laut, transport broom/sapu, monster, skill, equipment, crafting, dan pemakaian asset gratis yang aman dari Roblox.

---

## 1. Ringkasan Konsep

**TheWizard** adalah game Roblox bertema fantasi penyihir dengan loop utama:

- eksplorasi pulau
- grinding monster
- farming material
- meracik potion / alchemy
- unlock spell
- upgrade wand / staff / robe / relic
- buka pulau baru
- lawan boss
- PvP arena
- koleksi rarity dan build

Game ini bukan roleplay wizard biasa. Intinya adalah **RPG progression loop** yang dipadukan dengan **crafting alchemy**, **combat magic**, **open world islands**, dan **collection/meta build**.

### Fantasi utama pemain
Pemain merasa seperti:
- murid wizard yang naik kelas
- alchemist yang menemukan resep langka
- penyihir dengan elemen berbeda
- pemburu boss dan collector item
- pemilik broom yang bisa pindah pulau

### Target pengalaman
- seru di mobile
- kontrol sederhana
- visual magic yang flashy
- progress terasa cepat di awal, lalu dalam di mid/endgame
- cocok untuk update berkala

---

## 2. Core Game Pillars

1. **Progression yang jelas**  
   Player selalu tahu langkah berikutnya: kill, collect, craft, upgrade, unlock.

2. **Fantasy magic yang kuat**  
   Broom, wand, potion, rune, crystal, portal, tower, altar, academy.

3. **Collection dan rarity**  
   Item langka, spell langka, monster rare, material rare, cosmetic exclusive.

4. **Exploration antar pulau**  
   Dunia dibagi jadi beberapa pulau terpisah laut.

5. **Build variety**  
   Fire build, Ice build, Poison build, Arcane build, Summoner build, Hybrid build.

6. **Social / repeatable content**  
   Trading, party, boss raid, PvP arena, daily quest, event island.

---

## 3. Core Gameplay Loop

```text
Spawn di hub
→ ambil quest
→ terbang / jalan ke area monster
→ farming material
→ craft potion / upgrade skill
→ buka area baru
→ lawan boss
→ dapat item/langka
→ build lebih kuat
→ pindah ke pulau berikutnya
→ repeat
```

### Bentuk progression yang dipakai
- level karakter
- mastery elemen
- wand power
- potion tier
- broom tier
- race / lineage
- pet familiar
- reputation / title
- island unlock

---

## 4. Struktur Dunia dan Jumlah Pulau

Map sebaiknya dibuat seperti **archipelago**: pulau-pulau terpisah laut luas.  
Ini cocok dengan ide transport **broom/sapu** karena pemain bisa terbang di atas laut dari satu pulau ke pulau lain.

### Rekomendasi jumlah pulau
Untuk versi lengkap, gunakan **9 pulau utama**:

1. **Starter Island**
2. **Academy Island**
3. **Forest Island**
4. **Swamp Island**
5. **Volcano Island**
6. **Ice Island**
7. **Ruins Island**
8. **Sky Island**
9. **Void / Endgame Island**

Kalau mau versi MVP, cukup buat 3–4 pulau dulu:
- Starter
- Forest
- Swamp
- Academy / Hub

---

## 5. Struktur Map per Pulau

## 5.1 Starter Island
Pulau awal untuk pemain baru.

### Fungsi
- tutorial
- quest awal
- pengenalan crafting
- monster lemah
- toko dasar

### Bangunan
- Wizard Dock
- Beginner House
- Training Yard
- Small Potion Bench
- Starter Wand Shop
- Quest Board
- Boat/Broom Rental

### Monster
- Slime
- Bat
- Rat
- Tiny Goblin

### Material
- Herb
- Crystal Shard
- Mushroom
- Pebble Essence

---

## 5.2 Academy Island
Pulau pusat wizard school.

### Fungsi
- hub utama
- unlock skill
- upgrade spell tree
- training magic
- event seasonal

### Bangunan
- Grand Wizard Academy
- Library of Runes
- Spell Classroom
- Alchemy Laboratory
- Staff Forge
- Broom Hangar
- Dormitory
- Admin/Quest Hall
- Duel Arena

### NPC penting
- Headmaster
- Alchemist Teacher
- Wand Master
- Broom Seller
- Race Reroll NPC
- Boss Raid NPC

### Monster
- Training Dummy
- Cursed Book
- Rogue Student Spirit
- Spell Slime

### Sistem penting
- skill tree
- spell unlock
- tutorial lanjutan
- crafting recipe unlock

---

## 5.3 Forest Island
Pulau farming awal-menengah.

### Fungsi
- bahan herbal
- monster dasar
- rare mushrooms
- wood and moss ingredients

### Bangunan
- Herbal Hut
- Ranger Camp
- Tree Shrine
- Mushroom Grove Hut
- Small Healing Pavilion

### Monster
- Wild Wolf
- Forest Sprite
- Vine Beast
- Moss Golem

### Material
- Herb Leaf
- Bark Wood
- Glow Mushroom
- Fairy Dust

---

## 5.4 Swamp Island
Pulau alchemy dan poison.

### Fungsi
- bahan potion
- spell poison / curse
- monster beracun

### Bangunan
- Witch Hut
- Swamp Lab
- Rotten Dock
- Poison Cauldron House
- Old Ruined Chapel

### Monster
- Swamp Slime
- Poison Frog
- Bog Witch
- Leech Monster
- Cursed Skull

### Material
- Toxic Mushroom
- Sludge Core
- Poison Fang
- Rotten Bone

---

## 5.5 Volcano Island
Pulau fire mage.

### Fungsi
- fire spell
- forge material
- rare metal
- boss lava

### Bangunan
- Lava Forge
- Blacksmith Tower
- Fire Altar
- Magma Watchpost
- Ember Cave

### Monster
- Magma Slime
- Flame Imp
- Lava Golem
- Fire Drake

### Material
- Ember Crystal
- Molten Ore
- Ash Feather
- Fire Core

---

## 5.6 Ice Island
Pulau frost mage.

### Fungsi
- ice spell
- defense builds
- crowd control
- rare ice crystal

### Bangunan
- Frozen Temple
- Ice Library
- Crystal Bridge
- Snow Cabin
- Frost Arena

### Monster
- Ice Wolf
- Snow Spirit
- Frozen Knight
- Crystal Yeti

### Material
- Frost Crystal
- Snow Petal
- Frozen Heart
- Ice Shard

---

## 5.7 Ruins Island
Pulau ancient magic dan relic.

### Fungsi
- mid-late game
- artifact
- rune puzzle
- dungeon entrance

### Bangunan
- Ancient Gate
- Broken Temple
- Rune Circle
- Relic Vault
- Subterranean Dungeon

### Monster
- Ancient Guardian
- Skeleton Mage
- Stone Sentinel
- Cursed Knight

### Material
- Rune Fragment
- Ancient Dust
- Relic Stone
- Spirit Thread

---

## 5.8 Sky Island
Pulau akses lewat broom tinggi.

### Fungsi
- late game traversal
- air element
- elit mobs
- rare chest

### Bangunan
- Cloud Harbor
- Floating Observatory
- Sky Tower
- Windmill Shrine
- Aerial Market

### Monster
- Cloud Bat
- Wind Serpent
- Sky Golem
- Thunder Bird

### Material
- Wind Feather
- Cloud Essence
- Thunder Core
- Sky Crystal

---

## 5.9 Void / Endgame Island
Pulau tertinggi untuk boss dan item paling langka.

### Fungsi
- endgame
- boss raid
- mythic loot
- hard PvP zone

### Bangunan
- Void Citadel
- Broken Portal
- Eclipse Arena
- Soul Furnace
- Final Altar

### Monster
- Void Wraith
- Shadow Titan
- Rift Demon
- Eclipse Dragon

### Material
- Void Fragment
- Dark Essence
- Rift Core
- Mythic Ash

---

## 6. Ocean and Travel System

Karena map berbentuk pulau terpisah laut, laut harus jadi elemen penting dunia.

### Fungsi laut
- pemisah antar pulau
- visual scale besar
- jalur travel
- tempat event laut
- zona bahaya

### Isi laut
- ombak
- batu karang
- fishing spot
- sea monster
- whirlpool / portal
- hidden island kecil
- wreck ship
- storm zone

### Travel antar pulau
1. **Broom / Sapu**
   - terbuka setelah quest tertentu
   - cepat
   - bisa upgrade speed, glide, mana boost
   - cocok untuk pindah pulau di udara

2. **Boat / Ferry**
   - lebih lambat
   - murah
   - cocok early game

3. **Portal Gate**
   - unlock setelah map tertentu
   - untuk fast travel

4. **Sky Route**
   - jalur udara di area tinggi
   - hanya untuk pulau tertentu

### Sapu/broom progression
- Beginner Broom
- Oak Broom
- Silver Broom
- Arcane Broom
- Storm Broom
- Phoenix Broom
- Void Broom

### Stat broom
- speed
- acceleration
- mana cost
- turning
- altitude limit
- glide stability

---

## 7. Monster Design

Monster harus dibagi jadi beberapa tier agar progression terasa jelas.

### Tier monster
- Common
- Rare
- Elite
- Mini Boss
- Boss
- World Boss
- Event Boss
- Mythic Boss

### Contoh progression monster
#### Early game
- Slime
- Bat
- Goblin
- Wolf

#### Mid game
- Cursed Mage
- Ice Spirit
- Poison Beast
- Lava Golem

#### Late game
- Rune Knight
- Thunder Drake
- Void Wraith
- Ancient Titan

### Desain monster
Setiap monster idealnya punya:
- 1 basic attack
- 1 special attack
- 1 death effect atau rage phase
- drop material spesifik
- chance rare drop

### Monster rare/elite
- Golden Slime
- Shadow Wolf
- Crystal Gargoyle
- Ember Phoenix Hatchling
- Frost Revenant

---

## 8. Boss Design

Boss harus memorable, bukan sekadar HP besar.

### Ciri boss yang bagus
- arena khusus
- telegraph skill jelas
- phase 1 / phase 2
- loot unik
- cutscene pendek

### Boss examples
- Forest King
- Swamp Witch
- Magma Lord
- Ice Queen
- Ancient Rune Beast
- Sky Thunderbird
- Void Archon

### Reward boss
- rare spell book
- unique wand core
- broom upgrade part
- title
- cosmetic aura
- artifact drop

---

## 9. Character System

### Karakter utama
Pemain memakai avatar Roblox, tetapi di dalam game bisa ditambah:
- wizard robe overlay
- magic aura
- face effect
- title above head
- race visual
- accessory slot

### Race / lineage
Contoh race:
- Human
- Elf
- Demon
- Angel
- Dragonborn
- Undead
- Fairy
- Voidborn

### Fungsi race
- bonus damage
- mana regen
- luck
- movement speed
- resist element
- skill modifier

### Contoh build race
- **Elf**: mana regen tinggi, cocok support
- **Demon**: damage tinggi, cocok fire/curse
- **Dragonborn**: strong brute magic
- **Angel**: healing dan light build
- **Voidborn**: endgame crit/luck

---

## 10. Skill / Spell System

Skill harus terasa “wizard banget” dan punya efek visual kuat.

### Struktur spell
Setiap spell punya:
- name
- element
- mana cost
- cooldown
- cast time
- damage
- area
- rarity
- upgrade path

### Spell tiers
- Basic
- Advanced
- Rare
- Epic
- Legendary
- Mythic
- Ultimate

### Contoh spell fire
- Fire Spark
- Flame Bolt
- Inferno Ring
- Phoenix Strike
- Cataclysm Flame

### Contoh spell ice
- Ice Shard
- Frozen Wall
- Blizzard Field
- Absolute Zero
- Ice Age

### Contoh spell poison
- Toxic Dart
- Venom Cloud
- Rot Explosion
- Plague Bloom
- Death Miasma

### Contoh spell arcane
- Arcane Pulse
- Rune Burst
- Mana Chain
- Gravity Seal
- Astral Nova

### Sistem combo spell
Contoh:
- Fire + Wind = Plasma
- Water + Ice = Frostbite
- Lightning + Wind = Storm
- Shadow + Fire = Hellflame
- Earth + Fire = Lava

### Passive skills
- mana regen
- cast speed
- luck
- potion efficacy
- broom speed
- crit chance
- reduce cooldown

---

## 11. Alchemy and Potion System

Alchemy adalah inti identitas game.

### Fungsi potion
- heal
- mana regen
- exp boost
- damage boost
- defense boost
- speed boost
- drop luck boost
- rare spawn boost
- fishing luck
- boss damage boost

### Format crafting
```text
Ingredient A + Ingredient B + Ingredient C + Catalyst
→ Potion / Elixir / Flask / Tonic
```

### Contoh ingredient
- Herb Leaf
- Glow Mushroom
- Frost Petal
- Ember Ash
- Poison Fang
- Dragon Scale
- Rune Dust
- Spirit Water

### Proses crafting
1. kumpulkan material
2. buka cauldron / alchemy table
3. pilih resep
4. proses brewing
5. hasil potion muncul
6. ada kemungkinan normal / great / perfect / failed

### Output kualitas
- Common
- Fine
- Superior
- Masterwork
- Arcane
- Perfect

### Sistem eksperimen
Untuk menambah replayability:
- resep tersembunyi
- ingredient langka
- hasil kombinasi acak tertentu
- discovery book

---

## 12. Equipment System

Equipment sebaiknya dibagi jadi beberapa slot.

### Slot equipment
- Wand / Staff
- Robe
- Hat / Hood
- Ring
- Necklace
- Artifact
- Cape
- Broom
- Familiar / Pet

### Contoh item equipment
#### Wand
- Beginner Wand
- Oak Wand
- Crystal Wand
- Inferno Wand
- Void Wand

#### Robe
- Novice Robe
- Academy Robe
- Swamp Robe
- Elder Robe
- Archmage Robe

#### Ring / Necklace
- Mana Ring
- Crit Ring
- Lucky Pendant
- Soul Necklace
- Element Seal

#### Artifact
- Rune Tablet
- Ancient Core
- Orb of Sight
- Phoenix Charm

### Stat equipment
- magic power
- mana
- mana regen
- cast speed
- crit
- luck
- defense
- movement
- element bonus

---

## 13. Familiar / Pet System

Pet/familiar menambah build dan monetisasi.

### Contoh familiar
- Fire Sprite
- Ice Spirit
- Mini Dragon
- Floating Eye
- Spirit Wolf
- Baby Phoenix
- Arcane Orb

### Fungsi familiar
- passive buff
- auto loot
- damage bonus
- farming speed
- potion boost
- cosmetic flex

---

## 14. Currency and Economy

### Currency utama
- Gold
- Crystal
- Mana Dust
- Rune Shard
- Event Token

### Sumber currency
- quest
- monster drop
- boss
- daily reward
- event
- trading

### Pengeluaran currency
- upgrade wand
- skill unlock
- broom upgrade
- race reroll
- potion craft
- fast travel
- cosmetic shop

---

## 15. Quest System

### Jenis quest
- kill quest
- collect quest
- craft quest
- travel quest
- boss quest
- explore quest
- daily quest
- weekly quest

### Contoh quest flow
- ambil quest di board
- kill 10 slime
- collect 5 herb
- craft 1 potion
- return ke NPC
- dapat reward + unlock area

---

## 16. Buildings and Functional Structures

Bangunan bukan hanya dekorasi, tapi harus punya fungsi.

### Bangunan penting
- Academy
- Lab / Alchemy Lab
- Wand Shop
- Broom Shop
- Potion Bench
- Blacksmith Forge
- Quest Board
- Boss Gate
- Arena
- Dock / Ferry Port
- Portal Hall
- Storage / Warehouse
- Library
- Shrine
- Dungeon Entrance
- Market

### Fungsi per bangunan
- **Shop**: beli item
- **Lab**: craft potion
- **Forge**: upgrade equipment
- **Arena**: PvP
- **Dock**: pindah antar pulau
- **Portal Hall**: fast travel
- **Library**: unlock lore / recipe / spell book
- **Shrine**: buff / reroll / summoning

---

## 17. UI Layout

### UI utama
- HP bar
- Mana bar
- level
- quest tracker
- skill hotbar
- potion slot
- mini map
- currency display
- broom stamina / mana

### UI tambahan
- inventory
- spell book
- crafting menu
- map island menu
- shop menu
- race menu
- boss info
- reward popup
- rarity banner

### UI style
- fantasy clean
- glowing borders
- readable di mobile
- animasi smooth
- tidak terlalu ramai

---

## 18. Visual Direction

### Style visual
- fantasy modern
- colorful magic
- glowing effects
- soft fog
- magical particles
- floating runes
- water reflections
- sky islands dengan cloud layer

### Warna per area
- Starter: hijau / biru muda
- Academy: biru / gold
- Forest: hijau
- Swamp: hijau gelap / ungu
- Volcano: orange / merah
- Ice: putih / cyan
- Ruins: abu / emas pudar
- Sky: biru langit / putih
- Void: hitam / ungu / neon

---

## 19. Roblox Tech Stack

### Bahasa utama
- **Luau**

### Sistem yang perlu dipakai
- `ModuleScript` untuk sistem modular
- `RemoteEvent` / `RemoteFunction` untuk komunikasi client-server
- `DataStore` / profile system untuk save data
- `CollectionService` untuk tag monster / interactable
- `TweenService` untuk UI dan animasi
- `PathfindingService` jika ada NPC bergerak
- `Animation Editor` untuk animasi karakter / monster
- `Humanoid` / `Animator` untuk rig dan spell cast
- `Attributes` untuk stat entity
- `UI/ScreenGui` untuk interface
- `ParticleEmitter` / `Beam` / `Trail` untuk VFX
- `Sound` / audio assets untuk ambience dan spell SFX

### Arsitektur yang disarankan
- server authoritative untuk damage, loot, crafting
- client hanya untuk visual, input, dan UI
- data penting selalu divalidasi server

---

## 20. Asset Gratis yang Bisa Dipakai di Roblox

Bagian ini penting kalau kamu ingin cepat prototyping tanpa bikin semua asset dari nol.

### 20.1 Sumber asset gratis yang aman untuk mulai
1. **Creator Store**
   - marketplace asset dari Roblox dan kreator lain
   - berisi model, image, mesh, audio, plugin, video, font
   - cari item gratis untuk prototype

2. **Toolbox di Roblox Studio**
   - akses dari Studio
   - berisi models, images, meshes, audio, plugins, videos, fonts
   - cocok untuk placeholder cepat

3. **Packages**
   - asset modular yang bisa dipakai ulang
   - bagus untuk environment dan sistem yang konsisten

4. **Starter assets / built-in tools**
   - parts dasar
   - rig avatar dasar
   - tool standar
   - environment primitives

5. **Animation Editor**
   - bukan asset siap pakai, tapi gratis untuk membuat animasi sendiri
   - cocok untuk spell cast, run, idle, attack, broom ride

### 20.2 Asset gratis untuk equipment
- wand/staff model sederhana dari Creator Store
- robe/cape placeholder
- broom model gratis
- ring/artifact model
- generic fantasy weapon pack
- basic accessory pack

### 20.3 Asset gratis untuk monster
- creature model gratis dari Creator Store
- low-poly beast
- slime pack
- skeleton pack
- ghost pack
- goblin pack
- dragon placeholder

### 20.4 Asset gratis untuk skill / VFX
- particle effects sederhana
- beam/trail built-in
- decal rune circle
- magic circle mesh
- light glow effect
- sound effect dari Creator Store audio

### 20.5 Asset gratis untuk character
- default Roblox avatar / rig
- package avatar basic
- clothing placeholder
- hair / hat / accessory gratis
- animation bawaan atau custom dari Animation Editor

### 20.6 Asset gratis untuk building / map
- house pack
- castle / ruin / tower models
- dock / bridge / fence
- tree / rock / mountain pack
- cloud / sky island props
- fantasy village pack

### 20.7 Catatan penting asset gratis
- cek isi model sebelum dipakai
- hapus script yang tidak dikenal
- jangan langsung percaya semua free model
- pakai asset gratis sebagai placeholder, lalu ganti dengan original asset di versi final
- cocokkan style agar dunia tetap konsisten

---

## 21. Free Asset Workflow yang Disarankan

### Tahap prototype
Pakai asset gratis untuk:
- pulau
- monster
- wand
- broom
- effect dasar
- UI placeholder

### Tahap vertical slice
Ganti asset penting jadi original:
- main character VFX
- boss
- main island landmark
- academy building
- signature broom
- signature wand

### Tahap final polish
Buat:
- material sendiri
- sound sendiri
- spell effect sendiri
- icon sendiri
- banner/thumbnail sendiri

---

## 22. Content Update Plan

Game seperti ini hidup dari update rutin.

### Update yang paling bagus
- 1 pulau baru
- 1 boss baru
- 3–5 spell baru
- 1 set equipment baru
- 1 race baru
- 1 event limited
- 1 potion recipe baru

### Update cadence ideal
- small patch mingguan
- content patch bulanan
- event besar musiman

---

## 23. Monetization Plan

### Monetisasi yang cocok
- x2 exp
- x2 drop chance
- extra inventory slot
- broom speed boost
- race reroll
- spell reroll
- cosmetic pack
- premium aura
- private server
- boss raid pass
- name color/title

### Hindari
- paywall terlalu keras
- progression terasa dipaksa bayar
- terlalu banyak pop-up

---

## 24. MVP Scope

Kalau mau mulai cepat, jangan langsung bikin semua pulau.

### MVP yang disarankan
#### Map
- Starter Island
- Academy Island
- Forest Island

#### Sistem
- movement
- combat basic
- 3 spell
- 1 broom
- 1 potion system
- 1 boss
- 1 race system
- save data
- quest board
- inventory

#### Monster
- slime
- goblin
- forest wolf
- forest spirit

#### Equipment
- 3 wand
- 2 robe
- 2 broom
- 3 potion

### Target MVP
- pemain bisa login
- quest jalan
- farming terasa seru
- unlock spell
- pindah pulau pakai broom/boat
- ada loop yang bikin betah

---

## 25. Folder / Script Structure

Contoh struktur project yang rapi:

```text
ReplicatedStorage
├── Remotes
├── Modules
│   ├── CombatModule
│   ├── QuestModule
│   ├── CraftingModule
│   ├── BroomModule
│   ├── DataModule
│   └── MonsterModule
├── Assets
│   ├── VFX
│   ├── SFX
│   ├── Icons
│   ├── Spells
│   └── Items

ServerScriptService
├── Services
│   ├── CombatService
│   ├── QuestService
│   ├── CraftingService
│   ├── DataService
│   ├── LootService
│   └── TravelService

StarterPlayer
├── StarterPlayerScripts
├── StarterCharacterScripts

StarterGui
├── HUD
├── InventoryUI
├── CraftingUI
├── QuestUI
├── MapUI
└── ShopUI

Workspace
├── Islands
├── NPCs
├── Monsters
├── Bosses
├── Interactables
└── TravelPoints
```

---

## 26. System Rules

### Combat
- server hit validation
- cooldown anti-spam
- mana cost check
- range check
- stun/cc limit

### Crafting
- server checks material
- recipe table only dari server
- hasil potion dicatat di data

### Loot
- drop table per monster
- rarity controlled by server
- rare boss reward limited

### Travel
- broom unlock by quest
- island teleport only if unlocked
- anti-exploit position check

---

## 27. Design Principles

### Yang harus dijaga
- gampang dipahami
- progress selalu terasa
- visual magic satisfying
- map terasa luas
- tiap pulau punya identitas kuat
- player punya alasan balik lagi

### Yang jangan dilakukan
- terlalu banyak sistem di awal
- map tanpa identitas
- monster sama semua
- skill tanpa efek visual
- crafting yang membingungkan
- UI terlalu berat di mobile

---

## 28. Versi Final Vision

Kalau game ini matang, pemain akan merasakan:

- mulai dari murid wizard biasa
- farming di pulau awal
- unlock broom
- terbang ke pulau lain lewat laut
- belajar spell baru
- craft potion langka
- lawan boss besar
- kumpulkan set gear terbaik
- masuk endgame Void Island
- pamer build dan cosmetic rare

Itu inti fantasi TheWizard.

---

## 29. Referensi Produksi Roblox yang Dipakai

Catatan sumber resmi Roblox yang relevan untuk blueprint ini:

- Creator Store: marketplace asset yang berisi asset dari Roblox dan kreator lain.
- Toolbox: berisi models, images, meshes, audio, plugins, videos, fonts.
- Assets: tempat mencari asset proyek dan avatar assets.
- Studio: gratis dipakai untuk membuat dan publish pengalaman.
- Animation Editor: untuk membuat animasi custom.
- Audio assets: menyediakan audio free-to-use.
- Avatar items: banyak item avatar ada di marketplace, tetapi tidak semua gratis.

---

## 30. Output yang Harus Dibangun Setelah Dokumen Ini

Urutan kerja yang paling aman:

1. buat Starter Island
2. buat combat basic
3. buat quest board
4. buat 3 spell dasar
5. buat broom travel
6. buat Forest Island
7. buat crafting potion
8. buat boss pertama
9. buat save data
10. lanjut pulau berikutnya

---

## 31. Ringkasan Singkat Inti Game

```text
Wizard RPG + Alchemy Crafting + Island Exploration + Broom Travel + Monster Grinding + Boss Hunt + Build Progression
```

Itulah identitas utama TheWizard.
