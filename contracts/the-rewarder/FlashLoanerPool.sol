// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";

/**
 * @title FlashLoanerPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)

 * @dev A simple pool to get flash loans of DVT
 */
contract FlashLoanerPool is ReentrancyGuard {
    using Address for address;

    DamnValuableToken public immutable liquidityToken;

    constructor(address liquidityTokenAddress) {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
    }

    function flashLoan(uint256 amount) external nonReentrant {
        uint256 balanceBefore = liquidityToken.balanceOf(address(this));
        console.log("here 0");
        require(amount <= balanceBefore, "Not enough token balance");

        console.log("here 1");
        require(
            msg.sender.isContract(),
            "Borrower must be a deployed contract"
        );

        console.log("here 2");
        liquidityToken.transfer(msg.sender, amount);
        console.log("here 3");
        msg.sender.functionCall(
            abi.encodeWithSignature("receiveFlashLoan(uint256)", amount)
        );
        console.log("here 4");

        require(
            liquidityToken.balanceOf(address(this)) >= balanceBefore,
            "Flash loan not paid back"
        );
    }
}
