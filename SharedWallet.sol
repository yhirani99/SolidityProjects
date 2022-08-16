//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Allowance is Ownable{
    event AllowanceChanged(address indexed _forWho, address indexed _byWhom, uint oldA, uint newA);

    function isOwner() internal view returns(bool) {
        return owner() == msg.sender;
    }

    mapping(address => uint) public allowance;

    function addAllowance(address _who, uint _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount); 
        allowance[_who] = _amount;
    }

    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "You are not allowed!");
        _;
    }

    function reduceAllowance(address _who, uint _amount) internal{
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who]-_amount); 
        allowance[_who] -= _amount;
    }

}

contract SharedWallet is Allowance {

    event moneyOut(address indexed _benfeciary, uint _amount);
    event moneyIn(address indexed _from, uint _amount);

    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "Contract doesn't own enough money");
        if (!isOwner()){
            reduceAllowance(msg.sender, _amount);
        }
        emit moneyOut(_to, _amount);
        _to.transfer(_amount);
    }

    function renounceOwnership() public view override onlyOwner{
        revert("Cannot use this function");
    }

    receive() external payable {
        emit moneyIn(msg.sender, msg.value);
    }
}
