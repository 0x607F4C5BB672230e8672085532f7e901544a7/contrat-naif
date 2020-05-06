pragma solidity ^0.6;

contract Ballot {
    
    
    
    
    
    
    
    
    
    
    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal returns (string memory){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    uint i;
    for (i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
}

function strConcat(string memory _a, string memory _b, string memory _c) internal returns (string memory) {
    return strConcat(_a, _b, _c, "", "");
}

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //Ptits fonctions pour faire bien
    
    //Imposer une étape précise
    modifier etape(uint _indiceOrdre, uint _etape) {
        require(_etape == listeOrdre[_indiceOrdre].etape);
        _;
        listeOrdre[_indiceOrdre].etape++;
    }
    //On a que 3 étapes
    modifier contrat_fini(uint _indiceOrdre) {
        require(listeOrdre[_indiceOrdre].etape == 3);
        _;
    }
    //Imposer qu'on soit alice
    modifier est_alice(uint _indiceOrdre) {
        require(msg.sender == listeOrdre[_indiceOrdre].adresseAlice);
        _;
    }
    //Imposer qu'on soit bob
    modifier est_bob(uint _indiceOrdre) {
        require(msg.sender == listeOrdre[_indiceOrdre].adresseBob);
        _;
    }
    modifier paiement_alice(uint _indiceOrdre) {
        require(msg.value == listeOrdre[_indiceOrdre].lockAlice);
        _;
    }
    modifier paiement_bob(uint _indiceOrdre) {
        require(msg.value == listeOrdre[_indiceOrdre].lockBob);
        _;
    }
    
    
    //Structure de l'ordre que va poser Alice
    struct Ordre {
        //S'incrément progressivement au fur et à mesure de l'execution
        uint etape;
        //Etape 0
        uint pow;
        uint lockAlice;
        uint lockBob;
        address payable adresseAlice;
        //Etape 1
        address payable adresseBob;
        //Etape 2
        string hash;
        //Etape 3
        string reponse;
        
    }
    
    //La liste des ordres qui sont posés
    Ordre[] public listeOrdre;
    
    //Pour créer un ordre sur la marketplace
    function creer_un_ordre(uint _pow, uint _lockAlice, uint _lockBob) public {
        listeOrdre.push(Ordre(0, _pow, _lockAlice, _lockBob, msg.sender, msg.sender, "", ""));
    }
    
    //Pour prendre un ordre qui a été posé sur la marketplace
    function prendre_un_ordre(uint _indiceOrdre) public etape(_indiceOrdre, 0) payable paiement_bob(_indiceOrdre) {
        Ordre storage ordrePris = listeOrdre[_indiceOrdre];
        ordrePris.adresseBob = msg.sender;
        //On retire l'argent de bob. Askip c'est fait automatiquement
    }
    
    //Une fois l'ordre accepté Alice peut préciser son ordre
    function preciser_un_ordre(uint _indiceOrdre, string memory _hash) public est_alice(_indiceOrdre) etape(_indiceOrdre, 1) payable paiement_alice(_indiceOrdre) {
        Ordre storage ordrePris = listeOrdre[_indiceOrdre];
        ordrePris.hash = _hash;
    }
    
    //Maintenant Bob peut donner le résultat de son calcul
    function completer_un_ordre(uint _indiceOrdre, string memory _reponse) public est_bob(_indiceOrdre) etape(_indiceOrdre, 2) {
        Ordre memory ordrePris = listeOrdre[_indiceOrdre];
        string memory solution = strConcat(ordrePris.hash, "-", _reponse);
        uint nombre = uint(keccak256(abi.encodePacked(solution)));
        //Si c'est pas bon on return
        if (nombre != ordrePris.pow) {
            return;
        }
        //Sinon on rends l'argent aux abonnés. Ce que les deux ont lock
        ordrePris.adresseBob.transfer(ordrePris.lockAlice + ordrePris.lockBob);
        
        //Si ça a pas fail d'ici la on stock la réponse
        ordrePris.reponse = _reponse;
    }
    
    //Une fois l'ordre final on veut voir la réponse
    function voir_reponse(uint _indiceOrdre) public view contrat_fini(_indiceOrdre) returns (string memory) {
        return listeOrdre[_indiceOrdre].reponse;
    }
}



