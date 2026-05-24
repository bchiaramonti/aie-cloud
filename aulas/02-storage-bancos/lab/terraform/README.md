# Terraform — Aula 2

Código IaC pronto para provisionar **toda a camada de dados** da Quantum Commerce:

- Storage Account + 3 containers (catálogo, imagens, logs) + lifecycle policy
- Azure SQL Database (Free Offer, auto-pause)
- Key Vault com a connection string do SQL como segredo
- Cosmos DB (Free Tier)
- Azure AI Search (SKU Free)

## Como usar (no Azure Cloud Shell)

```bash
# Ir para a pasta
cd ~/aie-cloud/aulas/02-storage-bancos/lab/terraform

# Gerar uma senha forte para o admin do SQL (não use senha trivial)
SQL_PASSWORD=$(openssl rand -base64 24)
echo "Senha gerada (guarde em local seguro): $SQL_PASSWORD"

# Inicializar providers
terraform init

# Ver o plano
terraform plan -var="sql_admin_password=$SQL_PASSWORD"

# Aplicar (provisiona TUDO de uma vez — ~8 min)
terraform apply -auto-approve -var="sql_admin_password=$SQL_PASSWORD"

# ... usar os recursos durante o lab ...

# Destruir tudo ao final (regra de ouro — custo zero)
terraform destroy -auto-approve -var="sql_admin_password=$SQL_PASSWORD"
```

## Arquivos

| Arquivo | O que define |
|---------|--------------|
| [main.tf](main.tf) | Providers, sufixo aleatório, Resource Group, locals |
| [variables.tf](variables.tf) | `location` e `sql_admin_password` |
| [outputs.tf](outputs.tf) | Nomes e endpoints consumidos pelos scripts Python |
| [storage.tf](storage.tf) | Storage Account + 3 containers + lifecycle |
| [sql.tf](sql.tf) | SQL Server + Database (Free Offer) + firewall rules |
| [keyvault.tf](keyvault.tf) | Key Vault + RBAC + segredo da connection string |
| [cosmos.tf](cosmos.tf) | Cosmos DB Account (Free Tier) + DB + container `reviews` |
| [search.tf](search.tf) | AI Search service (SKU Free) + 2 role assignments |

## Outputs disponíveis após `apply`

Pegue valores específicos com `terraform output -raw <nome>`:

```bash
terraform output -raw storage_account_name
terraform output -raw key_vault_name
terraform output -raw cosmos_endpoint
terraform output -raw search_endpoint
```

Os scripts Python em [../scripts/](../scripts/) consomem esses outputs via variáveis de ambiente.

## Observações

- **Free Tier limits:** Cosmos DB e AI Search permitem **apenas 1 instância free por assinatura**. Se o `apply` falhar nesses, leia o aviso em `cosmos.tf` / `search.tf`.
- **Auto-pausa do SQL Free:** o banco entra em standby após 60 min sem uso. A primeira query depois disso pode levar ~30s.
- **Custo:** com todos os Free Tiers ativos, o lab inteiro fica em ~$0 enquanto rodando. Não esqueça do `destroy` no final.
- **Senha do SQL:** sempre gere com `openssl rand -base64 24`. Nunca commite a senha. O Terraform usa `var.sql_admin_password` via `-var=`.
