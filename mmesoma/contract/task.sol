// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract VIP_Bank {
    address public manager;
    mapping(address => uint) public balances;
    mapping(address => bool) public VIP;
    uint public maxETH = 0.5 ether;

    event VIPAdded(address indexed addr); // Event for adding VIPs
    event Withdrawn(address indexed addr, uint amount); // Event for withdrawals

    constructor() {
        manager = msg.sender;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "you are not manager");
        _;
    }

    modifier onlyVIP() {
        require(VIP[msg.sender] == true, "you are not our VIP customer");
        _;
    }

    function addVIP(address addr) public onlyManager {
        require(addr != address(0), "Invalid address"); // Check for zero address
        require(!VIP[addr], "Address is already a VIP"); // Prevent adding the same VIP
        VIP[addr] = true;
        emit VIPAdded(addr); // Emit event when a VIP is added
    }

    function deposit() public payable onlyVIP {
        require(
            msg.value <= 0.05 ether,
            "Cannot deposit more than 0.05 ETH per transaction"
        );
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) public onlyVIP {
        require(
            _amount <= maxETH,
            "Cannot withdraw more than 0.5 ETH per transaction"
        );
        require(balances[msg.sender] >= _amount, "Not enough ether");
        
        balances[msg.sender] -= _amount;
        
        // Using call to transfer funds, but ensure state is updated first
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdraw Failed!");

        emit Withdrawn(msg.sender, _amount); // Emit event when funds are withdrawn
    }

    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}