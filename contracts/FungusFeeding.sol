// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./FungusFactory.sol";

interface FeedFactoryInterface {
    function getFeed(uint _id) external view returns (string memory name, uint dna, uint price);
}

contract FungusFeeding is FungusFactory {

    FeedFactoryInterface feedContract;

    function setFeedFactoryContractAddress(address addr) external onlyOwner {
        feedContrat = FeedFactoryInterface(addr);
    }

    function feedAndMultiply(uint fungusId, uint targetDna, string memory species) public {
        require(msg.sender == fungusToOwner[fungusId]); // 주인인지 확인
        Fungus memory myFungus = fungi[fungusId];
        require(_isReady(myFungus));

        targetDna = targetDna % dnaModulus;
        uint newDna = (targetDna + myFungus.dna) / 2;
        
        if(keccak256(bytes(species)) == keccak256(bytes("feed"))) {
            newDna = newDna - newDna % 100 + 1 ;
        }

        _createFungus("Noname", newDna);
        _triggerCoolDown(myFungus);
    }

    function feed(uint fungusId, uint feedId) public payable {
        uint feedDna;
        uint feedPrice;
        (, feedDna, feedPrice) = feedContract.getFeed(feedId);
        require(msg.value == feedPrice);
        feedAndMultiply(fungusId, feedDna, "feed");
    }
    function _triggerCoolDown(Fungus memory fungus) internal view {
        fungus.cooldownTime = uint32(block.timestamp + cooldownTime);
    }

    function _isReady(Fungus memory fungus) internal view returns (bool) {
        return (fungus.cooldownTime <= block.timestamp);
    }
}