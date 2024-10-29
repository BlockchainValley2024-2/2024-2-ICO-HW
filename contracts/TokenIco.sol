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
    struct TokenDetails{
        address token;
        bool supported;
        uint256 price;
        address creator;
        string name;
        string symbol;
        uint256 availableSupply;
    }
    // *******************************************
    // tokenDetails 는 각각의 토큰 주소와 토큰 정보를 담고있는 TokenDetails 를 연결한 mapping 입니다.
    // TokenDetails 와 tokenDetails 는 다르니 대소문자를 주의해주세요!
    mapping(address => TokenDetails) public tokenDetails;
    
    // *******************************************
    // 이곳에 이벤트를 정의해주세요
    event TokenReceived(
        address indexed token,
        address indexed from,
        uint256 amount
    );

    event TokenTransferred(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    event TokenWithdraw(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    event TokenAdded(
        address indexed token,
        uint256 price,
        address indexed creator,
        string name,
        string symbol
    );
    // *******************************************

    // *******************************************
    // 이곳에 Modifier를 정의해주세요
    modifier supportedToken(address _token) {
        require(tokenDetails[_token].supported, "Token not supported");
        _;
    }

    modifier onlyCreator(address _token) {
        require(msg.sender == tokenDetails[_token].creator, "Caller is not the token creator");
        _;
    }
    // *******************************************


    // ICO 생성 및 토큰 예치
    function createICOSale(address _token, uint256 _price, uint256 _supply) external {
       IERC20 token = IERC20(_token);
       require(_supply > 0, "Supply must be greater than 0");
       require(token.balanceOf(msg.sender) >= _supply * 10**18, "Insufficient token balance");
       require(token.transferFrom(msg.sender, address(this), _supply * 10**18), "Token deposit failed");
       string memory tokenName = token.name();
       string memory tokenSymbol = token.symbol();

       tokenDetails[_token] = TokenDetails({
        token: _token,
        supported: true,
        price: _price,
        creator: msg.sender, // creator에 뭐가 들어가야되는지 모르겠습니다
        name: tokenName,
        symbol: tokenSymbol,
        availableSupply: _supply
       });

       emit TokenAdded(_token, _price, msg.sender, tokenName, tokenSymbol);
    }

    // 토큰 구매
    function buyToken(address _token, uint256 _amount) external payable supportedToken(_token) {
        require(_amount > 0, "Amount must be greater than 0");

        TokenDetails storage details = tokenDetails[_token];
        require(details.availableSupply >= _amount, "Not enough tokens available");

        uint256 totalCost = details.price * _amount;
        require(msg.value == totalCost, "Incorrect Ether amount sent");

        (bool sent, ) = details.creator.call{value: msg.value}("");
        require(sent, "Failed to transfer Ether to token creator");

        tokenDetails[_token].availableSupply -= _amount;

        IERC20 token = IERC20(_token);
        require(
            token.transfer(msg.sender, _amount * 10**18),
            "Token transfer failed"
        );

        emit TokenTransferred(_token, msg.sender, _amount);
    }

    // 특정 토큰의 남은 판매 수량 확인
    function getAvailableSupply(address _token) external view supportedToken(_token) returns (uint256) {
        return tokenDetails[_token].availableSupply;
    }

    // 판매자가 남은 토큰을 인출
    function withdraw(address _token, uint256 _amount) external onlyCreator(_token) supportedToken(_token) {
        require(_amount > 0, "Amount must be greater than 0");

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= _amount * 10**18, "Insufficient token balance");

        require(token.transfer(msg.sender, _amount * 10**18),"Token transfer failed");

        emit TokenWithdraw(_token, msg.sender, _amount);
    }
}
