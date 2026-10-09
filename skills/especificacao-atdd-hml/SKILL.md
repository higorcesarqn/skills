---
name: especificacao-atdd-hml
description: "Gera, revisa e mantém especificações ATDD/Gherkin em português para PBIs e cards filhos no Azure DevOps, e conduz a validação funcional em HML com evidências rastreáveis. Use ao escrever critérios de aceitação, cenários Gherkin, matriz de cobertura, dados de teste, ou ao validar/aprovar um card antes do Done."
---

# Especificação ATDD e validação em HML

## Visão geral

Produza especificações de aceitação executáveis que permitam a outra pessoa (ou a uma IA) entender a regra negocial sem depender do desenvolvedor, saber onde e como testar, preparar os dados, executar cenários positivos/negativos/de permissão, distinguir evidência de frontend, backend e persistência, registrar evidências no card correto e concluir o card somente com todos os critérios aplicáveis comprovados.

Aplique esta skill **antes** do início do desenvolvimento e revise a especificação sempre que um PR alterar o comportamento previsto.

## Quando usar

- Escrever ou revisar descrição, regras de negócio e critérios de aceitação de um PBI.
- Detalhar Task, Bug, Issue, Debt ou UX/UI derivados de um PBI.
- Escrever cenários Gherkin, matriz de cobertura ou dados de teste.
- Executar a validação funcional em HML e decidir se o card pode ir para Done.

## Princípios obrigatórios

- O **PBI** contém o comportamento e o valor negocial esperado.
- Cada **filho** (Task, Bug, Issue, Debt, UX/UI) contém somente os cenários do esforço daquela camada, mantendo a referência ao comportamento do PBI.
- Escreva cenários observáveis. Nunca use resultados vagos como "funcionar corretamente", "salvar com sucesso" ou "exibir adequadamente".
- Informe dados de teste concretos ou uma receita determinística para criá-los.
- Informe ambiente, perfil e permissões necessários.
- Declare o estado inicial e o resultado final verificável.
- Separe validação de interface, regra de negócio, API e persistência quando forem responsabilidades diferentes.
- PR aprovado, teste unitário ou HTTP 200 **não** são prova suficiente de aceitação funcional isoladamente.
- Nunca marque Done quando um cenário obrigatório falhar, estiver bloqueado ou não puder ser reproduzido.
- Nunca altere dados de produção. Testes mutáveis somente em ambiente autorizado de homologação.

## Fluxo de trabalho

### 1. Ler e correlacionar o escopo

Antes de escrever cenários, analise:

- título, descrição, critérios de aceitação e validações anteriores do PBI;
- descrição e tipo de cada filho;
- comentários, anexos, imagens, protótipos e links da Wiki;
- PRs e commits associados;
- regras do módulo e perfis envolvidos;
- dependências com outros cards.

Se houver divergência entre PBI, filho, PR e comportamento atual, **registre a divergência**. Não invente a regra correta.

### 2. Criar a matriz de cobertura

Antes do Gherkin, produza esta tabela:

| Regra/critério | Cenário | Camada | Tipo | Prioridade | Card responsável |
|---|---|---|---|---|---|
| Regra observável | Nome inequívoco | Frontend, Backend, Integração, Persistência ou E2E | Positivo, Negativo, Permissão, Limite ou Regressão | Bloqueante ou Complementar | ID do PBI/filho |

Todo critério de aceitação deve ter pelo menos um cenário. Regras de bloqueio, permissão ou obrigatoriedade devem ter cenário positivo **e** negativo.

### 3. Escrever os cenários ATDD/Gherkin

Use português e esta estrutura:

```gherkin
Funcionalidade: <capacidade negocial do PBI>
  Como <perfil real>
  Quero <ação ou capacidade>
  Para <benefício negocial verificável>

  Contexto:
    Dado que estou no ambiente <CIDAX HML ou Ponta Porã HML>
    E estou autenticado como <perfil/permissão>
    E existe <dado inicial identificável ou receita para criá-lo>

  @PBI-0000 @TASK-0000 @frontend @bloqueante
  Cenário: <resultado negocial específico>
    Dado <estado inicial verificável>
    E <outra pré-condição necessária>
    Quando <ação única ou sequência indispensável>
    Então <resultado observável e objetivo>
    E <efeito persistido, resposta de API ou ausência de efeito indevido>
```

