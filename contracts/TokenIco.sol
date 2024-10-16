// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 이전 세션들에서는 interface를 ' 구현을 위한 목적 ' 으로 사용했습니다 ( 꼭 구현해야 하는 함수들을 모두 명시 )
// 아래의 interface는 그렇게 만들어진 ERC20 표준 토큰과 '상호작용 ' 하기위해 사용되는 Interface입니다. ( 상호작용에 필요한 함수들만 명시 )
// interface에 토큰 주소를 넣어서 사용합니다
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function name() external view returns (string memory);
}

contract TokenIco {

    constructor() {}



    // *******************************************
    // 이곳에 구조체를 정의해주세요
    // *******************************************

    // tokenDetails 는 각각의 토큰 주소와 토큰 정보를 담고있는 TokenDetails 를 연결한 mapping 입니다.
    // TokenDetails 와 tokenDetails 는 다르니 대소문자를 주의해주세요!
    mapping(address => TokenDetails) public tokenDetails;
    
    // *******************************************
    // 이곳에 이벤트를 정의해주세요
    // *******************************************

    // *******************************************
    // 이곳에 Modifier를 정의해주세요
    // *******************************************


    // ICO 생성 및 토큰 예치
    function createICOSale(address _token, uint256 _price, uint256 _supply) external {
       
    }

    // 토큰 구매
    function buyToken(address _token, uint256 _amount) external payable supportedToken(_token) {
     
    }

    // 특정 토큰의 남은 판매 수량 확인
    function getAvailableSupply(address _token) external view supportedToken(_token) returns (uint256) {
    
    }

    // 판매자가 남은 토큰을 인출
    function withdraw(address _token, uint256 _amount) external onlyCreator(_token) supportedToken(_token) {
      
    }
}
