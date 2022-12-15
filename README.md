# EstaciOne
Projeto Final da disciplina de Microcontroladores e Aplicações (2022.1)

### Alunos:
- José Ferreira Leite Neto (19111153)

- Lilian Giselly Pereira Santos (19111115)

- Lucas Lemos Cerqueira de Freitas (19111116)

- Pedro Henrique de Brito Nascimento (19111287)

## Descrição
O EstaciOne é um projeto de estacionamento inteligente que reconhece a chegada do veículo, encontra a melhor vaga (a mais próxima da entrada para pedestres do estabelecimento) que esteja disponível, informa qual é e repassa o caminho até ela para o veículo. Já o veículo, equipado com um sensor de luminosidade, consegue reconhecer através das faixas no chão se está seguindo o caminho correto até o seu destino.

## Objetivos
Dentre os objetivos do projeto, podemos destacar:

- Construção de uma maquete com 7 vagas (quatro de cada lado),
equipadas com sensores ultrassônicos para identificar se existe ou
não veículo estacionado (algumas das vagas não terão o sensor por
limitações de viabilidade);

- Construção de cancela equipada com botão para identificar a chegada
do veículo e display LCD para exibir informações;

- Construção de veículo com sensor de luminosidade e LEDs que
indicam se o caminho correto até a vaga está sendo seguido;

- Viabilização da comunicação serial entre o microcontrolador que está
controlando o estacionamento e o que está no veículo, para
transmissão da informação da vaga e do caminho a ser percorrido até
ela.

## Requisitos
Dentre os requisitos que o projeto considera, podemos frisar:

- O motorista chega até a cancela e pressiona o botão da mesma
solicitando uma vaga;

- A vaga é exibida no painel (display LCD), junto à mensagem de
boas-vindas, durante um período de 6 segundos;

- A cancela abre após este período, permitindo a passagem do veículo e
se fecha após 6 segundos;

- O veículo se movimenta sem interferência do sistema (no caso, sendo
movido manualmente) pelos segmentos de reta de diferentes cores,
conforme mapeamento de cores das vagas;
○ Um LED RGB mostra a cor identificada na faixa, enquanto um
Buzzer (ou LED) mostra o feedback sobre o caminho que está
sendo seguido (se está correto ou não) para a vaga destino.

- Ao chegar na vaga, o sistema identifica a mesma como ocupada
através de seus sensores e não a disponibiliza para outros veículos
até que seja liberada.
O sistema não contará com os seguintes recursos:

- A chegada do veículo na cancela não será identificada
automaticamente (é necessário pressionar o botão);

- O veículo não irá percorrer o caminho de maneira autônoma (é
necessário percorrer manualmente);

- O caminho não será “remapeado” em caso de rota incorreta (caso se
distancie muito da rota, é necessário percorrer do início novamente);

- O sistema não terá comunicação com o veículo em outro momento
que não na transmissão serial na cancela;

- Nem todas as vagas terão sensores ultrassônicos de ocupação por
limitações de viabilidade (na maquete, alguns veículos ficarão “fixos”
nessas vagas para deixar essa situação verossímil).

## Diagrama do sistema
O diagrama abaixo ilustra o que se espera do sistema. Cores e layout podem ter pequenas variações:

![image](https://user-images.githubusercontent.com/32825974/207734920-4820d8e4-2759-4f3b-91c7-db2de857e600.png)