Regras de redação:

- `Dado` descreve situação existente, não ação de implementação.
- `Quando` descreve a ação do usuário ou evento do sistema.
- `Então` descreve comportamento verificável: texto, estado, quantidade, permissão ou dado persistido.
- Um cenário valida um comportamento principal.
- Use `Esquema do Cenário` quando a mesma regra variar por tipo de dado, perfil ou estado.
- Marque cenário bloqueante com `@bloqueante`.
- Vincule PBI e filho por tags, por exemplo `@PBI-2223 @TASK-2206`.

### 4. Definir os dados de teste

Para cada cenário, preencha:

| Campo | Conteúdo obrigatório |
|---|---|
| Ambiente | URL/base do HML correto |
| Perfil | Papel e permissões necessárias |
| Registro-base | Protocolo, camada, requerimento ou identificador conhecido |
| Como preparar | Passos ou endpoint autorizado para criar o estado inicial |
| Valores de entrada | Valores exatos usados no teste |
| Resultado esperado | Texto, estado, quantidade ou dado exato |
| Limpeza | Como desfazer ou identificar o dado criado |
| Reutilizável? | Sim/Não e restrições de concorrência |

Nunca dependa de "usar qualquer registro existente". Se o cenário exigir dado raro (subopção, geometria, pendência respondida, perfil específico), explique como localizar ou preparar esse dado.

### 5. Especificar evidências mínimas

Cada cenário declara antecipadamente o que provará sua aprovação:

- **Frontend:** captura antes/depois ou ação/resultado, com protocolo/identificador visível quando possível.
- **Backend/API:** requisição sanitizada, parâmetros relevantes, status e trecho mínimo da resposta que comprove a regra.
- **Persistência:** consulta somente leitura ou resposta posterior da API comprovando o valor salvo e a ausência de duplicidade.
- **Permissão:** evidência com perfil autorizado e com perfil não autorizado.
- **Erro/regra negativa:** mensagem apresentada e comprovação de que nenhuma alteração indevida ocorreu.

Não inclua tokens, cookies, senhas, CPFs reais ou dados sensíveis nas evidências.

### 6. Critério de aprovação do card

Classifique cada cenário como:

- `APROVADO` — resultado esperado integralmente comprovado;
- `REPROVADO` — comportamento divergiu do esperado;
- `BLOQUEADO` — pré-condição, acesso ou dado de teste indisponível;
- `NÃO APLICÁVEL` — somente com justificativa aderente ao escopo.

O card só pode ir para Done se:

- todos os cenários bloqueantes estiverem aprovados;
- nenhum cenário aplicável estiver reprovado;
- as regressões essenciais definidas estiverem aprovadas;
- as evidências estiverem anexadas ao próprio card;
- o campo **Validação da implementação** contiver executor, data, ambiente, cenários e resultado.

## Regras para execução da validação

1. Confirme qual build/PR está implantado antes de iniciar.
2. Execute somente cenários pertencentes ao card e à sprint solicitada.
3. Use a API para preparar ou verificar dados quando autorizado; use a interface para comprovar comportamentos visuais.
4. Registre o resultado de cada cenário, inclusive falhas e bloqueios.
5. Não infira aprovação a partir do código ou do título do card.
6. Se o comportamento falhar, não ajuste silenciosamente o critério para fazê-lo passar.
7. Se faltar dado de teste, registre exatamente qual dado/configuração precisa ser criado.
8. Anexe evidências legíveis e relacione-as ao cenário correspondente.
9. Atualize para Done somente após cumprir o critério de aprovação.
10. Produza relatório final com: aprovados, reprovados, bloqueados, cards alterados, cards preservados e defeitos encontrados.

## Verificação de qualidade da especificação

Antes de salvar no Azure DevOps, rejeite ou devolva para complementação qualquer especificação em que:

