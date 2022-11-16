Todas as possíveis combinações de entrada:

Entrada:  0I  1I  2I  3I
Entrada:  0I  1I  3I  2I 
Entrada:  0I  2I  1I  3I
Entrada:  0I  2I  3I  1I 
Entrada:  0I  3I  1I  2I 
Entrada:  0I  3I  2I  1I 
Entrada:  1I  0I  2I  3I
Entrada:  1I  0I  3I  2I 
Entrada:  1I  2I  0I  3I
Entrada:  1I  2I  3I  0I 
Entrada:  1I  3I  0I  2I 
Entrada:  1I  3I  2I  0I 
Entrada:  2I  0I  1I  3I
Entrada:  2I  0I  3I  1I 
Entrada:  2I  1I  0I  3I
Entrada:  2I  1I  3I  0I 
Entrada:  2I  3I  0I  1I 
Entrada:  2I  3I  1I  0I 
Entrada:  3I  0I  1I  2I 
Entrada:  3I  0I  2I  1I 
Entrada:  3I  1I  0I  2I 
Entrada:  3I  1I  2I  0I 
Entrada:  3I  2I  0I  1I 
Entrada:  3I  2I  1I  0I 

________________________

! APENAS CHAMADOS INTERNOS
________________________

AndarAtual = terreo

Entrada: 1I 2I 3I
Saída: 1 2 3

---------

Entrada: 1I 3I 2I
Saída: 1 2 3

---------

Entrada: 3I 2I 1I
Saída: 1 2 3

---------

Entrada: 3I 2I 0I
Saída: 0 2 3

_____________________________

AndarAtual = primeiro

Entrada: 0I 1I 2I 3I
Saída: 0 1 2 3

-----------

Entrada: 3I 2I 1I 0I
Saída: 2 3 1 0

-----------

Entrada: 3I 0I 2I 1I
Saída: 2 3 1 0

-----------

Entrada: 1I 0I 2I 3I
Saída: 1 0 2 3

-----------

Entrada: 0I 3I 2I 1I
Saída: 0 1 2 3

___________________________

Andar Atual = segundo

Entrada: 0I 1I 2I 3I
Saída: 1 0 2 3

-----------

Entrada: 3I 2I 1I 0I
Saída: 3 2 1 0

-----------

Entrada: 3I 0I 2I 1I
Saída: 3 2 1 0

-----------

Entrada: 1I 0I 2I 3I
Saída: 1 0 2 3

-----------

Entrada: 0I 3I 2I 1I
Saída: 0 1 2 3

___________________________

Andar Atual = terceiro

Entrada: 0I 1I 2I 3I
Saída: 2 1 0 3

-----------

Entrada: 3I 2I 1I 0I
Saída:  2 1 0 3

-----------

Entrada: 3I 2I 0I 1I
Saída: 2 1 0 3

-----------

Entrada: 3I 1I 0I 2I
Saída: 2 1 0 3

-----------

Entrada: 1I 0I 2I 3I
Saída: 2 1 0 3

-----------

Entrada: 2I 3I 1I 0I
Saída: 2 1 0 3

________________________

! APENAS CHAMADOS EXTERNOS
________________________

AndarAtual = terreo

Entrada: 0E 1E 2E 3E
Saída: 0 3 2 1

-----------

Entrada: 3E 2E 1E 0E
Saída:  3 2 1 0

-----------

Entrada: 3E 2E 0E 1E
Saída: 3 2 1 0

-----------

Entrada: 3E 1E 0E 2E
Saída: 3 2 1 0

-----------

Entrada: 1E 0E 2E 3E
Saída: 3 2 1 0

-----------

Entrada: 2E 3E 1E 0E
Saída: 3E 2E 1E 0E

________________________

AndarAtual = primeiro

Entrada: 0E 1E 2E 3E
Saída: 0 3 2 1

-----------

Entrada: 3E 2E 1E 0E
Saída:  3 2 1 0

-----------

Entrada: 3E 2E 0E 1E
Saída: 3 2 1 0

-----------

Entrada: 3E 1E 0E 2E
Saída: 3 2 1 0

-----------

Entrada: 1E 0E 2E 3E
Saída: 1 3 2 0

-----------

Entrada: 2E 3E 1E 0E
Saída: 3 2 1 0

________________________

AndarAtual = segundo

Entrada: 0E 1E 2E 3E
Saída: 1 0 3 2

-----------

Entrada: 3E 2E 1E 0E
Saída:  3 2 1 0

-----------

Entrada: 3E 2E 0E 1E
Saída: 3 2 1 0

-----------

Entrada: 3E 1E 0E 2E
Saída: 3 2 1 0

-----------

Entrada: 1E 0E 2E 3E
Saída: 1 0 3 2

-----------

Entrada: 2E 3E 1E 0E
Saída: 2 3 1 0

________________________
AndarAtual = terceiro

Entrada: 0E 1E 2E 3E
Saída: 2 1 0 3

-----------

Entrada: 3E 2E 1E 0E
Saída:  3 2 1 0

-----------

Entrada: 3E 2E 0E 1E
Saída: 3 2 1 0

-----------

Entrada: 3E 1E 0E 2E
Saída: 3 2 1 0

-----------

Entrada: 1E 0E 2E 3E
Saída: 2 1 0 3

-----------

Entrada: 2E 3E 1E 0E
Saída: 2 1 0 3

________________________

! CHAMADOS INTERNOS E EXTERNOS
________________________

AndarAtual = terreo

ntrada: 0I 1E 2I 3E
Saída: 0 2 3 1

-----------

Entrada: 3E 2I 1E 0I
Saída: 2 0 3 1 

-----------

Entrada: 3I 2E 0I 1E
Saída: 3 2 1 0

-----------

Entrada: 3I 1E 0E 2I
Saída: 3 2 10

-----------

Entrada: 1I 0I 2E 3E
Saída: 0 1 3 2

-----------

Entrada: 2I 3I 1E 0E
Saída: 2 3 1 0

_____________________________

AndarAtual = primeiro

_____________________________

Entrada: 0I 1E 2I 3E
Saída:  0 2 3 1

-----------

Entrada: 3E 2I 1E 0I
Saída: 2 0 3 1

-----------

Entrada: 3I 2E 0I 1E
Saída: 3 0 2 1

-----------

Entrada: 3I 1E 0E 2I
Saída: 2 3 1 0

-----------

Entrada: 1I 0I 2E 3E
Saída: 1 0 3 2

-----------

Entrada: 2I 3I 1E 0E
Saída: 2 3 1 0

___________________________

AndarAtual = segundo

Entrada: 0I 1E 2I 3E
Saída: 1 0 2 3 

-----------

Entrada: 3E 2I 1E 0I
Saída: 3 2 1 0

-----------

Entrada: 3I 2E 0I 1E
Saída: 3 2 1 0

-----------

Entrada: 3I 1E 0E 2I
Saída: 3 2 1 0

-----------

Entrada: 1I 0I 2E 3E
Saída: 1 0 3 2

-----------

Entrada: 2I 3I 1E 0E
Saída: 2 3 1 0

_________________________

AndarAtual = terceiro

________________________

Entrada: 0I 1E 2I 3E
Saída: 2 1 0 3

-----------

Entrada: 3E 2I 1E 0I
Saída: 3 2 1 0

-----------

Entrada: 3I 2E 0I 1E
Saída: 3 2 1 0

-----------

Entrada: 3I 1E 0E 2I
Saída: 3 2 1 0

-----------

Entrada: 1I 0I 2E 3E
Saída: 2 1 0 3 

-----------

Entrada: 2I 3I 1E 0E
Saída: 2 1 0 3