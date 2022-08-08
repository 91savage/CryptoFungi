// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./FungusFactory.sol";

// 외부 컨트랙트와 상호작용하기 위한 인터페이스 정의
interface FeedFactoryInterface {

    // 외부 컨트랙트에서 필요한 함수 헤더만 선언
    // 솔리디티 함수는 여러 개의 리턴 값을 가질 수 있음
    function getFeed(uint _id) external view returns (
        string memory name,
        uint dna,
        uint price
    );
}

// 상속, 자식 컨트랙트는 접근 제어자가 private인 변수나 함수를 제외하고
// 부모에 선언된 모든 함수와 변수에 접근할 수 있음
contract FungusFeeding is FungusFactory {
    
    // 외부 컨트랙트 인터페이스 선언
    FeedFactoryInterface feedContract;

    // 함수 제어자
    modifier onlyOwnerOf(uint fungusId) {
        // 주어진 조건을 만족하지 않으면 revert
        require(_msgSender() == fungusToOwner[fungusId]);
        // 다음 구문을 계속해서 진행
        _;
    }
    
    function setFeedFactoryContractAddress(address address_) external onlyOwner {
        // 외부 컨트랙트 객체 생성
        feedContract = FeedFactoryInterface(address_);
    }

    // fungus 매개변수가 함수 내에서 변경되기 때문에 memory로 선언
    function _triggerCooldown(Fungus memory fungus) internal view {    
        fungus.readyTime = uint32(block.timestamp + cooldownTime);
    }

    function _isReady(Fungus memory fungus) internal view returns (bool) {
        return (fungus.readyTime <= block.timestamp);
    }

    function feedAndMultiply(uint fungusId, uint targetDna, string memory species) internal onlyOwnerOf(fungusId) {
        Fungus memory myFungus = fungi[fungusId];
        require(_isReady(myFungus), "not ready");
        targetDna = targetDna % dnaModulus;
        uint newDna = (myFungus.dna + targetDna) / 2;

        if (keccak256(bytes(species)) == keccak256("feed")) {
            newDna = newDna - newDna % 100 + 1;
        }

        _createFungus("Noname", newDna);
        _triggerCooldown(myFungus);
    }

    // 함수 호출 시 송금이 필요한 함수는 payable 키워드를 이용해서 정의
    function feed(uint fungusId, uint feedId) public payable {
        uint feedDna;
        uint feedPrice;
        
        // 여러 개의 리턴 값 중 사용하지 않는 리턴 값은 공백으로 처리할 수 있음
        (,feedDna,feedPrice) = feedContract.getFeed(feedId);
        require(msg.value == feedPrice, "be paid inappropriate expenses");
        feedAndMultiply(fungusId, feedDna, "feed");
    }
}