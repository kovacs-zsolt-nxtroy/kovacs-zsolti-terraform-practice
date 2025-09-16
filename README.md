# HelloTerra - Azure Container App

Ez a Terraform projekt egy Azure Container App-ot hoz létre egy egyszerű "Hello World" alkalmazással.

## Előfeltételek

1. **Azure CLI** telepítve és konfigurálva
2. **Terraform** telepítve (verzió >= 1.0)
3. **Azure-előfizetés** és megfelelő jogosultságok

## Telepítés

### 1. Azure bejelentkezés

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 2. Konfiguráció

```bash
# Másold át a példa konfigurációt
cp terraform.tfvars.example terraform.tfvars

# Szerkeszd a terraform.tfvars fájlt a saját értékeiddel
nano terraform.tfvars
```

### 3. Terraform inicializálás

```bash
terraform init
```

### 4. Terv ellenőrzése

```bash
terraform plan
```

### 5. Telepítés

```bash
terraform apply
```

### 6. Alkalmazás elérése

A telepítés után a Container App URL-jét a kimenetekben találod:

```bash
terraform output container_app_url
```

## Key Vault integráció

Ha Key Vault-ot szeretnél használni titkos kulcsok kezeléséhez:

1. **Key Vault létrehozása** (ha még nincs):
   ```bash
   az keyvault create --name "your-keyvault-name" --resource-group "your-rg"
   ```

2. **Titkos kulcsok hozzáadása**:
   ```bash
   az keyvault secret set --vault-name "your-keyvault-name" --name "ALMA" --value "your-secret-value"
   ```

3. **Container App hozzáférés engedélyezése**:
   ```bash
   # Key Vault hozzáférési szabályzat hozzáadása
   az keyvault set-policy --name "your-keyvault-name" --object-id $(az ad signed-in-user show --query id -o tsv) --secret-permissions get list
   ```

4. **terraform.tfvars konfigurálása**:
   ```hcl
   key_vault_name = "your-keyvault-name"
   key_vault_resource_group_name = "your-rg"
   
   container_secrets = {
     secret-name = "https://your-keyvault-name.vault.azure.net/secrets/ALMA"
   }
   ```

## Ingress konfiguráció

Az ingress beállításával szabályozhatod, hogy a Container App külsőleg elérhető legyen-e:

### Ingress engedélyezése (alapértelmezett)
```hcl
enable_ingress = true
traffic_weight_percentage = 100
```
- A Container App külsőleg elérhető lesz
- Automatikusan generált URL-t kap
- HTTP protokoll használata
- 100% forgalom a legújabb revízióra

### Ingress letiltása
```hcl
enable_ingress = false
```
- A Container App csak belsőleg érhető el
- Nincs külső URL
- Hasznos belső szolgáltatásokhoz vagy queue-triggered függvényekhez

### Forgalom szabályozása
```hcl
traffic_weight_percentage = 50  # 50% forgalom az új revízióra
```
- 0-100% között állítható
- Hasznos fokozatos üzembe helyezéshez
- A fennmaradó forgalom a korábbi revízióra kerül

## Skálázási konfiguráció

A Container App automatikus skálázása HTTP kérések, memória és CPU kihasználtság alapján történik:

### HTTP Skálázás
```hcl
http_scaler_concurrent_requests = 20  # 20 egyidejű kérés után skálázás
http_scaler_concurrent_requests = 0   # HTTP skálázás letiltása
```

### Memória Skálázás
```hcl
memory_scaling_threshold = 80  # 80% memória kihasználtság után skálázás
memory_scaling_threshold = 0   # Memória skálázás letiltása
```

### CPU Skálázás
```hcl
cpu_scaling_threshold = 70  # 70% CPU kihasználtság után skálázás
cpu_scaling_threshold = 0   # CPU skálázás letiltása
```

### Skálázási működés

#### HTTP Skálázás
- **Alapértelmezett érték**: 20 egyidejű kérés
- **Skálázás felfelé**: Amikor az egyidejű kérések száma meghaladja a beállított értéket
- **Skálázás lefelé**: Amikor az egyidejű kérések száma alacsonyabb a beállított értéknél
- **Letiltás**: `http_scaler_concurrent_requests = 0` esetén a HTTP skálázás nem kerül konfigurálásra

#### Memória Skálázás
- **Alapértelmezett érték**: 80% memória kihasználtság
- **Skálázás felfelé**: Amikor a memória kihasználtság meghaladja a küszöbértéket
- **Skálázás lefelé**: Amikor a memória kihasználtság alacsonyabb a küszöbértéknél
- **Letiltás**: `memory_scaling_threshold = 0` esetén a memória skálázás nem kerül konfigurálásra

#### CPU Skálázás
- **Alapértelmezett érték**: 70% CPU kihasználtság
- **Skálázás felfelé**: Amikor a CPU kihasználtság meghaladja a küszöbértéket
- **Skálázás lefelé**: Amikor a CPU kihasználtság alacsonyabb a küszöbértéknél
- **Letiltás**: `cpu_scaling_threshold = 0` esetén a CPU skálázás nem kerül konfigurálásra

#### Kombinált Skálázás
- **Aktív szabályok**: A Container App akkor skálázódik, ha bármelyik engedélyezett feltétel teljesül
- **Letiltott szabályok**: 0 érték esetén a megfelelő skálázási szabály nem kerül konfigurálásra
- **Min/Max replikák**: A `min_replicas` és `max_replicas` változókkal szabályozható

