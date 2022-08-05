// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FungusFactory {


    uint dnaDigits = 14;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 minutes;

    struct Fungus {
        string name;
        uint dna;
        uint32 readyTime;
    }

    Fungus[] public fungi; //자료형 접근제어자 

    mapping (uint => address) public fungusToOwner;  // ID를 넣으면 주소가 나오게 함
    mapping (address => uint) public ownerFungusCount; // address가 몇 개의 fungi를 가지고 있는지

    event newFungus(uint, string, uint);

    function _createFungus(string memory name, uint dna, uint32 readyTime) internal {
        fungi.push(Fungus(name, dna, uint32(block.timestamp + readyTime)));
        uint id = fungi.length -1;
        fungusToOwner[id] = msg.sender;
        ownerFungusCount[msg.sender]++;
        emit newFungus(id, name, dna);
    }

    function _generateRandomData(string calldata _str) private view returns(uint) {
        uint rand = uint(keccak256(bytes(_str)));
        uint dna = rand % dnaModulus;
        dna = dna - dna % 100;
        return dna;

    }

    function createFungus(string calldata name) public {
        require(ownerFungusCount[msg.sender] == 0, "A fungus already exist.");
        uint randDna = _generateRandomData(name);
        _createFungus(name,randDna);
    }

}

