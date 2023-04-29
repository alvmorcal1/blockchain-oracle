pragma solidity >=0.4.21 <0.6.0;

contract Oracle {
  uint minQuorum = 3;
  Request[] requests;
  uint totalOracleCount = 3;
  uint currentId = 0;  


  struct Request {
    uint id;
    string urlToQuery;
    string attributeToFetch;
    string agreedValue;
    mapping(uint => string) anwers;
    mapping(address => uint) quorum;
  }


  event NewRequest (
    uint id,
    string urlToQuery,
    string attributeToFetch
  );


  event UpdatedRequest (
    uint id,
    string urlToQuery,
    string attributeToFetch,
    string agreedValue
  );

  function createRequest (
    string memory _urlToQuery,
    string memory _attributeToFetch
  )
  public
  {
    uint lenght = requests.push(Request(currentId, _urlToQuery, _attributeToFetch, ""));
    Request storage r = requests[lenght-1];

    r.quorum[address(0x6c2339b46F41a06f09CA0051ddAD54D1e582bA77)] = 1;
    r.quorum[address(0xb5346CF224c02186606e5f89EACC21eC25398077)] = 1;
    r.quorum[address(0xa2997F1CA363D11a0a35bB1Ac0Ff7849bc13e914)] = 1;

    emit NewRequest (
      currentId,
      _urlToQuery,
      _attributeToFetch
    );

    currentId++;
  }

  function updateRequest (
    uint _id,
    string memory _valueRetrieved
  ) public {

    Request storage currRequest = requests[_id];

    if(currRequest.quorum[address(msg.sender)] == 1){

      currRequest.quorum[msg.sender] = 2;

      uint tmpI = 0;
      bool found = false;
      while(!found) {
        if(bytes(currRequest.anwers[tmpI]).length == 0){
          found = true;
          currRequest.anwers[tmpI] = _valueRetrieved;
        }
        tmpI++;
      }

      uint currentQuorum = 0;

      for(uint i = 0; i < totalOracleCount; i++){
        bytes memory a = bytes(currRequest.anwers[i]);
        bytes memory b = bytes(_valueRetrieved);

        if(keccak256(a) == keccak256(b)){
          currentQuorum++;
          if(currentQuorum >= minQuorum){
            currRequest.agreedValue = _valueRetrieved;
            emit UpdatedRequest (
              currRequest.id,
              currRequest.urlToQuery,
              currRequest.attributeToFetch,
              currRequest.agreedValue
            );
          }
        }
      }
    }
  }
}
