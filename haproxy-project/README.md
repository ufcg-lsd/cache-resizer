# Projeto de TCC - Redimensionamento de Cache

> Este projeto busca servir como base para o estudo da disponibilidade e desempenho, de redimensionamento dinâmico de cache 
> utilizando o HAProxy como serviço de cache

Para inicializar o projeto, é necessário ter instalado o **docker** e o **docker compose**.

## Inicialização do projeto

Para buildar o projeto, execute o comando abaixo:

`docker compose up -d`

## Gerando massa de dados
Os arquivos no diretório /db servirão como banco de dados para a aplicação. O db.txt já está carregado com alguns dados.
Caso deseje adicionar mais dados, execute o comando abaixo

`sh ./input-db.sh`

Cada execução desse script adiciona 7000 dados ao db.txt.

## Teste de Carga
Para realizar teste de carga no projeto, execute o comando abaixo:

`sh ./load-test.sh <primeiro_id> <ultimo_id>`

Onde as variáveis primeiro_id e ultimo_id indicam o intervalo de ids no qual a API receberá uma requisição GET para 
armazenar em Cache. **Esse script ocorrerá em loop, realizando requisicoes para os ids nesse intervalo**

## Redimensionamento do cache
> Para realizar o redimensionamento do cache em tempo de execução, execute o curl abaixo, onde o novo_size_MB deve ser 
> o valor desejado para o novo tamanho do cache, em Megabytes. Inicialmente, o projeto está configurado para um cache de 
> 1024 MB.

`curl --location 'http://localhost:8200' --header 'Cache-Max-Size: <novo_size_MB>'`
