pragma solidity ^0.6;

contract Ballot {
    
    //On dit qu'on a un truc qui vérifie addresse et signature du coup
    function verify(address _adresse, string memory _signature) public view returns(bool) {
        return true;
    }
    
    //Structure du jeu entre les deux joueurs
    //Du coup ils se mettent d'accord en dehors de la chaine et ensuite qqn push le truc ici
    //Leurs signatures sont vérifiés lors de la creation de l'ordre
    struct Ordre {
        //Les adresses des deux joueurs
        address alice;
        address bob;
        //Les coups que vont jouer les joueurs
        uint coup_alice;
        uint coup_bob;
        //Le gagnant
        uint fin; //0 pas fini, 1 alice gagnante, 2 bobo gagnant
        uint date;
    }
    
    //La liste des ordres qui sont posés
    Ordre[] public listeOrdre;
    
    //Pour créer un ordre sur la marketplace
    function creer_un_ordre(address _alice, string memory _sig_alice, address _bob, string memory _sig_bob) public {
        require(verify(_alice, _sig_alice));
        require(verify(_bob, _sig_bob));
        listeOrdre.push(Ordre(_alice, _bob, 0, 0, 0, now));
    }
    
    //Pour prendre un ordre qui a été posé sur la marketplace
    function prendre_un_ordre(uint _indiceOrdre, bool _alice, string memory _sig, uint coup) public {
        Ordre storage ordre = listeOrdre[_indiceOrdre];
        if (_alice) {
            require(verify(ordre.alice, _sig));
            ordre.coup_alice = coup;
        } else {
            require(verify(ordre.bob, _sig));
            ordre.coup_bob = coup;
        }
    }
    
    //Une fois l'ordre accepté Alice peut préciser son ordre
    function resoudre_lordre(uint _indiceOrdre, uint _fin) public {
        Ordre storage ordre = listeOrdre[_indiceOrdre];
        require(ordre.fin == 0);
        //On regarde si le jeu est terminé
        if (ordre.coup_alice != 0 && ordre.coup_bob != 0) {
            if (ordre.coup_alice > ordre.coup_bob) {
                ordre.fin = 1;
            } else {
                ordre.fin = 2;
            }
        }
        //Si les deux joueurs n'ont pas push on resouds que si on a le droit
        if (now - ordre.date > 1 days) {
            //On regarde si l'ordre push est valide
            if (_fin == 1 || _fin == 2) {
                ordre.fin = _fin;
            }
        }
    }
}



