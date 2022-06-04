//"SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.8.4;

contract wallet{
  event deposit(address indexed sender, uint indexed value);
  event submit(uint indexed txid);
  event approved(address indexed sender, uint txid);
  event revoke(address indexed sender, uint txid);
  event executed(uint indexed txid);  
    address[] public owners;
    mapping (address => bool) public isOwner;
    mapping (uint => mapping ( address => bool)) public respond;
   
   
    struct trans{
        address to;
        uint _value;
        bool execute;
    } 

    trans[] public tran;
    uint res;
    //modifiers
    modifier onlyOwner() {

        require(isOwner[msg.sender], "not owner");
        _;
    }
    modifier txexist(uint txid){
        require(txid < tran.length,"does not exist");
        _;
    }
      modifier notapproved(uint txid){
        require(!respond[txid][msg.sender] ,"already approved");
        _;
    }
    modifier notexecuted(uint txid){
        require(!tran[txid].execute ,"already executed");
        _;
    }
  
    //

    constructor(address[] memory _owners, uint _res) {
        require( _owners.length > 0 , "require owners");
        require(  res> 0 && res < _owners.length , "require owners");

        for(uint i=0; i< _owners.length; ++i){
            address owner= _owners[i];
            require(!isOwner[owner],"owner is not unique" );
            require(owner !=address(0), "invalid owner");
            isOwner[owner]=true;
            owners.push(owner);
            res=_res;
        }
    }

    receive() payable external{
        emit deposit(msg.sender, msg.value);
    }

    function Submit(address _to , uint value) public onlyOwner{
        uint txid= tran.length;
        tran.push(trans({
            to: _to,
        _value: value,
         execute: false
        }));
            emit submit(txid);
    }
    function approve(uint txid) public txexist(txid)
      notapproved(txid)
      notexecuted(txid) 
      {
            respond[txid][msg.sender]=true;
            emit approved(msg.sender , txid);
    }
    function countapproved(uint _txid) private view returns (uint count){
        for (uint i=0; i < owners.length; ++i){
            if(respond[_txid][owners[i]]){
                count+=1;
            }
        }
    } 
        function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txexist(_txIndex)
        notexecuted(_txIndex)
    {
    trans storage tran = tran[_txIndex];


        tran.execute = true;


        emit executed( _txIndex);
    }

    function Revoke(uint txid) public
    onlyOwner
    txexist(txid)
    notexecuted(txid){
        require( respond[txid][msg.sender], "not approved");
        respond[txid][msg.sender]=false;
        emit revoke(msg.sender,txid);
    }
}
