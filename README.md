# Importação de BAPI_SALESORDER_CREATEFROMDAT2 #

[![N|Solid](https://wiki.scn.sap.com/wiki/download/attachments/1710/ABAP%20Development.png?version=1&modificationDate=1446673897000&api=v2)](https://www.sap.com/brazil/developer.html)

Esta rotina contempla o tratamento da tabela ```extensionin para BAPI``` de _Criação de Ordem de Vendas_.
~~Quando Deus der coragem~~ Futuramente eu vou melhorar o código e melhorar a documentação.

## Necessidade ##
Adicionar campos Z durante a Criação da Ordem de Vendas pela BAPI Standard.

## Tecnologia adotada ##
ABAP usando uma classe com um metodos staticos.

## Solução ##
Para que a solução tenha um bom aproveitamento de código, como parâmetros temos:
- O campo referente ao item;
- O valor do campo referente ao item;
- O campo que iremos atribuir valor;
- A estrutura do campo que iremos atribuir valor;
- O valor que iremos atribuir a este campo;

Para a opção de alteração também teremos uma tabela extensionin que sera alterada pelo método.

Esta rotina, em sua versão inicial, contempla apenas campos a nível de itens. Em novas atualizações ira contemplar também a nível de cabeçalho. Claro que o código esta aberto a contribuições.

```abap
zcl_sd_extensionin=>add_value(
  exporting
    item_field  = 'POSNR'
    item_value  = item-posnr
    field       = 'ZCA_PDEN'
    structure   = 'BAPE_VBAP'
    value       = item-zca_pden
  changing
    extensionin = tov_extensionin[]
) .
```
## Estruturas envolvidas ##

Fabio Henrique Cirino Silva
fabio.cirino@agrex.com.br
    

#### BAPI extensionin (Nivel de cabeçalho) ####
- VBAKKOZ - Campos de comunicação - cabeçalho: modificações cliente
- VBAKKOZX - Campos de comunicação - cabeçalho: modificações cliente
- BAPE_VBAK - Interface BAPI para extensões de cliente para tabela VBAK
- BAPE_VBAKX - Lista de seleção BAPI p/ampliações do cliente p/tabela VBAK

#### BAPI extensionin VBAP (Nivel de Item) ####
- VBAPKOZ - Campos de comunicação item: modificações cliente
- VBAPKOZX - Campos de comunicação item: modificações cliente
- BAPE_VBAP - Interface BAPI para extensões de cliente para tabela VBAP
- BAPE_VBAPX - Lista de seleção BAPI p/ampliações do cliente p/tabela VBAP

#### BAPI extensionin VBEP (Nivel de Item) ####
- VBEPKOZ - Campos modificação divisão rem.: modificações de cliente
- VBEPKOZX - Campos de seleção divisão de remessas: modificações cliente
- BAPE_VBEP - Interface BAPI para extensões de cliente para tabela VBEP
- BAPE_VBEPX - Lista de seleção BAPI p/ampliações do cliente p/tabela VBEP
