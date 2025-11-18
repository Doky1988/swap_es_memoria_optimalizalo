# 🚀 Webszerver Swap és Memória Optimalizáló Script

A script egy automatizált megoldást kínál Linux alapú webszerverek **Swap fájljának létrehozására** és a **memóriahasználat finomhangolására** a stabilitás és a teljesítmény maximalizálása érdekében. Kifejezetten hasznos lehet VPS (Virtual Private Server) környezetekben.

---

## ✨ Fő funkciók

* **Intelligens Swap méretezés:** A szerver **RAM mérete alapján** automatikusan kiszámítja az ajánlott Swap fájl méretét egy beépített táblázat segítségével.
* **Swap fájl létrehozása és aktiválása:** Létrehozza a `/swapfile` fájlt, beállítja a jogosultságokat, és hozzáadja az `/etc/fstab` fájlhoz a tartós aktiváláshoz.
* **Rendszerparaméterek finomhangolása (`sysctl`):** Optimalizálja a memória- és hálózati beállításokat (pl. `vm.swappiness`, `vm.vfs_cache_pressure`, TCP paraméterek) a jobb válaszidő és a megbízhatóbb kapcsolatkezelés érdekében.

## 💾 Swap méret kalkuláció

A script a következő logikát követi a Swap méret meghatározásához (alapvetően a RAM kétszerese kisebb RAM esetén, és csökkenő arány nagyobb RAM-oknál):

| Szerver RAM (GB) | Létrehozott Swap (GB) |
| :--------------: | :-------------------: |
| $\le 1$           | $1$                    |
| $1 < \text{RAM} \le 2$ | $1$                    |
| $2 < \text{RAM} \le 4$ | $2$                    |
| $4 < \text{RAM} \le 8$ | $2$                    |
| $8 < \text{RAM} \le 16$ | $4$                    |
| $16 < \text{RAM} \le 32$| $4$                    |
| $> 32$           | $8$                    |

## 📝 Használat

A script futtatásához csak le kell tölteni, futási jogot adni, majd futtatni `root` jogosultsággal (vagy `sudo` használatával).

1.  **Hozz létre `root` felhasználóként egy `swap_es_memoria_optimalizalo.sh` fájlt:**
    ```bash
    nano swap_es_memoria_optimalizalo.sh
    ```
    - Majd másold bele az itt található script tartalmát, és mentsd el!

2.  **Adj neki futási jogot:**
    ```bash
    chmod +x swap_es_memoria_optimalizalo.sh
    ```

3.  **Futtasd a scriptet:**
    ```bash
    sudo ./swap_es_memoria_optimalizalo.sh
    ```

A futtatás végén a script kiírja az **ellenőrző táblázatot** (`free -h`), és a beállított fő paraméterek aktuális értékét.

---

## ⚙️ Optimalizált `sysctl` beállítások

A script a következő értékeket állítja be az `/etc/sysctl.conf` fájlba:

### Memória- és Cache-kezelés

| Paraméter | Érték | Leírás |
| :--- | :---: | :--- |
| `vm.swappiness` | `10` | Alacsony érték, ami azt jelenti, hogy a kernel csak akkor használja a Swap-et, ha feltétlenül szükséges, előnyben részesítve a RAM-ot. |
| `vm.vfs_cache_pressure` | `50` | Mérsékelt érték, ami biztosítja a VFS (virtuális fájlrendszer) cache-ének megtartását a RAM-ban, csökkentve az I/O műveleteket. |
| `vm.dirty_background_ratio` | `5` | A RAM azon százaléka, amikor a háttérben megkezdődik az adatok lemezre írása. |
| `vm.dirty_ratio` | `10` | A RAM azon maximális százaléka, ami után minden új írási művelet blokkolódik, amíg az adatok lemezre nem kerülnek. |

### Hálózati finomhangolás (TCP)

| Paraméter | Érték | Leírás |
| :--- | :---: | :--- |
| `net.ipv4.tcp_fin_timeout` | `15` | Csökkenti a FIN-WAIT-2 állapotban lévő kapcsolatok idejét. |
| `net.ipv4.tcp_keepalive_time` | `300` | Beállítja az inaktív TCP kapcsolatok ellenőrzésének idejét 5 percre. |
| `net.ipv4.tcp_tw_reuse` | `1` | Lehetővé teszi a TIME-WAIT állapotban lévő socketek gyors újrahasználatát. |
| `net.ipv4.ip_local_port_range` | `1024 65000` | Növeli a kimenő kapcsolatokhoz használható portok tartományát. |
| `net.ipv4.tcp_max_syn_backlog` | `4096` | Növeli a még be nem fejezett TCP SYN kapcsolatok maximális sorát. |
| `net.core.somaxconn` | `4096` | Növeli a maximális bejövő kapcsolatok számát, amit a listen queue képes tartani. |

---

## 👤 Készítette

* **Készítette:** Doky
* **Dátum:** 2025.10.19
