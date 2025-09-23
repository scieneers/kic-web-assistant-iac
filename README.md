# KI Campus Web Assistant - Infrastructure as Code

Dieses Repository enthält die komplette Infrastructure-as-Code (IaC) Konfiguration für den KI Campus Web Assistant, eine KI-basierte Chatbot-Anwendung, die auf Microsoft Azure deployed wird.

## 🏗️ Architektur-Überblick

Das System besteht aus mehreren Komponenten, die auf Azure-Services basieren:

### Hauptkomponenten

- **Frontend**: Streamlit-basierte Web-Anwendung (Container App Service)
- **REST API**: Backend-Service für API-Endpunkte (Azure Container Apps)
- **Data Loader**: Azure Functions App für Datenverarbeitung
- **Vector Database**: Qdrant für Embedding-Speicherung (Container Apps)
- **LLM Services**: Azure OpenAI und serverlose KI-Modelle (Mistral, Llama)
- **Monitoring**: Langfuse für LLM-Observability
- **Speicher**: PostgreSQL, Azure Storage, Key Vault

### Umgebungen

Das System unterstützt drei Umgebungen:
- **dev**: Entwicklungsumgebung
- **lab**: Labor-/Testumgebung  
- **prod**: Produktionsumgebung

## 📁 Repository-Struktur

```
├── tf/                          # Haupt-Terraform-Konfiguration
│   ├── modules/                 # Wiederverwendbare Terraform-Module
│   │   ├── ai_hub/             # Azure AI Hub Module
│   │   ├── ai_project/         # Azure AI Project Module
│   │   ├── ai_model_serverless/# Serverlose KI-Modelle
│   │   ├── key_vault_secrets/  # Key Vault Secrets Management
│   │   └── openai/             # Azure OpenAI Service
│   ├── dev/                    # Dev-spezifische Konfiguration
│   ├── lab/                    # Lab-spezifische Konfiguration
│   ├── prod/                   # Prod-spezifische Konfiguration
│   └── *.tf                    # Haupt-Terraform-Dateien
├── modules/                     # Zusätzliche Module
│   ├── kubernetes/             # Kubernetes/AKS Konfiguration
│   └── key_vault/              # Key Vault Module
└── README.md
```

## 🚀 Deployment

### Voraussetzungen

1. **Terraform**: Version 1.6.2 (siehe `.terraform-version`)
2. **Azure CLI**: Für Authentication
3. **SOPS**: Für Secrets-Management (`brew install sops`)
4. **Berechtigung**: Zugriff auf die entsprechenden Azure-Subscriptions

### Umgebung-spezifisches Deployment

```bash
# Für die Lab-Umgebung
cd tf
terraform init -backend-config=lab/backend.config
terraform plan -var-file=lab/lab.tfvars
terraform apply -var-file=lab/lab.tfvars

```

## 🔒 Secrets Management mit SOPS

### Einrichtung

SOPS wird für die sichere Verwaltung von Secrets verwendet. Secrets werden verschlüsselt in Git gespeichert.

```bash
# SOPS installieren
brew install sops

# Secrets verschlüsseln
sops --encrypt secrets.yaml > secrets.enc.yaml

# Secrets entschlüsseln
sops --decrypt secrets.enc.yaml
```

### Konfiguration

SOPS ist in jeder Umgebung über `.sops.yaml` Dateien konfiguriert und nutzt Azure Key Vault für die Verschlüsselung.

## 🧩 Hauptkomponenten im Detail

### Azure Services

- **Resource Groups**: Umgebung-spezifische Gruppierung aller Ressourcen
- **Storage Account**: Blob Storage für Terraform State und Daten
- **Container Registry**: Private Docker Registry für Container Images
- **Key Vault**: Zentrale Secrets-Verwaltung
- **App Service Plans**: Hosting für Web Apps
- **Container Apps**: Hosting für containerisierte Services
- **PostgreSQL**: Managed Database für Langfuse
- **Application Insights**: Monitoring und Logging

### KI/ML Services

- **Azure OpenAI**: GPT-4, Text Embeddings
- **Azure AI Hub & Projects**: ML-Workspace für Model Management
- **Serverless Endpoints**: Mistral Large, Llama Models
- **Cognitive Services**: OpenAI-kompatible APIs

## 🔧 Konfiguration

### Wichtige Variablen

- `environment_short`: Umgebung (dev/lab/prod)
- `secrets_file`: Pfad zur verschlüsselten Secrets-Datei
- `restapi_image_name`: Version des REST API Containers
- `frontend_image_name`: Version des Frontend Containers
- `openai_model_deployment`: Konfiguration der OpenAI-Modelle

### Container Images

Die Anwendung nutzt mehrere Container:
- `rest-api`: Backend API Service
- `kic-frontend`: Streamlit Frontend
- `kic-loader`: Data Loading Functions
- `qdrant/qdrant`: Vector Database

## 🛠️ Entwicklung

### Lokale Entwicklung

1. Repository klonen
2. Azure CLI Login durchführen
3. Entsprechende Umgebungsvariablen setzen
4. Terraform Commands ausführen

### CI/CD

Das Repository ist für GitOps-Workflows konfiguriert mit:
- Environment-spezifischen Backend-Konfigurationen
- Verschlüsselten Secrets
- Modularer Struktur für Wiederverwendbarkeit
---

**Hinweis**: Dies ist ein Infrastructure-Repository. Die Anwendungs-Code befindet sich dem Repo `kic-web-assistant`.