# Karate Best Buy API Tests

Suíte de testes automatizados de API REST construída com **Karate DSL**, **JUnit 5** e **Maven**, utilizando a **Best Buy API Playground** como ambiente local de prática e portfólio.

---

## Stack & Ferramentas

- **Karate DSL:** `1.5.1` (`io.karatelabs:karate-junit5`)
- **Java:** Bytecode target **Java 21** (compatível com JDK 21+ / OpenJDK 27)
- **Build Tool:** Maven (`./mvnw` Wrapper incluído)
- **IDE recomendada:** IntelliJ IDEA
- **API alvo (local):** [Best Buy API Playground](https://github.com/BestBuy/api-playground) em `http://localhost:3030` (Swagger UI em `http://localhost:3030/docs/`)

---

## Adaptando cursos antigos (Eclipse + JUnit 4) para IntelliJ + Karate moderno

| Aspecto | Curso antigo (Eclipse) | Padrão atual (IntelliJ IDEA) |
| :--- | :--- | :--- |
| **Coordenada Maven** | `com.intuit.karate:karate-junit4` / `karate-apache` | `io.karatelabs:karate-junit5` (`1.5.1`) |
| **Runner Java** | `@RunWith(Karate.class)` (JUnit 4) | `@Karate.Test` (`com.intuit.karate.junit5.Karate`, JUnit 5) |
| **Java** | JDK 8 / 11 | JDK 17 ou 21+ |
| **IDE** | Eclipse + import Maven Project | IntelliJ IDEA (`File -> Open` diretamente na pasta do projeto) |
| **Plugin na IDE** | Cucumber / Karate para Eclipse | Plugin **Karate** no Marketplace do IntelliJ (`Settings -> Plugins`) |
| **Execução de teste único** | Run As -> JUnit Test | Clicar no ícone ▶ ao lado do método `@Karate.Test` ou direto no `Scenario:` |

> Nota: embora o pacote Maven oficial tenha migrado para `io.karatelabs`, as classes internas (como `com.intuit.karate.junit5.Karate` e o arquivo `karate-config.js`) mantêm os nomes originais para preservar compatibilidade com projetos existentes.

---

## Estrutura do Projeto

```text
karate-bestbuy-api-tests/
├── pom.xml
├── mvnw / mvnw.cmd
├── scripts/
│   └── api-playground.sh                 # Utilitário para iniciar, parar e resetar a API local
└── src/
    └── test/
        ├── resources/
        │   └── logback-test.xml          # Log limpo no console
        └── java/
            ├── karate-config.js          # Configuração global (baseUrl e timeouts)
            └── bestbuy/
                ├── BestBuyTest.java      # Runners JUnit 5 (@Karate.Test) por módulo
                ├── utilities/
                │   └── utilities.feature # GET /version e /healthcheck
                ├── products/
                │   ├── product-payload.json
                │   └── products.feature  # Paginação, $select, $sort, CRUD completo e validação 400
                ├── stores/
                │   └── stores.feature    # Filtros por estado/serviço e CRUD completo
                ├── categories/
                │   └── categories.feature# Hierarquia de categorias e CRUD completo
                └── services/
                    └── services.feature  # Listagem e CRUD completo
```

---

## Como preparar e rodar localmente

### 1. Pré-requisitos do ambiente local

A API **Best Buy API Playground** foi instalada em paralelo na pasta irmã `../api-playground` (`~/Documents/GitHub/api-playground`).

Para iniciar a API antes de rodar os testes:

```bash
./scripts/api-playground.sh start
```

Outros comandos úteis do utilitário:

```bash
./scripts/api-playground.sh status    # Verifica saúde da API e contagem de documentos
./scripts/api-playground.sh stop      # Encerra o servidor local da porta 3030
./scripts/api-playground.sh reset-db  # Restaura o dataset.sqlite original via Git
```

Swagger UI disponível enquanto o servidor estiver ativo: `http://localhost:3030/docs/`.

### 2. Executar os testes pelo terminal

```bash
# Toda a suíte
./mvnw test

# Apenas testes marcados com @smoke
./mvnw test -Dkarate.options="--tags @smoke"

# Apenas um runner específico (ex.: produtos)
./mvnw test -Dtest=BestBuyTest#testProducts

# Apontando para outra URL base (opcional)
./mvnw test -Dkarate.baseUrl=http://localhost:3030
```

### 3. Executar pelo IntelliJ IDEA

1. Abra a pasta `karate-bestbuy-api-tests` via **File -> Open** e aguarde a importação automática do `pom.xml`.
2. *(Opcional recomendado)* Instale o plugin **Karate** em **IntelliJ IDEA -> Settings -> Plugins -> Marketplace**.
3. Certifique-se de que a API local esteja ativa (`./scripts/api-playground.sh start` no terminal integrado do IntelliJ).
4. Abra [`BestBuyTest.java`](src/test/java/bestbuy/BestBuyTest.java) e clique no botão ▶ ao lado do método desejado (ou abra qualquer `.feature` diretamente caso o plugin Karate esteja instalado).

---

## Relatórios de Execução

Após qualquer execução, o Karate gera automaticamente relatórios HTML detalhados com linha do tempo de requisições, payloads e asserções:

```text
target/karate-reports/karate-summary.html
```
