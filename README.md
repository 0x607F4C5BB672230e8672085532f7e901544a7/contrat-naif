# contrat-naif

## tldr

Je me souvenais plus trop ce dont on avait parlé donc j'ai essayé de faire une marketplace où ça vends de la puissance de calcul pour faire une preuve de travail.  
On nomme Alice celle qui pose l'ordre, et Bob celui qui le prends.

En résumé Alice pose un ordre pour que qqn réalise une certaine preuve de travail.
Bob prends l'ordre et bloque de l'argent qui se reversé à Alice si il réalise pas la tache.
Alice précise la tache et bloque de l'argent qui sera reversé à Bob quand il aura fait la tache.
Bob push le résultat sur la chaine, et recupère son argent et celui d'Alice.

## Détails pour l'implémentation

La liste des ordres est stoquée dans Ordre[] public listeOrdre;  
Chacun de ses ordre a une variable Ordre.etape qui symbolise où en est l'ordre. Au début l'ordre est à l'étape 0, quand qqn le prends il passe à l'étape 1, et ainsi de suite. Du coup on peut prendre un ordre seulement si il est à l'étape 0, et ainsi de suite. 

#### Modifiers

Pour imposer ce méchanisme des étapes il y a le modifier etape(uint \_indiceOrdre, uint \_etape) qui vérifie si on est à la bonne étape, execute le contrat, puis incrémente l'étape (ça je suis pas sur que ça s'execute comme ça mais j'imagine).

On a également deux modifiers est_alice(uint \_indiceOrdre) et est_bob(uint \_indiceOrdre) qui impose que celui qui appelle la fonction soit celui qui a posé l'ordre (Alice) et celui qui a pris l'ordre (Bob).

Et enfin pour bloquer l'argent on a paiement_alice(uint \_indiceOrdre) et paiement_bob(uint \_indiceOrdre) qui bloque l'argent de Alice et de Bob.

Enfin on a contrat_fini(uint \_indiceOrdre) qui impose que le contrat soit à l'étape 3, c'est utile pour la fonction view voir_reponse(uint \_indiceOrdre) qui permets à Alice de récupérer le résultat de son calcul.

## Déroulement du contrat

Deux participants : Alice et Bob

#### Etape -1 : Alice pose un ordre sur la marketplace. Fonction creer_un_ordre(uint \_pow, uint \_lockAlice, uint \_lockBob)

Elle précise la preuve de travail qui doit être effectuée. C'est l'argument \_pow qui sera Ordre.pow !  
Elle précise combien d'argent elle va payer. C'est l'argument \_lockAlice qui sera Ordre.lockAlice !  
Elle précise combien d'argent Bob va lock. C'est l'argument \_lockBob qui sera Ordre.lockBob !  
Enfin ça retient l'adresse d'Alice pour que elle seule (avec Bob) puisse agir sur ce contrat. Ce sera Ordre.adresseAlice !

Le reste des arguments de la struct est rempli de valeurs par défaut

#### Etape 0 : Bob prends un ordre de la marketplace. Fonction prendre_un_ordre(uint \_indiceOrdre)

\_indiceOrdre indique à quel contrat on fait référence. C'est l'indice du tableau listeOrdre.  
Cette fonction bloque l'argent de Bob, et modifie dans Ordre l'adresse que le contrat va payer si le contrat s'execute correctement.  
Ainsi l'adresse de Bob sera Ordre.adresseBob !

#### Etape 1 : Alice précise l'ordre de la marketplace qu'elle avait déjà posé et qu'on lui a pris. Fonction preciser_un_ordre(uint \_indiceOrdre, string memory \_hash)

\_hash précise la chaine sur la laquelle effectuer la preuve de travail. Ce sera Ordre.hash !

#### Etape 2 : Bob complète l'ordre. Fonction completer_un_ordre(uint \_indiceOrdre, string memory \_reponse)

Le contrat vérifie si la preuve de travail est ok (bon ça j'ai pas fait du coup même si ça doit pas être loin).  
Et si la preuve de travail est ok ça paye Bob et stoque la blockchain dans la blockchain. Ce sera Ordre.reponse !

#### Etape 3 : Alice récupère le résultat du calcul. Fonction voir_reponse(uint \_indiceOrdre) view

Si le contrat est terminé cette fonction view renvoit ce que Bob avait push pour remplir le contrat.