- não seja possível identificar o ambiente ou o perfil;
- não exista dado de teste ou forma de prepará-lo;
- o resultado esperado seja subjetivo;
- o cenário não esteja ligado a um critério e a um card;
- uma regra negativa não comprove ausência de efeito indevido;
- frontend e backend sejam tratados como automaticamente aprovados pela mesma evidência;
- não haja critério claro para decidir Done;
- o cenário dependa de conhecimento não registrado do desenvolvedor.

## Modelo — descrição do PBI

```markdown
## Contexto
<problema atual, usuários afetados e consequência negocial>

## Objetivo
<comportamento e benefício esperado>

## Escopo
- <regra incluída>

## Não escopo
- <limite explícito>

## Perfis e permissões
- <perfil>: <o que pode ou não pode fazer>

## Regras de negócio
- RN01 — <regra atômica e verificável>

## Critérios de aceitação
- CA01 — <resultado observável>

## Dados de teste necessários
- <registro, configuração ou receita de preparação>

## Cenários ATDD/Gherkin
<cenários completos>

## Rastreabilidade
- Feature/Epic:
- Filhos responsáveis pelos cenários:
- Wiki/protótipo:
- PRs:

## Prints/protótipos
<anexos pertinentes>
```

## Modelo — descrição de Task, Bug, Issue ou Debt

```markdown
## Objetivo do esforço
<resultado desta camada e relação com o PBI>

## Responsabilidade desta camada
- <comportamento técnico observável>
- <contrato, componente, rota ou persistência afetada>

## Fora da responsabilidade desta camada
- <o que será comprovado em outro filho>

## Cenários vinculados
- <ID/nome dos cenários do PBI cobertos por este filho>

## Dados e pré-condições
- Ambiente:
- Perfil:
- Registro-base:
- Preparação:
- Limpeza:

## Gherkin executável
<cenários específicos desta camada>

## Evidências exigidas
- <captura/interface, API, persistência, permissão etc.>

## Regressões mínimas
- <comportamento anterior que não pode quebrar>

## Rastreabilidade técnica
- Branch:
- PR:
- Commit:
- Build/versão implantada no HML:
```

## Modelo — campo "Validação da implementação"

```html
<h3>&lt;Executor&gt; em DD/MM/AAAA</h3>
<p><strong>Ambiente:</strong> CIDAX HML / Ponta Porã HML</p>
<p><strong>Build/PR testado:</strong> número ou identificação disponível</p>
<p><strong>Dados utilizados:</strong> protocolo/registro sanitizado e perfil</p>
<ul>
  <li><strong>Cenário X:</strong> APROVADO — resumo objetivo.</li>
  <li><strong>Cenário Y:</strong> REPROVADO — diferença encontrada.</li>
</ul>
<p><strong>Regressões:</strong> resumo das verificações realizadas.</p>
<p><strong>Conclusão:</strong> aprovado, reprovado ou bloqueado.</p>
<p><img src="URL_DO_ANEXO" alt="Evidência do cenário X" /></p>
```

## Exemplo completo

```gherkin
Funcionalidade: Pesquisar requerimentos por protocolo
  Como colaborador do Licenciamento Urbano
  Quero localizar um requerimento pelo protocolo completo ou por parte dele
  Para acessar rapidamente o processo correto

  Contexto:
    Dado que estou autenticado no CIDAX HML como Administrador
    E existe o requerimento de protocolo "ALV2026000014"
    E estou na tela "Licenciamento Urbano > Requerimentos"

  @PBI-2223 @ISSUE-2284 @ISSUE-2285 @e2e @bloqueante
  Esquema do Cenário: Localizar por diferentes partes do protocolo
    Quando informo "<termo>" no campo "Pesquisar protocolo ou equipe"
    Então a lista deve apresentar o protocolo "ALV2026000014"
    E todos os registros apresentados devem conter o termo pesquisado em um dos campos cobertos pela busca

    Exemplos:
      | termo          |
      | ALV2026000014  |
      | ALV            |
      | 2026000014     |

  @PBI-2223 @ISSUE-2284 @ISSUE-2285 @negativo @bloqueante
  Cenário: Informar termo inexistente
    Quando informo "PROTOCOLO-INEXISTENTE-999" no campo de pesquisa
    Então a lista deve apresentar zero registros
    E deve exibir a mensagem de nenhum registro encontrado
    E não deve apresentar registros da consulta anterior
```