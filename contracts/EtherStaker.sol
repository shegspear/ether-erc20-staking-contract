// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

contract EtherStaker {

    // SI = (P * R * T) /100

    address private owner;
    uint256 private rate = 10;

    error ZeroAddressDetected();
    error ZeroAmoutDetected();
    error UserAlreadyStaked();
    error UserHasNotStaked();

    struct Staker {
        address account;
        uint256 timeStamp;
    }

    constructor(address _owner) payable {
        owner = _owner;
    }

    mapping(address => uint) ledger;
    mapping(address => Staker) stakers;


    function deposit() external payable {

        if(msg.sender == address(0)) { revert ZeroAddressDetected();}

        if(msg.value == 0) {revert ZeroAmoutDetected();}

        if(ledger[msg.sender] == 0) {

            stakers[msg.sender] = Staker(msg.sender, block.timestamp);

            ledger[msg.sender] = msg.value;
        } else {
            revert UserAlreadyStaked();
        }
 
    }

    function withDraw() external {
        if(msg.sender == address(0)) {revert ZeroAddressDetected();}

        if(ledger[msg.sender] == 0) {revert UserHasNotStaked();}

        Staker memory _user = stakers[msg.sender];
        uint256 _time = (block.timestamp - _user.timeStamp) / (31e8);
        uint256 _totalAmount = ledger[_user.account] + ((ledger[_user.account] * rate * _time) / 100);

        (bool success,) = msg.sender.call{value : _totalAmount}("");
        require(success, "failed withdrawal!");

        delete stakers[msg.sender];
        delete ledger[msg.sender];
    }
    
}