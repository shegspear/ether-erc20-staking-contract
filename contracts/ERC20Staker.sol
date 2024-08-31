// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERCStaker {

    struct Staker {
        address account;
        uint256 timeStamp;
    }

    address owner;
    address tokenAddress;
    uint256 rate = 10;

    mapping(address => uint) ledger;
    mapping(address => Staker) stakers;

    error ZeroAddressDetected();
    error ZeroAmoutDetected();
    error UserAlreadyStaked();
    error UserHasNotStaked();
    error InsufficientFunds();

    constructor(address _tokenAddress, address _owner) {
        owner = _owner;
        tokenAddress = _tokenAddress;
    }

    function givePermission(uint256 _amount) external {
        if(msg.sender == address(0)) { revert ZeroAddressDetected();}

        if(_amount == 0) {revert ZeroAmoutDetected();}

        IERC20(tokenAddress).approve(msg.sender, _amount);
    }

    function deposit(uint256 _amount) external {

        if(msg.sender == address(0)) { revert ZeroAddressDetected();}

        if(_amount == 0) {revert ZeroAmoutDetected();}

        if(ledger[msg.sender] == 0) {

            uint256 _userTokenBalance = IERC20(tokenAddress).balanceOf(msg.sender);

            if(_userTokenBalance < _amount) {
                revert InsufficientFunds();
            }

            IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);

            stakers[msg.sender] = Staker(msg.sender, block.timestamp);

            ledger[msg.sender] = _amount;
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

        IERC20(tokenAddress).transfer(msg.sender, _totalAmount);

        delete stakers[msg.sender];
        delete ledger[msg.sender];
    }

}