### Példa konfigurációk

#### Alacsony forgalom
```hcl
http_scaler_concurrent_requests = 10
memory_scaling_threshold = 70
cpu_scaling_threshold = 60
```

#### Magas forgalom
```hcl
http_scaler_concurrent_requests = 50
memory_scaling_threshold = 90
cpu_scaling_threshold = 85
```

#### Érzékeny skálázás
```hcl
http_scaler_concurrent_requests = 5
memory_scaling_threshold = 60
cpu_scaling_threshold = 50
```

#### CPU-intenzív alkalmazások
```hcl
http_scaler_concurrent_requests = 30
memory_scaling_threshold = 90
cpu_scaling_threshold = 50  # Alacsony CPU küszöb
```

#### Memória-intenzív alkalmazások
```hcl
http_scaler_concurrent_requests = 30
memory_scaling_threshold = 60  # Alacsony memória küszöb
cpu_scaling_threshold = 80
```

#### CPU skálázás letiltása
```hcl
http_scaler_concurrent_requests = 20
memory_scaling_threshold = 80
cpu_scaling_threshold = 0  # CPU skálázás letiltva
```

#### Csak HTTP skálázás
```hcl
http_scaler_concurrent_requests = 30
memory_scaling_threshold = 0  # Memória skálázás letiltva
cpu_scaling_threshold = 0     # CPU skálázás letiltva
```

#### Csak erőforrás-alapú skálázás
```hcl
http_scaler_concurrent_requests = 0  # HTTP skálázás letiltva
memory_scaling_threshold = 70
cpu_scaling_threshold = 60
```

#### Minden skálázás letiltva
```hcl
http_scaler_concurrent_requests = 0  # HTTP skálázás letiltva
memory_scaling_threshold = 0         # Memória skálázás letiltva
cpu_scaling_threshold = 0            # CPU skálázás letiltva
```

## Konfigurálható paraméterek

### Alapvető konfiguráció
- `resource_group_name`: Meglévő Azure Resource Group neve
- `location`: Azure régió
- `project_name`: Projekt neve (erőforrások nevezéséhez)

### Container App konfiguráció
- `container_app_environment_name`: Meglévő Container App Environment neve (üresen hagyva új létrehozásához)
- `container_app_name`: Container App neve (üresen hagyva a project_name használatához)
- `log_analytics_workspace_name`: Log Analytics Workspace neve (üresen hagyva a project_name-logs használatához)

### Container beállítások
- `container_image`: Container image URL
- `target_port`: Container port
- `min_replicas` / `max_replicas`: Skálázási beállítások
- `enable_ingress`: Ingress engedélyezése/letiltása (true/false)
- `http_scaler_concurrent_requests`: HTTP skálázási szabály egyidejű kérések száma
- `memory_scaling_threshold`: Memória kihasználtság küszöbértéke skálázáshoz (1-100%)
- `cpu_scaling_threshold`: CPU kihasználtság küszöbértéke skálázáshoz (1-100%)
- `cpu_requests` / `memory_requests`: Erőforrás kérések

### Container Registry konfiguráció
- `container_registry_host`: Container Registry host neve (pl. your-registry.azurecr.io)
- `container_registry_username`: Container Registry felhasználónév

### Key Vault integráció
- `key_vault_name`: Meglévő Key Vault neve (üresen hagyva Key Vault nélkül)
- `key_vault_resource_group_name`: Key Vault Resource Group neve (üresen hagyva a fő Resource Group használatához)

### Környezeti változók és titkos kulcsok
- `container_env_variables`: Normál környezeti változók
- `container_env_secrets`: Titkos környezeti változók (Key Vault referenciákkal)
- `container_secrets`: Container titkos kulcsok (Key Vault referenciákkal)

### Címkék
- `tags`: Azure erőforrások címkézése

## Létrehozott erőforrások

- **Resource Group**: Meglévő Resource Group használata (`rg-ai-feature`)
- **Log Analytics Workspace**: Logok gyűjtése és monitorozás
- **Container App Environment**: Meglévő vagy új Container App környezet
- **Container App**: A tényleges alkalmazás
- **Key Vault integráció**: Opcionális titkos kulcsok kezelése (ha konfigurálva)
- **Container Registry**: Privát registry integráció (ha konfigurálva)

## Funkciók

- ✅ **Automatikus skálázás**: 0-10 replika között (konfigurálható)
- ✅ **Key Vault integráció**: Biztonságos titkos kulcsok kezelése
- ✅ **Container Registry**: Privát registry támogatás
- ✅ **Környezeti változók**: Normál és titkos változók kezelése
- ✅ **Log Analytics**: Teljes monitorozás és naplózás
- ✅ **Resource tagging**: Azure erőforrások címkézése

## Törlés

```bash
terraform destroy
```

## Hasznos parancsok

```bash
# Állapot megtekintése
terraform show

# Kimeneti értékek listázása
terraform output

# Konkrét kimenet lekérése
terraform output container_app_url
```

## Hibaelhárítás

Ha problémák merülnek fel:

1. Ellenőrizd az Azure CLI bejelentkezést: `az account show`
2. Ellenőrizd a jogosultságokat: `az role assignment list --assignee $(az account show --query user.name -o tsv)`
3. Nézd meg a Terraform logokat: `TF_LOG=DEBUG terraform apply`
