pragma solidity ^0.4.23;

contract Bank {
    // 此合約的擁有者
    address private owner;

    // 儲存所有會員的餘額
    mapping (address => uint256) private coinBalances;
    mapping (address => uint256) private etherBalances;

    // 事件們，用於通知前端 web3.js
    event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
    event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
    event transferCoinEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);
    event TransferEtherEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);
    event BuyCoinEvent(address indexed from,uint256 value, uint256 timestamp);

    // 建構子
    constructor() public {
        owner = msg.sender;
    }
    
    //鑄幣
    function mint(uint256 etherValue) public{
        require(msg.sender == owner);
        uint256 weiValue = etherValue * 1 ether;
        coinBalances[owner] += weiValue;
    }
    
    // 存錢
    function deposit() public payable {
        etherBalances[msg.sender] += msg.value;

        // emit DepositEvent
        emit DepositEvent(msg.sender, msg.value, now);
    }

    // 提錢
    function withdraw(uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(etherBalances[msg.sender] >= weiValue, "your balances are not enough");

        msg.sender.transfer(weiValue);

        etherBalances[msg.sender] -= weiValue;

        // emit WithdrawEvent
        emit WithdrawEvent(msg.sender, etherValue, now);
    }
    
    //購買
    function buy(uint256 etherValue) public payable{
        uint256 weiValue = etherValue * 1 ether;
        require(coinBalances[owner] >= weiValue);
        require(etherBalances[msg.sender] >= weiValue);
        etherBalances[msg.sender] -= weiValue;
        etherBalances[owner] += weiValue;
        coinBalances[msg.sender] += weiValue;
        coinBalances[owner] -= weiValue;
        emit BuyCoinEvent(msg.sender, etherValue, now);
    }

    
    // 轉帳Coin
    function transferCoin(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(coinBalances[msg.sender] >= weiValue);

        coinBalances[msg.sender] -= weiValue;
        coinBalances[to] += weiValue;

        emit transferCoinEvent(msg.sender, to, etherValue, now);
    }
    
    // 轉帳Ether
    function transferEther(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(etherBalances[msg.sender] >= weiValue, "your balances are not enough");

        etherBalances[msg.sender] -= weiValue;
        etherBalances[to] += weiValue;

        // emit TransferEvent
        emit TransferEtherEvent(msg.sender, to, etherValue, now);
    }

    
    // 檢查Owner
    function checkOwner() public view returns(address){
        return owner;
    }
    
    //轉移Owner
    function transferOwner(address newOwner) public{
        require(msg.sender == owner);
        owner=newOwner;
    }
    
    // 檢查銀行帳戶餘額
    function checkBankBalance() public view returns (uint256) {
        return coinBalances[msg.sender];
    }

    // 檢查以太帳戶餘額
    function checkEtherBalance() public view returns (uint256) {
        return etherBalances[msg.sender];
    }
}