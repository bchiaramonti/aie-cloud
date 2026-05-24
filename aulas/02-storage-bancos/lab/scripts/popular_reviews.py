"""
Aula 2 / Atividade 3-A — Inserir 30 reviews fictícias da QC no Cosmos DB.

Demonstra:
- Cliente Cosmos com DefaultAzureCredential (sem chave hardcoded).
- Upsert de documentos com partition key.
- Query particionada.

Variáveis de ambiente necessárias:
    COSMOS_ENDPOINT — endpoint do Cosmos DB (terraform output -raw cosmos_endpoint)

Dependências:
    pip install --user azure-identity azure-cosmos
"""

import os
import random

from azure.cosmos import CosmosClient
from azure.identity import DefaultAzureCredential

# Templates de reviews — variados por sentimento
TEMPLATES = [
    ("Adorei! Chegou rápido e funcionou perfeitamente.", 5),
    ("Produto excelente, recomendo demais.", 5),
    ("Cumpre o que promete, vale a pena pelo preço.", 4),
    ("Bom produto, mas a embalagem chegou amassada.", 4),
    ("Funciona ok, nada de especial.", 3),
    ("Esperava mais pelo valor pago.", 2),
    ("Decepcionante, não recomendo.", 1),
    ("Veio com defeito, tive que trocar.", 1),
    ("Maravilhoso, superou expectativas!", 5),
    ("Compraria de novo, ótimo custo-benefício.", 5),
]


def main():
    endpoint = os.environ["COSMOS_ENDPOINT"]
    credential = DefaultAzureCredential()

    client = CosmosClient(endpoint, credential=credential)
    db = client.get_database_client("qc-db")
    container = db.get_container_client("reviews")

    print(f"→ Inserindo 30 reviews em {endpoint}...")

    random.seed(42)
    inseridos = 0
    for i in range(1, 31):
        produto_id = random.randint(1, 20)
        texto, score = random.choice(TEMPLATES)
        review = {
            "id": f"r-{i:03d}",
            "produto_id": str(produto_id),
            "score": score,
            "texto": texto,
            "cliente": f"cliente-{random.randint(100, 999)}",
        }
        container.upsert_item(review)
        inseridos += 1

    print(f"✓ {inseridos} reviews inseridas")

    # Query: reviews positivas do produto 5
    print("\n=== Reviews 4+ do produto 5 ===")
    query = "SELECT * FROM c WHERE c.produto_id = @pid AND c.score >= 4"
    items = list(
        container.query_items(
            query=query,
            parameters=[{"name": "@pid", "value": "5"}],
            enable_cross_partition_query=False,
        )
    )
    for r in items:
        print(f"  [score {r['score']}] {r['texto']}")


if __name__ == "__main__":
    main()
