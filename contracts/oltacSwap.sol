// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.3;

pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./oltac.sol";
import "./pricefeed.sol";

contract OltSwap is PriceConsumerV3 {
  
    ISwapRouter public immutable swapRouter;

    // This example swaps olt/WETH9 for single path swaps 

    address public constant olt = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address Owner;

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;
    



     int256 oracleprice;
     int8 counter;


    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
        msg.sender == Owner;
    }

    modifier onlyOwner {
        require(msg.sender == Owner, "not owner");
        require(counter == 0, "can only be called once");
        _;
    }


    function swapExactInputSingle(uint256 amountIn)  onlyOwner() external returns (uint256 amountOut)  {
        // msg.sender must approve this contract

        // Transfer the specified amount of olt to this contract.
        TransferHelper.safeTransferFrom(olt, msg.sender, address(this), amountIn);

        // Approve the router to spend olt.
        TransferHelper.safeApprove(olt, address(swapRouter), amountIn);

        oracleprice =  getLatestPrice(); 

        uint divider = uint256(oracleprice/ (10 ** 6) / (4500 * 10 ** 8));




        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: olt,
                tokenOut: WETH9,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: divider,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }

    
}