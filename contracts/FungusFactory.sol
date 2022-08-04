// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract FungusFactory {
    uint dnaDigits = 14;
    uint dnaModulus = 10 ** dnaDigits;

    struct Fungus {
        string name;
        uint dna;
    }

    Fungus[] public fungi; //자료형 접근제어자 

    function _createFungus(string calldata name, uint dna) private {
        fungi.push(Fungus(name, dna));
    }

    function _generateRandomData(string calldata str) private view returns(uint) {
        uint rand = uint(keccak256(bytes(str)));
        uint dna = rand % dnaModulus;
        return dna - dna % 100;

    }
}